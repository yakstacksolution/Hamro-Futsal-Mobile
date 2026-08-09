import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_shared_widgets.dart';
import 'package:hamro_footsall/features/transactions/domain/model/booking_transaction.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({
    super.key,
    required this.perspective,
    this.repository,
  });

  final TransactionPerspective perspective;
  final BookingRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookingBloc>(
      create: (_) {
        final BookingBloc bloc = BookingBloc(
          GetBookingsUseCase(repository ?? BookingRepositoryImpl()),
        );
        if (perspective == TransactionPerspective.futsal) {
          bloc.add(const FetchFutsalBookingsEvent());
        } else {
          bloc.add(const FetchMyBookingsEvent());
        }
        return bloc;
      },
      child: _TransactionHistoryView(perspective: perspective),
    );
  }
}

class _TransactionHistoryView extends StatefulWidget {
  const _TransactionHistoryView({required this.perspective});

  final TransactionPerspective perspective;

  @override
  State<_TransactionHistoryView> createState() =>
      _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<_TransactionHistoryView> {
  final TextEditingController _searchController = TextEditingController();
  TransactionStatus? _selectedStatus;

  bool get _isFutsal => widget.perspective == TransactionPerspective.futsal;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchTransactions() {
    final BookingBloc bloc = context.read<BookingBloc>();
    if (_isFutsal) {
      bloc.add(const FetchFutsalBookingsEvent());
    } else {
      bloc.add(const FetchMyBookingsEvent());
    }
  }

  Future<void> _refreshTransactions() async {
    _fetchTransactions();
    final BookingBloc bloc = context.read<BookingBloc>();
    await bloc.stream.firstWhere((BookingState state) {
      final BookingLoadStatus status = _isFutsal
          ? state.futsalBookingsStatus
          : state.myBookingsStatus;
      return status == BookingLoadStatus.success ||
          status == BookingLoadStatus.failure;
    });
  }

  void _openBookingDetails(BookingTransaction transaction) {
    context.pushNamed(
      AppRouterParams.bookingDetails.name,
      extra: transaction.booking,
      queryParameters: <String, String>{'futsal': _isFutsal.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: StringConstants.transactionHistory),
      body: SafeArea(
        top: false,
        child: BlocBuilder<BookingBloc, BookingState>(
          builder: (BuildContext context, BookingState state) {
            final BookingLoadStatus loadStatus = _isFutsal
                ? state.futsalBookingsStatus
                : state.myBookingsStatus;
            final List<BookingModel> bookings = _isFutsal
                ? state.futsalBookings
                : state.myBookings;
            final String? error = _isFutsal
                ? state.futsalBookingsError
                : state.myBookingsError;

            if (loadStatus == BookingLoadStatus.loading && bookings.isEmpty) {
              return const BookingSkeletonLoader();
            }
            if (loadStatus == BookingLoadStatus.failure && bookings.isEmpty) {
              return BookingErrorView(
                message: error ?? StringConstants.somethingWentWrong,
                onRetry: _fetchTransactions,
              );
            }

            final List<BookingTransaction> transactions =
                bookings
                    .map(
                      (BookingModel booking) => BookingTransaction.fromBooking(
                        booking,
                        perspective: widget.perspective,
                      ),
                    )
                    .toList(growable: false)
                  ..sort(
                    (BookingTransaction left, BookingTransaction right) =>
                        right.bookingDate.compareTo(left.bookingDate),
                  );

            return _buildHistory(transactions);
          },
        ),
      ),
    );
  }

  Widget _buildHistory(List<BookingTransaction> transactions) {
    final List<BookingTransaction> filteredTransactions = transactions
        .where(_matchesActiveFilters)
        .toList(growable: false);
    final Map<String, List<BookingTransaction>> groupedTransactions =
        _groupByMonth(filteredTransactions);

    return RefreshIndicator(
      color: LightColor.secondaryColor,
      onRefresh: _refreshTransactions,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.paddingX20,
          AppDimens.paddingX8,
          AppDimens.paddingX20,
          AppDimens.paddingX32,
        ),
        children: <Widget>[
          _TransactionSummary(
            transactions: transactions,
            perspective: widget.perspective,
          ),
          const SizedBox(height: AppDimens.sizeX18),
          _TransactionSearchField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            onClear: () {
              _searchController.clear();
              setState(() {});
            },
          ),
          const SizedBox(height: AppDimens.sizeX12),
          _TransactionStatusFilters(
            selectedStatus: _selectedStatus,
            onChanged: (TransactionStatus? status) {
              setState(() => _selectedStatus = status);
            },
          ),
          const SizedBox(height: AppDimens.sizeX22),
          if (transactions.isEmpty)
            const _TransactionEmptyState(hasActiveFilters: false)
          else if (filteredTransactions.isEmpty)
            const _TransactionEmptyState(hasActiveFilters: true)
          else
            for (final MapEntry<String, List<BookingTransaction>> group
                in groupedTransactions.entries) ...<Widget>[
              _TransactionMonthSection(
                title: group.key,
                transactions: group.value,
                onTransactionTap: _openBookingDetails,
              ),
              const SizedBox(height: AppDimens.sizeX22),
            ],
        ],
      ),
    );
  }

  bool _matchesActiveFilters(BookingTransaction transaction) {
    if (_selectedStatus != null && transaction.status != _selectedStatus) {
      return false;
    }
    final String query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return <String?>[
      transaction.reference,
      transaction.counterparty,
      transaction.courtName,
      transaction.paymentMethod,
      transaction.booking.paymentStatus,
    ].any((String? value) => value?.toLowerCase().contains(query) == true);
  }

  Map<String, List<BookingTransaction>> _groupByMonth(
    List<BookingTransaction> transactions,
  ) {
    final DateFormat monthFormat = DateFormat('MMMM yyyy');
    final Map<String, List<BookingTransaction>> grouped =
        <String, List<BookingTransaction>>{};
    for (final BookingTransaction transaction in transactions) {
      final String month = monthFormat.format(transaction.bookingDate);
      grouped.putIfAbsent(month, () => <BookingTransaction>[]).add(transaction);
    }
    return grouped;
  }
}

