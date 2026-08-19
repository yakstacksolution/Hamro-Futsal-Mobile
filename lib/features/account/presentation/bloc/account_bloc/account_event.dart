part of 'account_bloc.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => const [];
}

/// Fetches summary + statement + settlements. [silent] keeps current data on
/// screen (pull-to-refresh / post-submit reconcile) instead of the loader.
final class LoadAccountEvent extends AccountEvent {
  const LoadAccountEvent({this.silent = false});

  final bool silent;

  @override
  List<Object?> get props => [silent];
}

/// Loads the next page of the settlement history, or the first page again
/// when [refresh] is set.
final class LoadSettlementsEvent extends AccountEvent {
  const LoadSettlementsEvent({this.loadMore = false, this.refresh = false});

  final bool loadMore;
  final bool refresh;

  @override
  List<Object?> get props => [loadMore, refresh];
}

/// Vendor asks the super admin to pay out [amount] from the balance.
/// [venueId] scopes the settlement to one futsal; null settles across all.
final class RequestSettlementEvent extends AccountEvent {
  const RequestSettlementEvent({
    required this.amount,
    required this.transactionReference,
    required this.paymentProofPath,
    this.venueId,
    this.note,
  });

  final double amount;
  final String transactionReference;
  final String paymentProofPath;
  final int? venueId;
  final String? note;

  @override
  List<Object?> get props => [
    amount,
    transactionReference,
    paymentProofPath,
    venueId,
    note,
  ];
}
