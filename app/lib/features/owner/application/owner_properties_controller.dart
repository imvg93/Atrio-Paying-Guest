import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/paginated.dart';
import '../../properties/data/models/property.dart';
import '../data/models/property_draft.dart';
import '../data/owner_property_repository.dart';
import 'active_property_provider.dart';

/// The owner's portfolio (H1). All list business logic lives here, never in a
/// widget (CLAUDE.md 7, Flutter rules).
///
/// Holds a [Paginated] rather than a bare list so "load more" can append
/// without losing the total, which the header renders.
class OwnerPropertiesController
    extends AsyncNotifier<Paginated<PropertySummary>> {
  PropertyStatus? _statusFilter;

  OwnerPropertyRepository get _repo =>
      ref.read(ownerPropertyRepositoryProvider);

  @override
  Future<Paginated<PropertySummary>> build() => _load(page: 1);

  PropertyStatus? get statusFilter => _statusFilter;

  Future<Paginated<PropertySummary>> _load({required int page}) async {
    final result = await _repo.list(page: page, status: _statusFilter);

    // An owner with exactly one property never sees the switcher, so the shell
    // needs the selection made for them before Home renders.
    if (page == 1) {
      ref.read(activePropertyProvider.notifier).adoptIfSingle(
            result.items
                .map((p) => ActivePropertySelection(id: p.id, name: p.name))
                .toList(growable: false),
          );
    }
    return result;
  }

  /// Pull to refresh. Keeps the current filter.
  ///
  /// Deliberately does *not* set [AsyncLoading] first. Doing so would drop the
  /// current page and blank the list behind a skeleton on every refresh and
  /// every filter change — the RefreshIndicator is already saying "working",
  /// and replacing content the owner is looking at is what makes a list screen
  /// feel cheap. On failure the error replaces the list, which is correct: a
  /// filter that could not be applied must not look applied.
  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _load(page: 1));
  }

  /// Appends the next page. A no-op at the end of the list, and never replaces
  /// the visible list with a spinner — the screen keeps showing what it has.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || state.isLoading) return;

    final next = await _repo.list(page: current.nextPage, status: _statusFilter);
    state = AsyncData(current.merge(next));
  }

  Future<void> setStatusFilter(PropertyStatus? status) async {
    if (status == _statusFilter) return;
    _statusFilter = status;
    await refresh();
  }

  // ---- writes -------------------------------------------------------
  //
  // Each one refetches page 1 rather than patching the local list: the card
  // carries server-computed occupancy and rent range, so a locally-assembled
  // entry would be a guess at values only the server can produce.

  Future<Property> create(PropertyDraft draft) async {
    final created = await _repo.create(draft);
    await refresh();
    return created;
  }

  Future<Property> updateStatus(String id, PropertyStatus status) async {
    final updated = await _repo.updateStatus(id, status);
    await refresh();
    return updated;
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);

    // The Tenants, Rent and More tabs are scoped to the active property; if it
    // was this one they would keep querying a property that no longer exists.
    //
    // Clearing is not the end of it: the refetch below re-runs adoptIfSingle,
    // so an owner left with exactly one property lands on that one instead of
    // on nothing. Only deleting the last property leaves the selection null.
    if (ref.read(activePropertyProvider)?.id == id) {
      ref.read(activePropertyProvider.notifier).clear();
    }
    await refresh();
  }
}

final ownerPropertiesProvider = AsyncNotifierProvider<OwnerPropertiesController,
    Paginated<PropertySummary>>(OwnerPropertiesController.new);

/// How many properties the owner has, which decides whether the app-bar
/// switcher appears at all.
///
/// Reads `total` rather than counting loaded items: the list is paginated, so
/// `items.length` is a page size, not a portfolio size. Zero while the list is
/// loading or has failed, which keeps the switcher hidden rather than showing
/// an empty sheet.
final ownerPropertyCountProvider = Provider<int>((ref) {
  return ref.watch(ownerPropertiesProvider).value?.total ?? 0;
});

/// One property in full (H2, H3 edit, H11).
///
/// A family rather than a single provider because the shell can hold several
/// properties in play at once — the active one plus whichever the portfolio
/// list was last scrolled to.
final ownerPropertyProvider =
    FutureProvider.family<Property, String>((ref, id) {
  return ref.watch(ownerPropertyRepositoryProvider).get(id);
});

/// Edits one property, then invalidates both the detail and the list so the
/// card's occupancy and rent range are re-read rather than inferred.
class OwnerPropertyEditor {
  OwnerPropertyEditor(this._ref);

  final Ref _ref;

  Future<Property> save({
    required Property original,
    required PropertyDraft draft,
  }) async {
    final updated = await _ref
        .read(ownerPropertyRepositoryProvider)
        .update(original: original, draft: draft);

    _ref.invalidate(ownerPropertyProvider(original.id));
    _ref.invalidate(ownerPropertiesProvider);

    // The app-bar switcher shows the name, so a rename must reach it.
    final active = _ref.read(activePropertyProvider);
    if (active?.id == updated.id && active?.name != updated.name) {
      _ref.read(activePropertyProvider.notifier).select(
            ActivePropertySelection(id: updated.id, name: updated.name),
          );
    }
    return updated;
  }
}

final ownerPropertyEditorProvider = Provider<OwnerPropertyEditor>((ref) {
  return OwnerPropertyEditor(ref);
});
