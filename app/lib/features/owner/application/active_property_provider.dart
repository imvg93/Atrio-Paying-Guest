import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The property the Tenants, Rent and More tabs are scoped to.
///
/// Owner screens are almost all about *one* property — tenants of a PG, rent
/// for a PG, complaints at a PG. Rather than threading a property id through
/// every route, one selection lives here and those tabs read it.
///
/// Held as an id plus a display name rather than the full `Property` so that
/// changing the selection does not require the property to be loaded first, and
/// so the app bar can render immediately from cache.
class ActivePropertySelection {
  const ActivePropertySelection({required this.id, required this.name});

  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is ActivePropertySelection && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

/// Null until the owner has properties, or while they are still loading.
///
/// Set by the portfolio screen when the owner picks a property, and set
/// automatically when they have exactly one — in that case the switcher is
/// hidden entirely, because offering a choice of one is noise.
class ActiveProperty extends Notifier<ActivePropertySelection?> {
  @override
  ActivePropertySelection? build() => null;

  void select(ActivePropertySelection selection) => state = selection;

  /// Adopts the only property an owner has, if they have exactly one.
  /// A no-op otherwise, so it is safe to call on every portfolio load.
  void adoptIfSingle(List<ActivePropertySelection> properties) {
    if (properties.length == 1) {
      state = properties.single;
    }
  }

  /// Called when the selected property is deleted or the owner signs out.
  void clear() => state = null;
}

final activePropertyProvider =
    NotifierProvider<ActiveProperty, ActivePropertySelection?>(
  ActiveProperty.new,
);

// `ownerPropertyCountProvider` lives in owner_properties_controller.dart, next
// to the list it counts — this file is deliberately free of data dependencies
// so the selection can be read from anywhere without pulling in the portfolio.
