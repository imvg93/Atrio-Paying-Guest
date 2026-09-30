import 'package:atrio_pg/core/utils/money.dart';
import 'package:atrio_pg/features/auth/data/models/user.dart';
import 'package:atrio_pg/features/properties/data/models/room.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('formats paise as whole rupees', () {
      // CLAUDE.md 3.7: money crosses the wire as integer paise.
      expect(Money.format(850000), '₹8,500');
      expect(Money.format(0), '₹0');
    });

    test('uses Indian digit grouping', () {
      expect(Money.format(10000000), '₹1,00,000');
    });

    test('renders a rent range, collapsing equal bounds', () {
      expect(Money.range(800000, 1200000), '₹8,000 – ₹12,000');
      expect(Money.range(800000, 800000), '₹8,000');
      expect(Money.range(null, null), 'Price on request');
    });

    test('converts rupees back to paise without float drift', () {
      expect(Money.rupeesToPaise(8500), 850000);
      expect(Money.rupeesToPaise(8500.5), 850050);
    });
  });

  group('enum wire values', () {
    test('SharingType carries the bed defaults from sharing type', () {
      expect(SharingType.single.defaultBedCount, 1);
      expect(SharingType.double_.defaultBedCount, 2);
      expect(SharingType.triple.defaultBedCount, 3);
      expect(SharingType.fourPlus.defaultBedCount, 4);
    });
  });

  group('User', () {
    test('needsProfileCompletion needs both a name and a chosen role', () {
      const base =
          User(id: 'u1', phone: '+919876543210', role: UserRole.student);
      expect(base.needsProfileCompletion, isTrue);

      // A name alone is not enough: `role` is a provisional 'student' on every
      // new account, so only roleLocked says the user actually chose.
      expect(base.copyWith(name: 'Asha').needsProfileCompletion, isTrue);
      expect(base.copyWith(roleLocked: true).needsProfileCompletion, isTrue);

      expect(
        base.copyWith(name: 'Asha', roleLocked: true).needsProfileCompletion,
        isFalse,
      );
      expect(
        base.copyWith(name: '   ', roleLocked: true).needsProfileCompletion,
        isTrue,
      );
    });

    test('displayName falls back to the phone number', () {
      const base =
          User(id: 'u1', phone: '+919876543210', role: UserRole.student);
      expect(base.displayName, '+919876543210');
      expect(base.copyWith(name: 'Asha').displayName, 'Asha');
    });
  });
}
