import 'package:atrio_pg/core/router/app_routes.dart';
import 'package:atrio_pg/core/theme/app_theme.dart';
import 'package:atrio_pg/core/theme/status_colors.dart';
import 'package:atrio_pg/features/owner/application/active_property_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('design tokens', () {
    test('status colours are registered in both themes', () {
      // A missing extension would not fail a build — every status would just
      // quietly fall back to the light palette, including in dark mode.
      expect(AppTheme.light().extension<StatusColors>(), isNotNull);
      expect(AppTheme.dark().extension<StatusColors>(), isNotNull);
    });

    test('dark status fills differ from light, rather than being reused', () {
      final light = AppTheme.light().extension<StatusColors>()!;
      final dark = AppTheme.dark().extension<StatusColors>()!;

      expect(dark.positive.fill, isNot(light.positive.fill));
      expect(dark.danger.fill, isNot(light.danger.fill));
    });

    test('every status has distinct fill and content colours', () {
      final light = AppTheme.light().extension<StatusColors>()!;
      for (final palette in [
        light.positive,
        light.warning,
        light.danger,
        light.neutral,
        light.info,
      ]) {
        expect(palette.fill, isNot(palette.content));
      }
    });

    test('the type scale is applied, not left at Material defaults', () {
      final text = AppTheme.light().textTheme;
      expect(text.titleMedium?.fontWeight, FontWeight.w600);
      expect(text.bodyMedium?.fontSize, 14);
      expect(text.labelSmall?.fontWeight, FontWeight.w600);
    });
  });

  group('role routing rules', () {
    test('owner paths are recognised as the owner area', () {
      for (final path in AppRoutes.ownerTabs) {
        expect(AppRoutes.isOwnerArea(path), isTrue, reason: path);
      }
      expect(AppRoutes.isOwnerArea(AppRoutes.ownerPropertyNew), isTrue);
      expect(AppRoutes.isOwnerArea('/owner/property/abc/manage'), isTrue);
    });

    test('student-only paths are recognised', () {
      expect(AppRoutes.isStudentArea(AppRoutes.search), isTrue);
      expect(AppRoutes.isStudentArea('/search/map'), isTrue);
      expect(AppRoutes.isStudentArea(AppRoutes.myVisits), isTrue);
      expect(AppRoutes.isStudentArea('/property/abc'), isTrue);
    });

    test('owner property routes are not mistaken for student ones', () {
      // '/owner/property/...' must not match the '/property/' prefix, or an
      // owner editing their own property would be redirected to their home.
      expect(AppRoutes.isStudentArea('/owner/property/abc/edit'), isFalse);
      expect(AppRoutes.isStudentArea('/owner/property/new'), isFalse);
    });

    test('shared paths belong to neither area, so both roles reach them', () {
      // This is the point of the deny-list: a screen nobody registered is
      // reachable, instead of silently bouncing owners home.
      for (final path in [AppRoutes.profile, '/help', '/notifications']) {
        expect(AppRoutes.isOwnerArea(path), isFalse, reason: path);
        expect(AppRoutes.isStudentArea(path), isFalse, reason: path);
      }
    });

    test('an owner lands on the Home tab', () {
      expect(AppRoutes.ownerDashboard, AppRoutes.ownerHome);
      expect(AppRoutes.ownerTabs.first, AppRoutes.ownerHome);
      expect(AppRoutes.ownerTabs, hasLength(4));
    });
  });

  group('active property', () {
    test('adopts a single property automatically', () {
      final container = _container();
      addTearDown(container.dispose);
      final notifier = container.read(activePropertyProvider.notifier);

      notifier.adoptIfSingle(
        const [ActivePropertySelection(id: 'p1', name: 'Sunrise PG')],
      );

      expect(container.read(activePropertyProvider)?.name, 'Sunrise PG');
    });

    test('does not guess when there are several, or none', () {
      final container = _container();
      addTearDown(container.dispose);
      final notifier = container.read(activePropertyProvider.notifier);

      notifier.adoptIfSingle(const [
        ActivePropertySelection(id: 'p1', name: 'Sunrise PG'),
        ActivePropertySelection(id: 'p2', name: 'Green Nest'),
      ]);
      expect(container.read(activePropertyProvider), isNull);

      notifier.adoptIfSingle(const []);
      expect(container.read(activePropertyProvider), isNull);
    });

    test('an explicit choice wins and can be cleared on sign-out', () {
      final container = _container();
      addTearDown(container.dispose);
      final notifier = container.read(activePropertyProvider.notifier);

      notifier.select(const ActivePropertySelection(id: 'p2', name: 'Green Nest'));
      expect(container.read(activePropertyProvider)?.id, 'p2');

      notifier.clear();
      expect(container.read(activePropertyProvider), isNull);
    });
  });
}

ProviderContainer _container() => ProviderContainer();