class _TransactionSummary extends StatelessWidget {
  const _TransactionSummary({
    required this.transactions,
    required this.perspective,
  });

  final List<BookingTransaction> transactions;
  final TransactionPerspective perspective;

  @override
  Widget build(BuildContext context) {
    final bool isFutsal = perspective == TransactionPerspective.futsal;
    final double paidAmount = _sumForStatus(TransactionStatus.paid);
    final double pendingAmount = _sumForStatus(TransactionStatus.pending);
    final double refundedAmount = _sumForStatus(TransactionStatus.refunded);
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX18),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX18),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: AppDimens.radiusX18,
            offset: Offset(0, AppDimens.sizeX8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX46,
                height: AppDimens.sizeX46,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX14),
                ),
                child: Icon(
                  isFutsal
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: LightColor.secondaryColor,
                  size: AppDimens.sizeX22,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isFutsal
                          ? StringConstants.futsalEarnings
                          : StringConstants.playerPayments,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      isFutsal
                          ? StringConstants.moneyReceivedFromBookings
                          : StringConstants.moneyPaidForBookings,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX20),
          Text(
            isFutsal
                ? StringConstants.totalEarnings
                : StringConstants.totalSpent,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX4),
          Text(
            _formatCurrency(paidAmount),
            style: textTheme.headingXSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX18),
          const Divider(height: AppDimens.sizeX1),
          const SizedBox(height: AppDimens.sizeX14),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryMetric(
                  label: StringConstants.pendingAmount,
                  value: _formatCurrency(pendingAmount),
                  color: LightColor.warningColor,
                ),
              ),
              Container(
                width: AppDimens.sizeX1,
                height: AppDimens.sizeX36,
                color: LightColor.dividerColor,
              ),
              Expanded(
                child: _SummaryMetric(
                  label: StringConstants.refunds,
                  value: _formatCurrency(refundedAmount),
                  color: LightColor.purpleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _sumForStatus(TransactionStatus status) {
    return transactions
        .where((BookingTransaction transaction) => transaction.status == status)
        .fold<double>(
          0,
          (double total, BookingTransaction transaction) =>
              total + transaction.amount,
        );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionSearchField extends StatelessWidget {
  const _TransactionSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: StringConstants.searchTransactions,
        prefixIcon: Icon(
          Icons.search_rounded,
          color: LightColor.secondaryTextColor,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  color: LightColor.secondaryTextColor,
                ),
              ),
        filled: true,
        fillColor: LightColor.cardColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDimens.paddingX12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX14),
          borderSide: BorderSide(color: LightColor.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX14),
          borderSide: BorderSide(color: LightColor.dividerColor),
        ),
      ),
    );
  }
}

class _TransactionStatusFilters extends StatelessWidget {
  const _TransactionStatusFilters({
    required this.selectedStatus,
    required this.onChanged,
  });

  final TransactionStatus? selectedStatus;
  final ValueChanged<TransactionStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    const List<TransactionStatus?> filters = <TransactionStatus?>[
      null,
      TransactionStatus.paid,
      TransactionStatus.pending,
      TransactionStatus.refunded,
      TransactionStatus.cancelled,
    ];

