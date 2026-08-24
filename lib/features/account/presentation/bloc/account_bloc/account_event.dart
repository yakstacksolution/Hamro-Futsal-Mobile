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

/// Loads `/auth/settlement-breakdown`.
///
/// Deferred until the Futsal Breakdown screen is actually opened — it is the
/// only surface that needs the per-futsal balances, and paying for it on every
/// account load slowed the screen down for vendors who never open it.
final class LoadSettlementBreakdownEvent extends AccountEvent {
  const LoadSettlementBreakdownEvent({this.refresh = false});

  /// Refetches even when a breakdown is already held.
  final bool refresh;

  @override
  List<Object?> get props => <Object?>[refresh];
}

/// Loads `/auth/settlement-recent-activity`.
///
/// The account summary already carries a short preview of these rows, so the
/// full ledger is fetched only when the Account statement screen opens.
final class LoadRecentActivityEvent extends AccountEvent {
  const LoadRecentActivityEvent({this.loadMore = false, this.refresh = false});

  /// Appends the next page instead of replacing page 1.
  final bool loadMore;

  /// Refetches page 1 even when rows are already held.
  final bool refresh;

  @override
  List<Object?> get props => <Object?>[loadMore, refresh];
}
