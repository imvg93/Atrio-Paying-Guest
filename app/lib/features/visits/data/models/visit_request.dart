import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_request.freezed.dart';
part 'visit_request.g.dart';

/// `visit_requests.preferred_slot`.
enum VisitSlot {
  @JsonValue('morning')
  morning,
  @JsonValue('afternoon')
  afternoon,
  @JsonValue('evening')
  evening;

  String get label => switch (this) {
        VisitSlot.morning => 'Morning',
        VisitSlot.afternoon => 'Afternoon',
        VisitSlot.evening => 'Evening',
      };

  String get timeRange => switch (this) {
        VisitSlot.morning => '8 AM – 12 PM',
        VisitSlot.afternoon => '12 PM – 4 PM',
        VisitSlot.evening => '4 PM – 8 PM',
      };
}

/// `visit_requests.status`.
enum VisitRequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('declined')
  declined,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled;

  String get label => switch (this) {
        VisitRequestStatus.pending => 'Pending',
        VisitRequestStatus.accepted => 'Accepted',
        VisitRequestStatus.declined => 'Declined',
        VisitRequestStatus.completed => 'Completed',
        VisitRequestStatus.cancelled => 'Cancelled',
      };

  /// Only a pending request can still be cancelled by the student.
  bool get isCancellable => this == VisitRequestStatus.pending;

  bool get isOpen =>
      this == VisitRequestStatus.pending || this == VisitRequestStatus.accepted;
}

@freezed
abstract class VisitRequest with _$VisitRequest {
  const factory VisitRequest({
    required String id,
    required String propertyId,
    required String studentId,
    required DateTime preferredDate,
    required VisitSlot preferredSlot,
    String? message,
    required VisitRequestStatus status,
    DateTime? respondedAt,
    DateTime? createdAt,

    /// Denormalized for list rendering so the client needn't fetch each
    /// property separately.
    String? propertyName,
    String? propertyLocality,
    String? propertyPhotoUrl,
    String? studentName,
    String? studentPhone,
  }) = _VisitRequest;

  factory VisitRequest.fromJson(Map<String, dynamic> json) =>
      _$VisitRequestFromJson(json);
}