    return SizedBox(
      height: AppDimens.sizeX36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.sizeX8),
        itemBuilder: (BuildContext context, int index) {
          final TransactionStatus? status = filters[index];
          final bool selected = status == selectedStatus;
          return ChoiceChip(
            label: Text(_statusLabel(status)),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => onChanged(status),
            backgroundColor: LightColor.cardColor,
            selectedColor: LightColor.secondaryColor.withValues(alpha: 0.12),
            side: BorderSide(
              color: selected
                  ? LightColor.secondaryColor.withValues(alpha: 0.28)
                  : LightColor.dividerColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            ),
            labelStyle: FutsalTheme.getTextTheme(context).bodyTextSmall
                ?.copyWith(
                  color: selected
                      ? LightColor.secondaryColor
                      : LightColor.secondaryTextColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX8,
            ),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

class _TransactionMonthSection extends StatelessWidget {
  const _TransactionMonthSection({
    required this.title,
    required this.transactions,
    required this.onTransactionTap,
  });

  final String title;
  final List<BookingTransaction> transactions;
  final ValueChanged<BookingTransaction> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: AppDimens.paddingX4,
            bottom: AppDimens.paddingX10,
          ),
          child: Text(
            title,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX16),
            border: Border.all(color: LightColor.dividerColor),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: AppDimens.radiusX14,
                offset: Offset(0, AppDimens.sizeX6),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              for (int index = 0; index < transactions.length; index++) ...[
                _TransactionTile(
                  transaction: transactions[index],
                  onTap: () => onTransactionTap(transactions[index]),
                ),
                if (index < transactions.length - 1)
                  Divider(
                    height: AppDimens.sizeX1,
                    thickness: AppDimens.sizeX1,
                    indent: AppDimens.sizeX72,
                    color: LightColor.dividerColor,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.onTap});

  final BookingTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color statusColor = _statusColor(transaction.status);
    final String counterparty = transaction.counterparty.isEmpty
        ? transaction.perspective == TransactionPerspective.futsal
              ? StringConstants.players
              : StringConstants.futsal
        : transaction.counterparty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingX14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: AppDimens.sizeX44,
                height: AppDimens.sizeX44,
                decoration: BoxDecoration(
                  color:
                      (transaction.isCredit
                              ? LightColor.secondaryColor
                              : LightColor.blueColor)
                          .withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  transaction.isCredit
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: transaction.isCredit
                      ? LightColor.secondaryColor
                      : LightColor.blueColor,
                  size: AppDimens.sizeX20,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            counterparty,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyTextMedium?.copyWith(
                              color: LightColor.primaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.sizeX10),
                        Text(
                          '${transaction.isCredit ? '+' : '-'}${_formatCurrency(transaction.amount)}',
                          style: textTheme.bodyTextMedium?.copyWith(
                            color: transaction.isCredit
                                ? LightColor.secondaryColor
                                : LightColor.primaryTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.sizeX4),
                    Text(
                      <String>[
                        transaction.reference,
                        if (transaction.courtName.isNotEmpty)
                          transaction.courtName,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX8),
                    Wrap(
                      spacing: AppDimens.sizeX8,
                      runSpacing: AppDimens.sizeX6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        _TransactionStatusChip(
                          label: _statusLabel(transaction.status),
                          color: statusColor,
                        ),
                        Text(
                          _transactionDateLabel(transaction),
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.hintTextColor,
                            fontSize: AppDimens.fontBodySubTitle,
                          ),
                        ),
                        if (transaction.paymentMethod != null)
                          Text(
                            '${StringConstants.paidVia} ${transaction.paymentMethod}',
                            style: textTheme.bodyTextSmall?.copyWith(
                              color: LightColor.hintTextColor,
                              fontSize: AppDimens.fontBodySubTitle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionStatusChip extends StatelessWidget {
  const _TransactionStatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX8,
        vertical: AppDimens.paddingX2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        label,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: color,
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TransactionEmptyState extends StatelessWidget {
  const _TransactionEmptyState({required this.hasActiveFilters});

  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX48),
      child: Column(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX80,
            height: AppDimens.sizeX80,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX36,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX16),
          Text(
            hasActiveFilters
                ? StringConstants.noTransactionsFound
                : StringConstants.noTransactionsYet,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX6),
          Text(
            hasActiveFilters
                ? StringConstants.tryAdjustingOrClearingYourFilters
                : StringConstants.bookingPaymentsWillAppearHere,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double amount) {
  final NumberFormat formatter = NumberFormat('#,##0', 'en_US');
  return '${StringConstants.npr} ${formatter.format(amount)}';
}

String _transactionDateLabel(BookingTransaction transaction) {
  final String date = DateFormat('dd MMM yyyy').format(transaction.bookingDate);
  final String time = transaction.booking.displayTimeRange;
  return time.isEmpty ? date : '$date · $time';
}

String _statusLabel(TransactionStatus? status) => switch (status) {
  null => StringConstants.all,
  TransactionStatus.paid => StringConstants.paid,
  TransactionStatus.pending => StringConstants.pending,
  TransactionStatus.refunded => StringConstants.refunded,
  TransactionStatus.cancelled => StringConstants.cancelled,
};

Color _statusColor(TransactionStatus status) => switch (status) {
  TransactionStatus.paid => LightColor.secondaryColor,
  TransactionStatus.pending => LightColor.warningColor,
  TransactionStatus.refunded => LightColor.purpleColor,
  TransactionStatus.cancelled => LightColor.redColor,
};
