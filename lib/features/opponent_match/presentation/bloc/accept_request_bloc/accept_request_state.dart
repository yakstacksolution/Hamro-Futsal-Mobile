part of 'accept_request_bloc.dart';

enum AcceptRequestStatus { initial, loading, success, failure }

class AcceptRequestState extends Equatable {
  const AcceptRequestState({
    this.quoteStatus = AcceptRequestStatus.initial,
    this.submitStatus = AcceptRequestStatus.initial,
    this.quote,
    this.result,
    this.errorMessage,
    this.errorStatusCode = 0,
  });

  final AcceptRequestStatus quoteStatus;
  final AcceptRequestStatus submitStatus;

  /// The active accept hold + advance quote (step 2 of the flow).
  final OpponentAcceptQuoteModel? quote;

  /// The updated request returned by a successful accept submit.
  final OpponentRequestModel? result;

  final String? errorMessage;

  /// HTTP status of the last failure — 409 (taken by another team) and
  /// 410 (expired) get dedicated UI copy.
  final int errorStatusCode;

  AcceptRequestState copyWith({
    AcceptRequestStatus? quoteStatus,
    AcceptRequestStatus? submitStatus,
    OpponentAcceptQuoteModel? quote,
    OpponentRequestModel? result,
    String? errorMessage,
    int? errorStatusCode,
    bool clearQuote = false,
    bool clearError = false,
  }) => AcceptRequestState(
    quoteStatus: quoteStatus ?? this.quoteStatus,
    submitStatus: submitStatus ?? this.submitStatus,
    quote: clearQuote ? null : (quote ?? this.quote),
    result: result ?? this.result,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    errorStatusCode: clearError ? 0 : (errorStatusCode ?? this.errorStatusCode),
  );

  @override
  List<Object?> get props => [
    quoteStatus,
    submitStatus,
    quote,
    result,
    errorMessage,
    errorStatusCode,
  ];
}
