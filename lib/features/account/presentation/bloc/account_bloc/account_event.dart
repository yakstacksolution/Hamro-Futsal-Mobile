part of 'account_bloc.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => const [];
}

final class LoadAccountEvent extends AccountEvent {
  const LoadAccountEvent({this.silent = false});

  final bool silent;

  @override
  List<Object?> get props => [silent];
}

final class LoadSettlementsEvent extends AccountEvent {
  const LoadSettlementsEvent({this.loadMore = false, this.refresh = false});

  final bool loadMore;
  final bool refresh;

  @override
  List<Object?> get props => [loadMore, refresh];
}

final class RequestSettlementEvent extends AccountEvent {
  const RequestSettlementEvent({
    required this.amount,
    required this.transactionReference,
    required this.paymentProof,
    this.venueId,
    this.note,
  });

  final double amount;
  final String transactionReference;
  final UploadAttachment paymentProof;
  final int? venueId;
  final String? note;

  @override
  List<Object?> get props => [
    amount,
    transactionReference,
    paymentProof,
    venueId,
    note,
  ];
}

final class LoadSettlementBreakdownEvent extends AccountEvent {
  const LoadSettlementBreakdownEvent({this.refresh = false});

  final bool refresh;

  @override
  List<Object?> get props => <Object?>[refresh];
}

final class LoadRecentActivityEvent extends AccountEvent {
  const LoadRecentActivityEvent({this.loadMore = false, this.refresh = false});

  final bool loadMore;

  final bool refresh;

  @override
  List<Object?> get props => <Object?>[loadMore, refresh];
}
