@Tags(['golden'])
library;

import 'dart:io';

import 'package:atrio_pg/core/network/paginated.dart';
import 'package:atrio_pg/core/theme/app_theme.dart';
import 'package:atrio_pg/features/meta/data/amenity.dart';
import 'package:atrio_pg/features/meta/data/amenity_repository.dart';
import 'package:atrio_pg/features/owner/data/models/property_draft.dart';
import 'package:atrio_pg/features/owner/data/owner_property_repository.dart';
import 'package:atrio_pg/features/owner/presentation/owner_portfolio_screen.dart';
import 'package:atrio_pg/features/owner/presentation/property_overview_screen.dart';
import 'package:atrio_pg/features/owner/presentation/property_settings_screen.dart';
import 'package:atrio_pg/features/owner/presentation/property_wizard_screen.dart';
import 'package:atrio_pg/features/properties/data/models/property.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders each Wave 1 owner screen to a PNG under `test/goldens/`.
///
/// Not an assertion suite — these are for *looking at*. `flutter analyze` and
/// the render tests prove the screens build and lay out; they say nothing about
/// whether the result is worth shipping, and on a machine where the Android
/// build is slow this is far quicker than an emulator round trip.
///
/// Run with:
/// ```
/// flutter test test/owner_screens_golden_test.dart --update-goldens
/// ```
///
/// The Flutter test harness ships no real font — text would otherwise render as
/// filled boxes — so Roboto and the Material icon font are loaded from the SDK
/// cache first. Without that, every one of these images is unreadable.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFont('Roboto', [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
    ]);
    await _loadFont('MaterialIcons', ['materialicons-regular.otf']);
  });

  final property = Property(
    id: 'a3f1c2d4-0000-4000-8000-000000000001',
    name: 'Sunrise Residency',
    description:
        'A quiet, well-kept PG five minutes from the metro, with home-style '
        'meals and a study room on every floor.',
    genderType: PropertyGenderType.coliving,
    addressLine: '12 MG Road, above Sunrise Bakery',
    locality: 'Indiranagar',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560038',
    latitude: 12.971599,
    longitude: 77.594566,
    amenities: const {
      'wifi': true,
      'power_backup': true,
      'meals': true,
      'cctv': true,
      'laundry': true,
      'ac': false,
    },
    rules: const {'gateClosingTime': '22:30', 'visitorsAllowed': false},
    foodIncluded: true,
    noticePeriodDays: 30,
    status: PropertyStatus.published,
    occupancy: const OccupancySummary(
      totalBeds: 18,
      occupiedBeds: 12,
      availableBeds: 5,
      maintenanceBeds: 1,
    ),
    minRentPaise: 750000,
    maxRentPaise: 1200000,
    createdAt: DateTime(2026, 6, 1),
    updatedAt: DateTime(2026, 7, 20),
  );

  final second = property.copyWith(
    id: 'b7e2d3a1-0000-4000-8000-000000000002',
    name: 'Green Nest PG',
    locality: 'Koramangala',
    genderType: PropertyGenderType.female,
    status: PropertyStatus.draft,
    occupancy: const OccupancySummary(
      totalBeds: 9,
      occupiedBeds: 3,
      availableBeds: 6,
    ),
    minRentPaise: 900000,
    maxRentPaise: 900000,
  );

  final third = property.copyWith(
    id: 'c1a9f8b2-0000-4000-8000-000000000003',
    name: 'Metro Stay',
    locality: 'HSR Layout',
    genderType: PropertyGenderType.male,
    status: PropertyStatus.unlisted,
    occupancy: const OccupancySummary(),
    minRentPaise: null,
    maxRentPaise: null,
  );

  final portfolio = Paginated<PropertySummary>(
    items: [property.asSummary, second.asSummary, third.asSummary],
    page: 1,
    limit: 20,
    total: 3,
  );

  Widget host(Widget child, {Property? detail, Brightness? brightness}) {
    return ProviderScope(
      overrides: [
        ownerPropertyRepositoryProvider.overrideWithValue(
          _FakeRepository(page: portfolio, detail: detail ?? property),
        ),
        amenityRepositoryProvider.overrideWithValue(_FakeAmenityRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.dark
            ? AppTheme.dark()
            : AppTheme.light(),
        home: child,
      ),
    );
  }

  /// A tall phone, so a screenshot shows a realistic amount of each screen
  /// rather than the harness default of 800x600.
  Future<void> phone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('H1 portfolio', (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(const OwnerPortfolioScreen()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(OwnerPortfolioScreen),
      matchesGoldenFile('goldens/h1_portfolio.png'),
    );
  });

  testWidgets('H1 portfolio dark', (tester) async {
    await phone(tester);
    await tester.pumpWidget(
      host(const OwnerPortfolioScreen(), brightness: Brightness.dark),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(OwnerPortfolioScreen),
      matchesGoldenFile('goldens/h1_portfolio_dark.png'),
    );
  });

  testWidgets('H1 portfolio empty', (tester) async {
    await phone(tester);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        ownerPropertyRepositoryProvider.overrideWithValue(
          _FakeRepository(
            page: const Paginated<PropertySummary>.empty(),
            detail: property,
          ),
        ),
        amenityRepositoryProvider.overrideWithValue(_FakeAmenityRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const OwnerPortfolioScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(OwnerPortfolioScreen),
      matchesGoldenFile('goldens/h1_portfolio_empty.png'),
    );
  });

  testWidgets('H2 overview', (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(
      const PropertyOverviewScreen(
        propertyId: 'a3f1c2d4-0000-4000-8000-000000000001',
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PropertyOverviewScreen),
      matchesGoldenFile('goldens/h2_overview.png'),
    );
  });

  testWidgets('H2 overview draft', (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(
      const PropertyOverviewScreen(
        propertyId: 'a3f1c2d4-0000-4000-8000-000000000001',
      ),
      detail: property.copyWith(status: PropertyStatus.draft),
    ));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PropertyOverviewScreen),
      matchesGoldenFile('goldens/h2_overview_draft.png'),
    );
  });

  testWidgets('H3 wizard step 1', (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(const PropertyWizardScreen()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PropertyWizardScreen),
      matchesGoldenFile('goldens/h3_wizard_basics.png'),
    );
  });

  testWidgets('H3 wizard amenities', (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(
      const PropertyWizardScreen(
        propertyId: 'a3f1c2d4-0000-4000-8000-000000000001',
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PropertyWizardScreen),
      matchesGoldenFile('goldens/h3_wizard_amenities.png'),
    );
  });

  testWidgets('H3 wizard review', (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(
      const PropertyWizardScreen(
        propertyId: 'a3f1c2d4-0000-4000-8000-000000000001',
      ),
    ));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    await expectLater(
      find.byType(PropertyWizardScreen),
      matchesGoldenFile('goldens/h3_wizard_review.png'),
    );
  });

  testWidgets('H11 settings', (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(
      const PropertySettingsScreen(
        propertyId: 'a3f1c2d4-0000-4000-8000-000000000001',
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PropertySettingsScreen),
      matchesGoldenFile('goldens/h11_settings.png'),
    );
  });
}

