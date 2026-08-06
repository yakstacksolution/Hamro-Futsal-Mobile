part of 'accept_request_bloc.dart';

enum AcceptRequestStatus { initial, loading, success, failure }

class AcceptRequestState extends Equatable {
  const AcceptRequestState({
    this.submitStatus = AcceptRequestStatus.initial,
    this.result,
    this.errorMessage,
    this.errorStatusCode = 0,
  });

  final AcceptRequestStatus submitStatus;

  /// The updated request returned by a successful acceptance.
  final OpponentRequestModel? result;

  final String? errorMessage;

  /// HTTP status of the last failure — 409 (settled with another team) and
  /// 410 (expired) get dedicated UI copy.
  final int errorStatusCode;

  AcceptRequestState copyWith({
    AcceptRequestStatus? submitStatus,
    OpponentRequestModel? result,
    String? errorMessage,
    int? errorStatusCode,
    bool clearError = false,
  }) => AcceptRequestState(
    submitStatus: submitStatus ?? this.submitStatus,
    result: result ?? this.result,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    errorStatusCode: clearError ? 0 : (errorStatusCode ?? this.errorStatusCode),
  );

  @override
  List<Object?> get props => [
    submitStatus,
    result,
    errorMessage,
    errorStatusCode,
  ];
}
