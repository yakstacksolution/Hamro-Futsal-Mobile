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

  final int amount;
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