/// Loads a font family from the Flutter SDK's own cache.
///
/// `FLUTTER_ROOT` is set by the `flutter test` wrapper, so this follows
/// whichever SDK is actually running rather than a hardcoded path.
Future<void> _loadFont(String family, List<String> files) async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;

  final loader = FontLoader(family);
  var loaded = 0;
  for (final name in files) {
    final file = File('$root/bin/cache/artifacts/material_fonts/$name');
    if (!file.existsSync()) continue;
    loader.addFont(
      file.readAsBytes().then((b) => ByteData.view(b.buffer)),
    );
    loaded++;
  }
  if (loaded > 0) await loader.load();
}

class _FakeRepository implements OwnerPropertyRepository {
  _FakeRepository({required this.page, required this.detail});

  final Paginated<PropertySummary> page;
  final Property detail;

  @override
  Future<Paginated<PropertySummary>> list({
    int page = 1,
    int limit = 20,
    PropertyStatus? status,
  }) async =>
      this.page;

  @override
  Future<Property> get(String id) async => detail;

  @override
  Future<Property> create(PropertyDraft draft) async => detail;

  @override
  Future<Property> update({
    required Property original,
    required PropertyDraft draft,
  }) async =>
      original;

  @override
  Future<Property> updateStatus(String id, PropertyStatus status) async =>
      detail.copyWith(status: status);

  @override
  Future<void> delete(String id) async {}
}

class _FakeAmenityRepository implements AmenityRepository {
  @override
  Future<List<Amenity>> list() async => const [
        Amenity(key: 'wifi', label: 'Wi-Fi', group: 'essentials'),
        Amenity(key: 'power_backup', label: 'Power backup', group: 'essentials'),
        Amenity(key: 'water_24x7', label: '24x7 water', group: 'essentials'),
        Amenity(key: 'laundry', label: 'Laundry', group: 'essentials'),
        Amenity(key: 'ac', label: 'Air conditioning', group: 'room'),
        Amenity(key: 'geyser', label: 'Geyser', group: 'room'),
        Amenity(key: 'wardrobe', label: 'Wardrobe', group: 'room'),
        Amenity(key: 'meals', label: 'Meals included', group: 'food'),
        Amenity(key: 'ro_water', label: 'RO drinking water', group: 'food'),
        Amenity(key: 'cctv', label: 'CCTV', group: 'safety'),
        Amenity(key: 'security_guard', label: 'Security guard', group: 'safety'),
        Amenity(key: 'parking', label: 'Parking', group: 'common'),
        Amenity(key: 'gym', label: 'Gym', group: 'common'),
      ];
}
