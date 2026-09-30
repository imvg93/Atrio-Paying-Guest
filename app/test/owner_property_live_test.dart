import 'dart:io';

import 'package:atrio_pg/core/network/api_client.dart';
import 'package:atrio_pg/core/network/api_exception.dart';
import 'package:atrio_pg/core/network/auth_interceptor.dart';
import 'package:atrio_pg/core/storage/token_storage.dart';
import 'package:atrio_pg/features/auth/data/auth_repository.dart';
import 'package:atrio_pg/features/auth/data/models/user.dart';
import 'package:atrio_pg/features/meta/data/amenity_repository.dart';
import 'package:atrio_pg/features/owner/application/active_property_provider.dart';
import 'package:atrio_pg/features/owner/application/owner_properties_controller.dart';
import 'package:atrio_pg/features/owner/data/models/property_draft.dart';
import 'package:atrio_pg/features/owner/data/owner_property_repository.dart';
import 'package:atrio_pg/features/properties/data/models/property.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drives the Wave 1 owner property layer against a running backend, through
/// the app's own [ApiClient], [OwnerPropertyRepository] and controllers.
///
/// The point is the contract: `flutter analyze` is perfectly happy with a
/// freezed field named `totalBeds` when the API sends `occupancy.totalBeds`,
/// and nothing but a real response catches it.
///
/// ```
/// flutter test test/owner_property_live_test.dart \
///   --dart-define=API_BASE_URL=http://localhost:8080/api/v1 \
///   --dart-define=BACKEND_LOG=<path to the backend log>
/// ```
void main() {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );
  const logPath = String.fromEnvironment('BACKEND_LOG');

  late bool backendUp;

  setUpAll(() async {
    // ensureInitialized installs HttpOverrides that answer every real request
    // with an empty 400. Dropping it restores real dart:io.
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;

    backendUp = await _probe(baseUrl);
    _installSecureStorageMock();
  });

  setUp(_secureStorageContents.clear);

  Future<String> latestCode() async {
    final lines = await File(logPath).readAsLines();
    final line = lines.lastWhere((l) => l.contains('code  :'));
    return line.split('code  :').last.trim();
  }

  String newPhone() =>
      '+9199${DateTime.now().microsecondsSinceEpoch % 100000000}'
          .padRight(13, '0')
          .substring(0, 13);

  ProviderContainer container() => ProviderContainer(
        overrides: [
          dioProvider.overrideWith((ref) {
            final options = BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              contentType: Headers.jsonContentType,
            );
            final dio = Dio(options);
            dio.interceptors.add(
              AuthInterceptor(
                storage: ref.watch(tokenStorageProvider),
                refreshDio: Dio(options),
                onAuthFailure: () async {
                  ref.read(authFailureProvider.notifier).signal();
                },
              ),
            );
            return dio;
          }),
        ],
      );

  /// Creates an account, locks it to owner, and leaves a usable token pair in
  /// storage.
  ///
  /// Signs in twice on purpose: the role is a claim in the access token, minted
  /// at verify time, so the token issued before `PATCH /auth/profile` still says
  /// "student" and would be turned away by the `/owner/**` role guard.
  Future<void> signInAsOwner(ProviderContainer ref) async {
    final repo = ref.read(authRepositoryProvider);
    final storage = ref.read(tokenStorageProvider);
    final phone = newPhone();

    await repo.requestOtp(phone);
    final tokens = await repo.verifyOtp(phone: phone, code: await latestCode());
    await storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    await repo.updateProfile(name: 'Wave1 Owner', role: UserRole.owner);

    await repo.requestOtp(phone);
    final reissued =
        await repo.verifyOtp(phone: phone, code: await latestCode());
    await storage.saveTokens(
      accessToken: reissued.accessToken,
      refreshToken: reissued.refreshToken,
    );
  }

  PropertyDraft draft() => const PropertyDraft(
        name: 'Sunrise PG',
        description: 'Five minutes from the metro',
        genderType: PropertyGenderType.coliving,
        addressLine: '12 MG Road',
        locality: 'Indiranagar',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560038',
        latitude: 12.971599,
        longitude: 77.594566,
        amenities: {'wifi': true, 'ac': false},
        rules: {'gateClosingTime': '22:30'},
        foodIncluded: true,
        noticePeriodDays: 45,
      );

  bool skip() {
    if (!backendUp || logPath.isEmpty) {
      markTestSkipped(
        'No backend at $baseUrl (or BACKEND_LOG unset) — skipping live flow.',
      );
      return true;
    }
    return false;
  }

  test('create -> list -> get -> patch -> publish -> delete', () async {
    if (skip()) return;

    final ref = container();
    addTearDown(ref.dispose);
    await signInAsOwner(ref);

    final repo = ref.read(ownerPropertyRepositoryProvider);

    // --- create ----------------------------------------------------
    final created = await repo.create(draft());
    expect(created.id, isNotEmpty);
    expect(created.name, 'Sunrise PG');
    expect(created.status, PropertyStatus.draft,
        reason: 'POST always creates a draft; publishing is a separate call');
    expect(created.genderType, PropertyGenderType.coliving);
    expect(created.amenities['wifi'], isTrue);
    expect(created.rules?['gateClosingTime'], '22:30');
    expect(created.noticePeriodDays, 45);
    expect(created.foodIncluded, isTrue);
    expect(created.latitude, closeTo(12.971599, 0.000001));
    expect(created.createdAt, isNotNull,
        reason: 'timestamps must parse as DateTime, not arrive as strings');

    // The nested occupancy object is the field name most likely to drift.
    expect(created.occupancy.totalBeds, 0);
    expect(created.occupancy.hasNoBeds, isTrue);
    expect(created.occupancy.occupancyRate, 0,
        reason: 'no beds must not divide by zero');
    expect(created.minRentPaise, isNull,
        reason: 'a property with no rooms has no rent range yet');
    expect(created.photos, isEmpty);

    // --- list ------------------------------------------------------
    final page = await repo.list();
    expect(page.page, 1);
    expect(page.limit, 20);
    expect(page.total, 1);
    final card = page.items.single;
    expect(card.id, created.id);
    expect(card.name, 'Sunrise PG');
    expect(card.shortAddress, 'Indiranagar, Bengaluru');
    expect(card.occupancy.totalBeds, 0);
    expect(card.photoCount, 0);
    expect(card.coverPhotoUrl, isNull);
    expect(card.hasRent, isFalse);

    // --- get -------------------------------------------------------
    final fetched = await repo.get(created.id);
    expect(fetched.id, created.id);
    expect(fetched.activeAmenities, ['wifi'],
        reason: 'ac is present but false, so it is not an active amenity');

    // --- patch, as a diff ------------------------------------------
    final edited = PropertyDraft.from(fetched).copyWith(
      name: 'Sunrise PG Deluxe',
      description: '',
      amenities: const {'gym': true},
    );
    final body = edited.toUpdateJson(fetched);
    expect(body.keys, containsAll(<String>['name', 'description', 'amenities']));
    expect(body.containsKey('city'), isFalse,
        reason: 'an unchanged field must not be sent');

    final updated = await repo.update(original: fetched, draft: edited);
    expect(updated.name, 'Sunrise PG Deluxe');
    expect(updated.description, isNull, reason: '"" clears the description');
    expect(updated.amenities.containsKey('wifi'), isFalse,
        reason: 'amenities are replaced wholesale, not merged');
    expect(updated.city, 'Bengaluru', reason: 'untouched by the patch');

    // An unchanged draft must not produce a request at all.
    final unchanged = await repo.update(
      original: updated,
      draft: PropertyDraft.from(updated),
    );
    expect(unchanged.updatedAt, updated.updatedAt);

    // --- publish ---------------------------------------------------
    final published =
        await repo.updateStatus(created.id, PropertyStatus.published);
    expect(published.status, PropertyStatus.published);
    expect(published.isPublished, isTrue);

    // --- delete is soft --------------------------------------------
    await repo.delete(created.id);
    await expectLater(
      repo.get(created.id),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 404)),
    );
    expect((await repo.list()).total, 0);
  });

  test('the controller adopts a single property and drops it on delete',
      () async {
    if (skip()) return;

    final ref = container();
    addTearDown(ref.dispose);
    await signInAsOwner(ref);

    final controller = ref.read(ownerPropertiesProvider.notifier);
    await ref.read(ownerPropertiesProvider.future);
    expect(ref.read(ownerPropertyCountProvider), 0);
    expect(ref.read(activePropertyProvider), isNull);

    final created = await controller.create(draft());

    // Exactly one property means no switcher, so the shell needs the selection
    // made for the owner rather than by them.
    expect(ref.read(ownerPropertyCountProvider), 1);
    expect(ref.read(activePropertyProvider)?.id, created.id);

    // A second property makes the choice ambiguous again — the existing
    // selection stands rather than flip-flopping.
    await controller.create(draft().copyWith(name: 'Moonlight PG'));
    expect(ref.read(ownerPropertyCountProvider), 2);
    expect(ref.read(activePropertyProvider)?.id, created.id);

    // Deleting the active property clears it, and the refetch that follows
    // finds exactly one left and adopts it. Landing on the survivor is the
    // point: the Tenants, Rent and More tabs are scoped to the selection, and
    // leaving it null would strand them with nothing to show.
    final survivor = ref.read(ownerPropertiesProvider).value!.items
        .firstWhere((p) => p.id != created.id);
    await controller.delete(created.id);
    expect(ref.read(ownerPropertyCountProvider), 1);
    expect(ref.read(activePropertyProvider)?.id, survivor.id);

    // Deleting the last one leaves nothing to adopt, so the selection stays
    // cleared rather than pointing at a property that no longer exists.
    await controller.delete(survivor.id);
    expect(ref.read(ownerPropertyCountProvider), 0);
    expect(ref.read(activePropertyProvider), isNull);
  });

  test('the status filter round-trips through the API', () async {
    if (skip()) return;

    final ref = container();
    addTearDown(ref.dispose);
    await signInAsOwner(ref);

    final controller = ref.read(ownerPropertiesProvider.notifier);
    await ref.read(ownerPropertiesProvider.future);

    final a = await controller.create(draft());
    await controller.create(draft().copyWith(name: 'Moonlight PG'));
    await controller.updateStatus(a.id, PropertyStatus.published);

    await controller.setStatusFilter(PropertyStatus.published);
    final published = ref.read(ownerPropertiesProvider).value!;
    expect(published.total, 1);
    expect(published.items.single.id, a.id);

    await controller.setStatusFilter(PropertyStatus.draft);
    expect(ref.read(ownerPropertiesProvider).value!.total, 1);

    await controller.setStatusFilter(null);
    expect(ref.read(ownerPropertiesProvider).value!.total, 2);
  });

  test('the amenity catalogue is server-driven and groups cleanly', () async {
    if (skip()) return;

    final ref = container();
    addTearDown(ref.dispose);
    await signInAsOwner(ref);

    final amenities = await ref.read(amenityCatalogueProvider.future);
    expect(amenities, isNotEmpty);
    expect(amenities.map((a) => a.key), contains('wifi'));
    expect(amenities.every((a) => a.label.isNotEmpty), isTrue);

    final grouped = ref.read(groupedAmenitiesProvider).value!;
    expect(grouped, isNotEmpty);
    expect(grouped.first.key, 'essentials',
        reason: 'known groups render in amenityGroupOrder');
    // Nothing may be dropped on the way through the grouping.
    final regrouped = grouped.expand((e) => e.value).length;
    expect(regrouped, amenities.length);
  });
}

Future<bool> _probe(String baseUrl) async {
  try {
    final response = await Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    )).get<dynamic>('/health');
    return response.statusCode == 200;
  } catch (e) {
    // ignore: avoid_print
    print('Health probe on $baseUrl failed: $e');
    return false;
  }
}

final _secureStorageContents = <String, String>{};

void _installSecureStorageMock() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = _secureStorageContents;

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
    final key = args['key'] as String?;
    switch (call.method) {
      case 'write':
        store[key!] = args['value'] as String;
        return null;
      case 'read':
        return store[key];
      case 'delete':
        store.remove(key);
        return null;
      case 'deleteAll':
        store.clear();
        return null;
      case 'readAll':
        return Map<String, String>.from(store);
      case 'containsKey':
        return store.containsKey(key);
      default:
        return null;
    }
  });
}
