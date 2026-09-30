/// The list payload every paginated endpoint returns (CLAUDE.md 3.11):
/// ```json
/// { "items": [...], "page": 1, "limit": 20, "total": 137 }
/// ```
///
/// Written by hand rather than generated: freezed's generic `fromJson` needs a
/// per-call converter anyway, so codegen would buy nothing here.
class Paginated<T> {
  const Paginated({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawItems = (json['items'] as List<dynamic>? ?? const <dynamic>[]);
    return Paginated<T>(
      items: rawItems
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(growable: false),
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? rawItems.length,
      total: json['total'] as int? ?? rawItems.length,
    );
  }

  const Paginated.empty()
      : items = const [],
        page = 1,
        limit = 20,
        total = 0;

  bool get isEmpty => items.isEmpty;

  /// True when at least one more page exists after this one.
  bool get hasMore => page * limit < total;

  int get nextPage => page + 1;

  Paginated<T> merge(Paginated<T> next) => Paginated<T>(
        items: [...items, ...next.items],
        page: next.page,
        limit: next.limit,
        total: next.total,
      );
}
