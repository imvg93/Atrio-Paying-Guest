import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state_views.dart';

/// Renders an [AsyncValue] with all four states handled in one place, so no
/// screen can accidentally forget one.
///
/// ```dart
/// AsyncValueView<List<Property>>(
///   value: ref.watch(myProvider),
///   onRetry: () => ref.invalidate(myProvider),
///   isEmpty: (list) => list.isEmpty,
///   emptyMessage: 'No PGs match your filters.',
///   data: (list) => ListView(...),
/// )
/// ```
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.isEmpty,
    this.emptyMessage,
    this.emptyTitle,
    this.loadingMessage,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  /// Lets the caller decide what "empty" means for its own type.
  final bool Function(T data)? isEmpty;
  final String? emptyMessage;
  final String? emptyTitle;
  final String? loadingMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => AppLoadingView(message: loadingMessage),
      error: (error, _) => AppErrorView(error: error, onRetry: onRetry),
      data: (value) {
        if (isEmpty != null && isEmpty!(value)) {
          return AppEmptyView(
            title: emptyTitle,
            message: emptyMessage ?? 'Nothing here yet.',
          );
        }
        return data(value);
      },
    );
  }
}
