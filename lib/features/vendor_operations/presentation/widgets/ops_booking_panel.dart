import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/utils/date_format.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/bookings/data/model/candidate_model.dart';
import 'package:hamro_futsal/features/vendor_operations/data/manual_group_booking_service.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/bloc/vendor_ops_bloc.dart';

enum _Step { selection, details, review, result }

class OpsBookingPanel extends StatefulWidget {
  const OpsBookingPanel({
    super.key,
    required this.onClose,
    this.service,
    this.scrollController,
    this.inSheet = false,
  });

  final VoidCallback onClose;
  final ManualGroupBookingService? service;
  final ScrollController? scrollController;

  final bool inSheet;

  @override
  State<OpsBookingPanel> createState() => _OpsBookingPanelState();
}

class _OpsBookingPanelState extends State<OpsBookingPanel> {
  static const int _candidatePageSize = 20;

  late final ManualGroupBookingService _service =
      widget.service ?? ManualGroupBookingService();

  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _name = TextEditingController();

  final TextEditingController _note = TextEditingController();

  final List<_PaymentLineField> _payments = <_PaymentLineField>[
    _PaymentLineField(),
  ];
  static const int _maxPayments = 2;

  static String _otherMethod(String method) =>
      method == 'cash' ? 'online' : 'cash';

  _Step _step = _Step.selection;
  OpsBookingStatus _bookingStatus = OpsBookingStatus.confirmed;

  bool _busy = false;
  String? _error;
  List<CandidateModel> _candidates = const <CandidateModel>[];
  Timer? _candidateSearchDebounce;
  String _candidateSearch = '';
  int _candidatePage = 1;
  bool _candidatesLoading = false;
  bool _candidatesLoadingMore = false;
  bool _candidateHasMore = false;
  String? _candidateError;
  bool _showCandidatePicker = false;
  bool _applyingCandidate = false;

  bool _closing = false;

  String? _conflictKey;
  List<OpsRangeTicket> _tickets = const <OpsRangeTicket>[];
  bool _acceptedRevisedPrices = false;
  Timer? _holdTicker;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  @override
  void dispose() {
    _candidateSearchDebounce?.cancel();
    _holdTicker?.cancel();
    // Holds not turned into bookings are given back straight away rather
    // than left to expire — unless a booking is being created from them.
    if (_step == _Step.review && !_busy) {
      unawaited(_service.release(_tickets));
    }
    _phone.dispose();
    _name.dispose();
    _note.dispose();
    for (final _PaymentLineField p in _payments) {
      p.dispose();
    }
    super.dispose();
  }

  void _onCandidateSearchChanged(String value) {
    if (_applyingCandidate) return;
    setState(() => _showCandidatePicker = true);
    _candidateSearchDebounce?.cancel();
    _candidateSearchDebounce = Timer(const Duration(milliseconds: 350), () {
      final String search = _candidateQuery;
      if (search == _candidateSearch && _candidates.isNotEmpty) return;
      _loadCandidates(search: search);
    });
  }

  String get _candidateQuery {
    final String name = _name.text.trim();
    if (name.isNotEmpty) return name;
    return _phone.text.trim();
  }

  Future<void> _loadCandidates({String? search, bool loadMore = false}) async {
    final int page = loadMore ? _candidatePage + 1 : 1;
    final String querySearch = search ?? _candidateSearch;
    if (loadMore && (!_candidateHasMore || _candidatesLoadingMore)) return;
    setState(() {
      if (loadMore) {
        _candidatesLoadingMore = true;
      } else {
        _candidatesLoading = true;
        _candidateError = null;
      }
    });

    final Result response = await Client.instance()
        .getAuthManager()
        .getCandidates(
          query: <String, dynamic>{
            'page': page,
            'per_page': _candidatePageSize,
            if (querySearch.isNotEmpty) 'search': querySearch,
          },
        );
    if (!mounted) return;
    if (response.isError()) {
      final AppException error = ResponseHelper.error(response);
      setState(() {
        _candidatesLoading = false;
        _candidatesLoadingMore = false;
        _candidateError = error.errorMessage;
      });
      return;
    }

    try {
      final CandidatePage result = CandidatePage.fromResponse(
        response.getValue(),
      );
      setState(() {
        _candidateSearch = querySearch;
        _candidatePage = result.currentPage;
        _candidateHasMore = result.hasMorePages;
        _candidates = loadMore
            ? _mergeCandidates(_candidates, result.items)
            : result.items;
        _candidatesLoading = false;
        _candidatesLoadingMore = false;
        _candidateError = null;
      });
    } catch (_) {
      setState(() {
        _candidatesLoading = false;
        _candidatesLoadingMore = false;
        _candidateError = 'Could not read candidates from the server.';
      });
    }
  }

  List<CandidateModel> _mergeCandidates(
    List<CandidateModel> existing,
    List<CandidateModel> incoming,
  ) {
    final Map<String, CandidateModel> keyed = <String, CandidateModel>{
      for (final CandidateModel item in existing) _candidateKey(item): item,
      for (final CandidateModel item in incoming) _candidateKey(item): item,
    };
    return keyed.values.toList(growable: false);
  }

  String _candidateKey(CandidateModel candidate) {
    if (candidate.id > 0) return 'id:${candidate.id}';
    return '${candidate.name}|${candidate.phone}';
  }

  void _selectCandidate(CandidateModel candidate) {
    _applyingCandidate = true;
    _name.text = candidate.name;
    _phone.text = candidate.phone;
    _applyingCandidate = false;
    setState(() => _showCandidatePicker = false);
    FocusScope.of(context).unfocus();
  }

  // ───────────────────────────── Totals ─────────────────────────────

  double _estimateTotal(List<OpsBookingRange> ranges) => ranges.fold<double>(
    0,
    (double sum, OpsBookingRange r) => sum + (r.estimate ?? 0),
  );

  bool _hasUnpriced(List<OpsBookingRange> ranges) =>
      ranges.any((OpsBookingRange r) => r.estimate == null);

  double get _payable => _tickets.isEmpty
      ? 0
      : _tickets.fold<double>(
          0,
          (double sum, OpsRangeTicket t) => sum + (t.effectiveTotal ?? 0),
        );

  double get _received => _payments.fold<double>(
    0,
    (double sum, _PaymentLineField p) => sum + p.value,
  );

  OpsPaymentPlan _planFor(double total, {bool unpriced = false}) {
    final double r = _received;
    if (r <= 0) return OpsPaymentPlan.pending;
    if (!unpriced && total > 0 && r >= total - 0.5) return OpsPaymentPlan.full;
    return OpsPaymentPlan.partial;
  }

  OpsPayment get _payment => OpsPayment(
    lines: <OpsPaymentLine>[
      for (final MapEntry<String, double> e in <String, double>{
        for (final String m in <String>{
          for (final _PaymentLineField p in _payments) p.method,
        })
          m: _payments
              .where((_PaymentLineField p) => p.method == m)
              .fold<double>(0, (double s, _PaymentLineField p) => s + p.value),
      }.entries)
        if (e.value > 0) OpsPaymentLine(method: e.key, amount: e.value),
    ],
    bookingStatus: _bookingStatus,
    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
  );

  String get _methodsLabel {
    final List<String> used = <String>[
      for (final _PaymentLineField p in _payments)
        if (p.value > 0) _methodLabel(p.method),
    ];
    return used.isEmpty
        ? _methodLabel(_payments.first.method)
        : used.join(' + ');
  }

  static String _methodLabel(String method) =>
      method == 'online' ? 'Online' : 'Cash';

  void _addPayment(double total) {
    if (_payments.length >= _maxPayments) return;
    final _PaymentLineField line = _PaymentLineField(
      method: _otherMethod(_payments.first.method),
    );
    final double rest = total - _received;
    if (rest > 0) line.amount.text = rest.round().toString();
    setState(() => _payments.add(line));
  }

  void _removePayment(int index) {
    if (_payments.length <= 1) return;
    setState(() => _payments.removeAt(index).dispose());
  }

  void _fillShare(double total, double share) {
    final _PaymentLineField last = _payments.last;
    final double others = _received - last.value;
    final double amount = (total * share - others).clamp(0, double.infinity);
    setState(() => last.amount.text = amount.round().toString());
  }

  // ───────────────────────────── Actions ─────────────────────────────  // ───────────────────────────── Actions ─────────────────────────────

  Future<void> _review(List<OpsBookingRange> ranges) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
      _conflictKey = null;
    });
    final OpsPrepareOutcome outcome = await _service.prepare(ranges);
    if (!mounted) {
      unawaited(_service.release(outcome.tickets));
      return;
    }
    if (outcome.isConflict) {
      setState(() {
        _busy = false;
        _step = _Step.selection;
        final OpsBookingRange? conflict = outcome.conflict;
        _conflictKey = conflict?.key;
        _error = conflict == null
            ? '${outcome.message} Nothing was booked.'
            : '${conflict.courtName}, '
                  '${formatMinuteOfDay(conflict.start)}–'
                  '${formatMinuteOfDay(conflict.end)}: ${outcome.message} '
                  'Nothing was booked.';
      });
      context.read<VendorOpsBloc>().add(const VendorOpsRefreshed(silent: true));
      return;
    }
    setState(() {
      _busy = false;
      _tickets = outcome.tickets;
      _acceptedRevisedPrices = false;
      _step = _Step.review;
    });
    _holdTicker?.cancel();
    _holdTicker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => mounted ? setState(() {}) : null,
    );
  }

  Future<void> _backToDetails() async {
    _holdTicker?.cancel();
    final List<OpsRangeTicket> held = _tickets;
    setState(() {
      _tickets = const <OpsRangeTicket>[];
      _step = _Step.details;
      _error = null;
    });
    await _service.release(held);
  }

  String? _paymentProblem(double payable) {
    if (_payments.length > 1 &&
        _payments.any((_PaymentLineField p) => p.value <= 0)) {
      return 'Enter an amount for every payment, or remove it.';
    }
    final double r = _received;
    if (payable > 0 && r > payable + 0.5) {
      return 'Received (${Money.npr(r)}) is more than the payable total '
          '(${Money.npr(payable)}).';
    }
    return null;
  }

  Future<void> _confirm() async {
    if (_busy) return; // A second tap while confirming does nothing.
    final double payable = _payable;
    final String? problem = _paymentProblem(payable);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final List<OpsRangeTicket> result = await _service.confirm(
      tickets: _tickets,
      customer: OpsCustomer(name: _name.text.trim(), phone: _phone.text.trim()),
      payment: _payment,
    );
    if (!mounted) return;
    final bool allCreated = result.every((OpsRangeTicket t) => t.isCreated);
    final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
    setState(() {
      _busy = false;
      if (allCreated) {
        _tickets = result;
        _holdTicker?.cancel();
        _step = _Step.result;
      } else {
        // All or nothing: one message for the whole booking, not one per
        // slot. The slots stay held, so confirming again is safe.
        final String? reason = result
            .map((OpsRangeTicket t) => t.error)
            .whereType<String>()
            .firstOrNull;
        _tickets = <OpsRangeTicket>[
          for (final OpsRangeTicket t in result) t.copyWith(clearError: true),
        ];
        _error =
            'Nothing was booked${reason == null ? '.' : ': $reason'} '
            'The slots are still held — confirm again to retry.';
      }
    });
    if (allCreated) {
      bloc
        ..add(const VendorOpsSelectionCleared())
        ..add(const VendorOpsRefreshed(silent: true));
    } else {
      // Keep only what still needs booking in the selection.
      final Set<String> done = <String>{
        for (final OpsRangeTicket t in result.where((t) => t.isCreated))
          for (final OpsSelectionItem i in t.range.items) i.key,
      };
      if (done.isNotEmpty) {
        bloc
          ..add(VendorOpsSelectionRemoved(done))
          ..add(const VendorOpsRefreshed(silent: true));
      }
    }
  }

  bool get _holdingSlots =>
      _step == _Step.review && _tickets.any((OpsRangeTicket t) => !t.isCreated);

  Future<bool> _requestClose() async {
    if (_busy || _closing) return false;
    if (_holdingSlots) {
      final int held = _tickets
          .where((OpsRangeTicket t) => !t.isCreated)
          .length;
      final bool? release = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Release held slots?'),
          content: Text(
            held == 1
                ? 'The slot held for this booking goes back on sale. Your '
                      'selection is kept.'
                : 'The $held slots held for this booking go back on sale. '
                      'Your selection is kept.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep reviewing'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: LightColor.redColor),
              child: const Text('Release & close'),
            ),
          ],
        ),
      );
      if (release != true || !mounted || _busy || _closing) return false;
    }
    _closing = true;
    widget.onClose();
    return true;
  }

  Future<void> _clearAll(int count) async {
    final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
    if (count > 1) {
      final bool? clear = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Remove all $count slots?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: LightColor.redColor),
              child: const Text('Remove all'),
            ),
          ],
        ),
      );
      if (clear != true || !mounted) return;
    }
    setState(() => _conflictKey = null);
    bloc.add(const VendorOpsSelectionCleared());
  }

  void _startOver() {
    _phone.clear();
    _name.clear();
    _note.clear();
    setState(() {
      for (final _PaymentLineField p in _payments.skip(1)) {
        p.dispose();
      }
      _payments
        ..removeRange(1, _payments.length)
        ..first.method = 'cash'
        ..first.amount.clear();
      _tickets = const <OpsRangeTicket>[];
      _bookingStatus = OpsBookingStatus.confirmed;
      _step = _Step.selection;
      _error = null;
    });
  }

  // ───────────────────────────── Build ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOpsBloc, VendorOpsState>(
      buildWhen: (VendorOpsState a, VendorOpsState b) =>
          a.selection != b.selection || a.date != b.date,
      builder: (BuildContext context, VendorOpsState state) {
        final List<OpsBookingRange> ranges = state.ranges;
        // System back and a tap outside the sheet go through here: never
        // while booking, and only after asking while slots are held.
        return PopScope<Object?>(
          canPop: !_busy && !_holdingSlots,
          onPopInvokedWithResult: (bool didPop, _) {
            if (!didPop) unawaited(_requestClose());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _header(context, state),
              if (_error != null) _ErrorBanner(message: _error!),
              Expanded(
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: KeyedSubtree(
                      key: ValueKey<_Step>(_step),
                      child: switch (_step) {
                        _Step.selection => _selection(context, state, ranges),
                        _Step.details => _details(context, ranges),
                        _Step.review => _reviewView(context),
                        _Step.result => _resultView(context),
                      },
                    ),
                  ),
                ),
              ),
              _footer(context, state, ranges),
            ],
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, VendorOpsState state) {
    final textTheme = FutsalTheme.getTextTheme(context);
    const Map<_Step, String> titles = <_Step, String>{
      _Step.selection: 'Manual booking',
      _Step.details: 'Customer & payment',
      _Step.review: 'Review booking',
      _Step.result: 'Booking confirmed',
    };
    final int slots = state.selection.length;
    final int courts = state.selection.values
        .map((OpsSelectionItem i) => i.courtId)
        .toSet()
        .length;
    final String? subtitle = switch (_step) {
      _Step.result => null,
      _ when slots == 0 => 'Pick free slots on the board',
      _ =>
        '$slots ${slots == 1 ? 'slot' : 'slots'} · '
            '$courts ${courts == 1 ? 'court' : 'courts'}',
    };
    final bool canGoBack = _step == _Step.details || _step == _Step.review;
    return Container(
      padding: EdgeInsets.fromLTRB(8, widget.inSheet ? 12 : 8, 8, 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: LightColor.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (canGoBack)
                // The app's back button, as in [CustomAppBar].
                IconButton(
                  tooltip: 'Back',
                  visualDensity: VisualDensity.compact,
                  onPressed: _busy
                      ? null
                      : () => _step == _Step.review
                            ? _backToDetails()
                            : setState(() => _step = _Step.selection),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: LightColor.primaryTextColor,
                  ),
                )
              else
                const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      titles[_step]!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextLarge?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: LightColor.secondaryTextColor,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close panel',
                visualDensity: VisualDensity.compact,
                onPressed: _busy ? null : _requestClose,
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: LightColor.primaryTextColor,
                ),
              ),
            ],
          ),
          if (_step != _Step.result)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: _Stepper(step: _step.index),
            ),
        ],
      ),
    );
  }

  Widget _selection(
    BuildContext context,
    VendorOpsState state,
    List<OpsBookingRange> ranges,
  ) {
    final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!state.isToday)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton.icon(
              onPressed: () =>
                  bloc.add(VendorOpsDateChanged(KathmanduClock.today())),
              style: OutlinedButton.styleFrom(
                foregroundColor: LightColor.brandTextColor,
                minimumSize: const Size.fromHeight(42),
              ),
              icon: const Icon(Icons.today_rounded, size: 18),
              label: const Text('Book for today'),
            ),
          ),
        if (ranges.isEmpty)
          const _EmptySelection()
        else
          ..._groupedRanges(context, ranges),
      ],
    );
  }

  List<Widget> _groupedRanges(
    BuildContext context,
    List<OpsBookingRange> ranges,
  ) {
    final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
    // Insertion-ordered, so the board's order is kept.
    final Map<int, (String, Map<int, List<OpsBookingRange>>)> venues =
        <int, (String, Map<int, List<OpsBookingRange>>)>{};
    for (final OpsBookingRange r in ranges) {
      final (String, Map<int, List<OpsBookingRange>>) venue = venues
          .putIfAbsent(
            r.venueId,
            () => (r.venueName, <int, List<OpsBookingRange>>{}),
          );
      venue.$2.putIfAbsent(r.courtId, () => <OpsBookingRange>[]).add(r);
    }

    final List<Widget> out = <Widget>[];
    for (final (String venueName, Map<int, List<OpsBookingRange>> courts)
        in venues.values) {
      out.add(
        Padding(
          padding: EdgeInsets.only(top: out.isEmpty ? 0 : 8, bottom: 8),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.stadium_rounded,
                size: 15,
                color: LightColor.brandTextColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  venueName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: LightColor.primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      for (final List<OpsBookingRange> courtRanges in courts.values) {
        out.add(
          _CourtGroup(
            ranges: courtRanges,
            conflictKey: _conflictKey,
            onRemove: (OpsBookingRange r, OpsSelectionItem item) {
              if (_conflictKey == r.key) setState(() => _conflictKey = null);
              bloc.add(VendorOpsSelectionRemoved(<String>{item.key}));
            },
          ),
        );
      }
    }
    return out;
  }

  Widget _details(BuildContext context, List<OpsBookingRange> ranges) {
    final double estimate = _estimateTotal(ranges);
    final bool unpriced = _hasUnpriced(ranges);
    final double received = _received;
    final OpsPaymentPlan plan = _planFor(estimate, unpriced: unpriced);
    const SizedBox gap = SizedBox(height: AppDimens.paddingX16);
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SectionLabel('Customer'),
          const SizedBox(height: AppDimens.paddingX6),
          AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CustomTextField(
                  controller: _name,
                  labelText: 'Customer name',
                  hintText: 'Full name',
                  icon: Icons.person_rounded,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.name],
                  onChanged: _onCandidateSearchChanged,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  ensureVisibleOnFocus: true,
                  validator: (String? v) => (v?.trim().isEmpty ?? true)
                      ? 'Enter the customer\'s name'
                      : null,
                ),
                gap,
                CustomTextField(
                  controller: _phone,
                  labelText: 'Phone number',
                  hintText: '98XXXXXXXX',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.telephoneNumber],
                  onChanged: _onCandidateSearchChanged,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  ensureVisibleOnFocus: true,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    LengthLimitingTextInputFormatter(15),
                  ],
                  validator: (String? v) {
                    final String t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Enter the customer\'s phone number';
                    final String digits = t.replaceAll('+', '');
                    if (digits.length < 7) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                _candidatePicker(context),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.paddingX20),
          _SectionLabel('Payment'),
          const SizedBox(height: AppDimens.paddingX6),
          for (int i = 0; i < _payments.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: AppDimens.paddingX10),
            _PaymentLineRow(
              key: ValueKey<_PaymentLineField>(_payments[i]),
              line: _payments[i],
              // Split: each line is its method's, fixed — one cash, one
              // online.
              locked: _payments.length > 1,
              label: _payments.length == 1
                  ? 'Amount received (NPR)'
                  : '${_methodLabel(_payments[i].method)} received (NPR)',
              onMethodChanged: (String m) =>
                  setState(() => _payments[i].method = m),
              onAmountChanged: () => setState(() {}),
              onRemove: _payments.length > 1 ? () => _removePayment(i) : null,
              validator: (String? v) {
                final double r = double.tryParse(v?.trim() ?? '') ?? 0;
                if (_payments.length > 1 && r <= 0) {
                  return 'Enter an amount, or remove this payment';
                }
                // The total, once, under the last payment.
                if (i == _payments.length - 1 &&
                    !unpriced &&
                    estimate > 0 &&
                    received > estimate + 0.5) {
                  return 'More than the total (${Money.npr(estimate)})';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: AppDimens.paddingX8),
          Row(
            children: <Widget>[
              if (estimate > 0)
                for (final (String label, double share)
                    in const <(String, double)>[
                      ('25%', 0.25),
                      ('50%', 0.5),
                      ('Full', 1),
                    ]) ...<Widget>[
                  Expanded(
                    child: CustomButton(
                      text: label,
                      isOutlined: true,
                      foregroundColor: LightColor.brandTextColor,
                      borderColor: LightColor.dividerColor,
                      minWidth: 0,
                      minHeight: AppDimens.sizeX36,
                      verticalPadding: 0,
                      fontSize: AppDimens.fontBodyTextSmall,
                      onPressed: () => _fillShare(estimate, share),
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX8),
                ]
              else
                const Spacer(),
              // Part in cash, the rest online: the other method's line, for
              // what is still owed. Gone once both are there.
              if (_payments.length < _maxPayments)
                _AddPaymentButton(
                  label:
                      'Add ${_methodLabel(_otherMethod(_payments.first.method)).toLowerCase()}',
                  onPressed: () => _addPayment(estimate),
                ),
            ],
          ),
          gap,
          _PaymentStatusLine(
            key: const Key('ops-payment-status'),
            plan: plan,
            methods: received > 0 ? _methodsLabel : null,
          ),
          gap,
          CustomDropdownField<OpsBookingStatus>(
            key: const Key('ops-booking-status'),
            labelText: 'Booking status',
            icon: Icons.event_available_outlined,
            initialValue: _bookingStatus,
            isRequired: true,
            items: <DropdownMenuItem<OpsBookingStatus>>[
              for (final OpsBookingStatus b in OpsBookingStatus.values)
                DropdownMenuItem<OpsBookingStatus>(
                  value: b,
                  child: Text(b.label),
                ),
            ],
            onChanged: (OpsBookingStatus? v) {
              if (v != null) setState(() => _bookingStatus = v);
            },
          ),
          gap,
          CustomTextField(
            controller: _note,
            labelText: 'Payment note',
            hintText: 'Add a payment remark',
            isRequired: false,
            icon: Icons.notes_rounded,
            textCapitalization: TextCapitalization.sentences,
            ensureVisibleOnFocus: true,
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: AppDimens.paddingX16),
          _MoneyBox(
            rows: <(String, String, bool)>[
              (
                unpriced ? 'Subtotal (estimate, from)' : 'Subtotal (estimate)',
                Money.npr(estimate),
                false,
              ),
              ('Received', Money.npr(received), false),
              (
                'Remaining',
                Money.npr((estimate - received).clamp(0, double.infinity)),
                true,
              ),
            ],
            footnote:
                'Final prices come from the server when the slots are held '
                'on the next step.',
          ),
        ],
      ),
    );
  }

  Widget _candidatePicker(BuildContext context) {
    if (!_showCandidatePicker) return const SizedBox.shrink();
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingX10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          border: Border.all(
            color: _candidateError == null
                ? LightColor.dividerColor
                : LightColor.redColor.withValues(alpha: 0.7),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingX12,
                AppDimens.paddingX10,
                AppDimens.paddingX8,
                AppDimens.paddingX6,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.person_search_rounded,
                    size: AppDimens.sizeX18,
                    color: LightColor.brandTextColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX8),
                  Expanded(
                    child: Text(
                      'Existing candidates',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Hide candidates',
                    onPressed: () =>
                        setState(() => _showCandidatePicker = false),
                    icon: Icon(
                      Icons.close_rounded,
                      size: AppDimens.sizeX18,
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (_candidatesLoading)
              const Padding(
                padding: EdgeInsets.all(AppDimens.paddingX14),
                child: Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (_candidateError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.paddingX12,
                  AppDimens.paddingX4,
                  AppDimens.paddingX12,
                  AppDimens.paddingX12,
                ),
                child: Text(
                  _candidateError!,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.redColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (_candidates.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.paddingX12,
                  AppDimens.paddingX4,
                  AppDimens.paddingX12,
                  AppDimens.paddingX12,
                ),
                child: Text(
                  'No matching candidate. Continue with these details to create a new customer.',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    height: 1.3,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _candidates.length + (_candidateHasMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: LightColor.dividerColor),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= _candidates.length) {
                      return TextButton.icon(
                        onPressed: _candidatesLoadingMore
                            ? null
                            : () => _loadCandidates(loadMore: true),
                        style: TextButton.styleFrom(
                          foregroundColor: LightColor.brandTextColor,
                        ),
                        icon: _candidatesLoadingMore
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.expand_more_rounded),
                        label: const Text('Load more candidates'),
                      );
                    }
                    final CandidateModel candidate = _candidates[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 17,
                        backgroundColor: LightColor.secondaryLight,
                        child: Icon(
                          Icons.person_rounded,
                          size: AppDimens.sizeX18,
                          color: LightColor.brandTextColor,
                        ),
                      ),
                      title: Text(
                        candidate.name.isEmpty
                            ? 'Unnamed customer'
                            : candidate.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: candidate.phone.isEmpty
                          ? null
                          : Text(
                              candidate.phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyTextSmall?.copyWith(
                                color: LightColor.secondaryTextColor,
                              ),
                            ),
                      onTap: () => _selectCandidate(candidate),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _reviewView(BuildContext context) {
    final DateTime? expiry = _tickets
        .map((OpsRangeTicket t) => t.holdExpiresAt)
        .whereType<DateTime>()
        .fold<DateTime?>(
          null,
          (DateTime? min, DateTime e) =>
              min == null || e.isBefore(min) ? e : min,
        );
    final bool anyChanged = _tickets.any((OpsRangeTicket t) => t.priceChanged);
    final double payable = _payable;
    final double received = _received;
    final List<_PaymentLineField> paid = <_PaymentLineField>[
      for (final _PaymentLineField p in _payments)
        if (p.value > 0) p,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (expiry != null) _HoldCountdown(expiresAt: expiry),
        _SectionLabel('Slots'),
        for (final OpsRangeTicket t in _tickets) _TicketLine(ticket: t),
        if (anyChanged) ...<Widget>[
          const SizedBox(height: 8),
          // Material, not a coloured box: the tile paints its ink on the
          // nearest Material, and a coloured box in between would hide it.
          Material(
            color: LightColor.warningLightColor,
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: CheckboxListTile(
                value: _acceptedRevisedPrices,
                onChanged: (bool? v) =>
                    setState(() => _acceptedRevisedPrices = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: LightColor.warningColor,
                title: Text(
                  'The server priced some slots differently from the board. '
                  'I have reviewed the revised prices.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: LightColor.onWarningLightColor,
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _SectionLabel('Customer'),
        _InfoCard(
          lines: <(IconData, String, bool)>[
            (Icons.person_rounded, _name.text.trim(), true),
            (Icons.phone_rounded, _phone.text.trim(), false),
          ],
        ),
        const SizedBox(height: 14),
        _SectionLabel('Payment'),
        _InfoCard(
          lines: <(IconData, String, bool)>[
            (
              Icons.account_balance_wallet_outlined,
              'Payment method · $_methodsLabel',
              false,
            ),
            (
              Icons.verified_outlined,
              'Payment status · ${_planFor(payable).label}',
              false,
            ),
            (
              Icons.event_available_outlined,
              'Booking status · ${_bookingStatus.label}',
              false,
            ),
            if (_note.text.trim().isNotEmpty)
              (Icons.notes_rounded, _note.text.trim(), false),
          ],
        ),
        const SizedBox(height: 14),
        _MoneyBox(
          rows: <(String, String, bool)>[
            ('Payable', Money.npr(payable), true),
            if (paid.isEmpty)
              ('Received now', Money.npr(0), false)
            else
              for (final _PaymentLineField p in paid)
                (
                  'Received now (${_methodLabel(p.method)})',
                  Money.npr(p.value),
                  false,
                ),
            (
              'Remaining balance',
              Money.npr((payable - received).clamp(0, double.infinity)),
              false,
            ),
          ],
          footnote:
              'Source: Manual / Vendor. Discounts and fees are applied by the '
              'server where configured.',
        ),
      ],
    );
  }

  Widget _resultView(BuildContext context) {
    final double payable = _payable;
    // Paid up front with the booking, or recorded payment by payment.
    final OpsPayment payment = _payment;
    final double paid =
        payment.planFor(payable) == OpsPaymentPlan.full && !payment.isSplit
        ? payable
        : _tickets.fold<double>(
            0,
            (double s, OpsRangeTicket t) => s + t.paidNow,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: LightColor.greenLightColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 38,
              color: LightColor.successColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _tickets.length == 1
              ? 'Booked for ${_name.text.trim()}'
              : '${_tickets.length} bookings for ${_name.text.trim()}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: LightColor.primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          paid <= 0
              ? 'Payment pending · ${Money.npr(payable)} to collect'
              : paid >= payable
              ? 'Paid in full · $_methodsLabel'
              : '${Money.npr(paid)} paid · '
                    '${Money.npr(payable - paid)} to collect',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: LightColor.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        for (final OpsRangeTicket t in _tickets) _TicketLine(ticket: t),
        const SizedBox(height: 12),
        _MoneyBox(
          rows: <(String, String, bool)>[
            ('Total', Money.npr(payable), true),
            ('Paid', Money.npr(paid), false),
            (
              'Balance due',
              Money.npr((payable - paid).clamp(0, double.infinity)),
              false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _footer(
    BuildContext context,
    VendorOpsState state,
    List<OpsBookingRange> ranges,
  ) {
    final int minutes = state.selectedMinutes;
    final double estimate = _estimateTotal(ranges);
    final Widget summary = Text(
      '${state.selection.length} '
      '${state.selection.length == 1 ? 'slot' : 'slots'} · '
      '${formatHours(minutes)} court-h · '
      '${_hasUnpriced(ranges) ? 'from ' : ''}${Money.npr(estimate)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: LightColor.primaryTextColor,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
    );

    final Widget primary;
    final Widget secondary;
    switch (_step) {
      case _Step.selection:
        // The first step has nothing to go back to: Back leaves the booking,
        // as the close button does. The selection is kept on the board.
        secondary = _SecondaryButton(
          label: 'Back',
          icon: Icons.arrow_back_ios,
          onPressed: _busy ? null : _requestClose,
        );
        primary = _PrimaryButton(
          label: 'Continue',
          onPressed: ranges.isEmpty
              ? null
              : () => setState(() {
                  _step = _Step.details;
                  _error = null;
                }),
        );
      case _Step.details:
        secondary = _SecondaryButton(
          label: 'Back',
          icon: Icons.arrow_back_ios,
          onPressed: _busy
              ? null
              : () => setState(() {
                  _step = _Step.selection;
                  _error = null;
                }),
        );
        primary = _PrimaryButton(
          label: 'Hold slots & review',
          busy: _busy,
          onPressed: ranges.isEmpty ? null : () => _review(ranges),
        );
      case _Step.review:
        final bool blocked =
            _tickets.any((OpsRangeTicket t) => t.priceChanged) &&
            !_acceptedRevisedPrices;
        // All or nothing: nothing is booked until confirming succeeds, so
        // going back is always safe.
        secondary = _SecondaryButton(
          label: 'Back',
          icon: Icons.arrow_back_ios,
          onPressed: _busy ? null : _backToDetails,
        );
        primary = _PrimaryButton(
          label: 'Confirm booking',
          busy: _busy,
          onPressed: blocked ? null : _confirm,
        );
      case _Step.result:
        secondary = _SecondaryButton(label: 'Done', onPressed: _requestClose);
        primary = _PrimaryButton(label: 'New booking', onPressed: _startOver);
    }

    // The sheet is already lifted above the keyboard, and the keyboard covers
    // the home indicator — so while it is up, no safe-area gap, and no
    // summary line: the footer sits right on the keyboard.
    final bool keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        keyboardOpen ? 8 : 10,
        16,
        keyboardOpen ? 8 : 12 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        border: Border(top: BorderSide(color: LightColor.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!keyboardOpen &&
              (_step == _Step.selection || _step == _Step.details)) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(child: summary),
                if (_step == _Step.selection && state.selection.isNotEmpty)
                  TextButton(
                    onPressed: () => _clearAll(state.selection.length),
                    style: TextButton.styleFrom(
                      foregroundColor: LightColor.redColor,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Clear all'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          // Back and the step's action split the bar evenly, as in venue
          // onboarding's [VendorBottomActionBar].
          Row(
            children: <Widget>[
              Expanded(child: secondary),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(child: primary),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Pieces ─────────────────────────────

class _EmptySelection extends StatelessWidget {
  const _EmptySelection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: <Widget>[
          Icon(Icons.touch_app_rounded, size: 36, color: LightColor.iconGrey),
          const SizedBox(height: 10),
          Text(
            'Tap free slots on the board',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pick any mix of courts, venues and times. Separate times stay '
            'separate — the gap is never booked.',
            textAlign: TextAlign.center,
            style: TextStyle(color: LightColor.secondaryTextColor),
          ),
        ],
      ),
    );
  }
}

class _SelectionLine extends StatelessWidget {
  const _SelectionLine({
    required this.item,
    required this.onRemove,
    this.conflict = false,
  });

  final OpsSelectionItem item;
  final VoidCallback onRemove;
  final bool conflict;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      decoration: BoxDecoration(
        color: conflict ? LightColor.redLightColor : LightColor.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: conflict ? LightColor.redColor : LightColor.dividerColor,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${formatMinuteOfDay(item.start)} – '
                  '${formatMinuteOfDay(item.end)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDuration(item.minutes)} · '
                  '${item.price == null ? 'Priced on hold' : Money.npr(item.price!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove ${formatMinuteOfDay(item.start)}',
            onPressed: onRemove,
            icon: Icon(
              Icons.remove_circle_outline_rounded,
              color: LightColor.redColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketLine extends StatelessWidget {
  const _TicketLine({required this.ticket});

  final OpsRangeTicket ticket;

  @override
  Widget build(BuildContext context) {
    final OpsBookingRange r = ticket.range;
    final DateTime? date = DateTime.tryParse(r.date);
    final bool failed = !ticket.isCreated && ticket.error != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ticket.isCreated
            ? LightColor.greenLightColor
            : failed
            ? LightColor.redLightColor
            : LightColor.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            ticket.isCreated
                ? Icons.check_circle_rounded
                : failed
                ? Icons.error_rounded
                : Icons.lock_clock_rounded,
            size: 18,
            color: ticket.isCreated
                ? LightColor.successColor
                : failed
                ? LightColor.redColor
                : LightColor.brandTextColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${r.venueName} · ${r.courtName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                Text(
                  '${date == null ? r.date : DateFmt.date(date)} · '
                  '${formatMinuteOfDay(r.start)} – ${formatMinuteOfDay(r.end)} '
                  '(${formatDuration(r.minutes)}, ${r.items.length} '
                  '${r.items.length == 1 ? 'slot' : 'slots'})',
                  style: TextStyle(
                    fontSize: 12,
                    color: LightColor.secondaryTextColor,
                  ),
                ),
                if (ticket.isCreated && (ticket.bookingId ?? -1) > 0)
                  Text(
                    'Booking #${ticket.bookingId}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: LightColor.successColor,
                    ),
                  ),
                if (ticket.error != null)
                  Text(
                    ticket.error!,
                    style: TextStyle(fontSize: 12, color: LightColor.redColor),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                ticket.effectiveTotal == null
                    ? '—'
                    : Money.npr(ticket.effectiveTotal!),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: LightColor.primaryTextColor,
                ),
              ),
              if (ticket.priceChanged && r.estimate != null)
                Text(
                  'was ${Money.npr(r.estimate!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: LightColor.warningColor,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HoldCountdown extends StatelessWidget {
  const _HoldCountdown({required this.expiresAt});

  final DateTime expiresAt;

  @override
  Widget build(BuildContext context) {
    final Duration left = expiresAt.difference(DateTime.now());
    final bool expired = left.isNegative;
    final String text = expired
        ? 'Hold expired — confirming will recheck availability.'
        : 'Slots held for ${left.inMinutes}:'
              '${(left.inSeconds % 60).toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: expired
            ? LightColor.warningLightColor
            : LightColor.secondaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.lock_clock_rounded,
            size: 16,
            color: expired
                ? LightColor.warningColor
                : LightColor.brandTextColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: expired
                    ? LightColor.onWarningLightColor
                    : LightColor.brandTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: LightColor.redLightColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: LightColor.redColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: LightColor.onRedLightColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyBox extends StatelessWidget {
  const _MoneyBox({required this.rows, this.footnote});

  final List<(String, String, bool)> rows;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    const List<FontFeature> figures = <FontFeature>[
      FontFeature.tabularFigures(),
    ];
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final (String label, String value, bool strong) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      label,
                      style:
                          (strong
                                  ? textTheme.bodyTextMedium
                                  : textTheme.bodyTextSmall)
                              ?.copyWith(
                                fontWeight: strong
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: strong
                                    ? LightColor.primaryTextColor
                                    : LightColor.secondaryTextColor,
                              ),
                    ),
                  ),
                  Text(
                    value,
                    style:
                        (strong
                                ? textTheme.bodyTextLarge
                                : textTheme.bodyTextMedium)
                            ?.copyWith(
                              fontWeight: strong
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: LightColor.primaryTextColor,
                              fontFeatures: figures,
                            ),
                  ),
                ],
              ),
            ),
          if (footnote != null) ...<Widget>[
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              footnote!,
              style: textTheme.bodySubTitle?.copyWith(
                color: LightColor.hintTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentLineField {
  _PaymentLineField({this.method = 'cash'});

  String method;
  final TextEditingController amount = TextEditingController();

  double get value =>
      double.tryParse(amount.text.replaceAll(',', '').trim()) ?? 0;

  void dispose() => amount.dispose();
}

class _PaymentLineRow extends StatelessWidget {
  const _PaymentLineRow({
    super.key,
    required this.line,
    required this.label,
    required this.onMethodChanged,
    required this.onAmountChanged,
    required this.validator,
    this.locked = false,
    this.onRemove,
  });

  final _PaymentLineField line;
  final String label;

  final bool locked;
  final ValueChanged<String> onMethodChanged;
  final VoidCallback onAmountChanged;
  final FormFieldValidator<String> validator;

  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        locked
            ? _MethodChip(method: line.method)
            : _MethodToggle(value: line.method, onChanged: onMethodChanged),
        const SizedBox(width: AppDimens.paddingX8),
        Expanded(
          child: CustomTextField(
            controller: line.amount,
            labelText: label,
            hintText: '0',
            isRequired: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            ensureVisibleOnFocus: true,
            inputFormatters: <TextInputFormatter>[
              // Digits and at most one decimal point, so it always parses.
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: (_) => onAmountChanged(),
            validator: validator,
          ),
        ),
        if (onRemove != null)
          SizedBox(
            height: _MethodToggle.height,
            child: IconButton(
              tooltip: 'Remove this payment',
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: LightColor.secondaryTextColor,
              ),
            ),
          ),
      ],
    );
  }
}

class _MethodToggle extends StatelessWidget {
  const _MethodToggle({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const double height = 48;

  @override
  Widget build(BuildContext context) {
    Widget option(String method, String label, IconData icon) {
      final bool selected = method == value;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          label: 'Paid by $label',
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(method),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? LightColor.secondaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                // Shrinks rather than overflows with large text.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        icon,
                        size: 15,
                        color: selected
                            ? LightColor.onBrandSurface
                            : LightColor.secondaryTextColor,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? LightColor.onBrandSurface
                              : LightColor.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 112,
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          option('cash', 'Cash', Icons.payments_outlined),
          const SizedBox(width: 3),
          option('online', 'Online', Icons.qr_code_2_rounded),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    final bool cash = method == 'cash';
    final String label = cash ? 'Cash' : 'Online';
    return Semantics(
      label: 'Paid by $label',
      child: ExcludeSemantics(
        child: Container(
          width: 112,
          height: _MethodToggle.height,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: LightColor.secondaryColor.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                cash ? Icons.payments_outlined : Icons.qr_code_2_rounded,
                size: 16,
                color: LightColor.brandTextColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: LightColor.brandTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddPaymentButton extends StatelessWidget {
  const _AddPaymentButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: LightColor.brandTextColor,
        minimumSize: const Size(0, AppDimens.sizeX36),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PaymentStatusLine extends StatelessWidget {
  const _PaymentStatusLine({super.key, required this.plan, this.methods});

  final OpsPaymentPlan plan;

  final String? methods;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon) = switch (plan) {
      OpsPaymentPlan.full => (
        LightColor.greenLightColor,
        LightColor.onGreenLightColor,
        Icons.check_circle_rounded,
      ),
      OpsPaymentPlan.partial => (
        LightColor.warningLightColor,
        LightColor.onWarningLightColor,
        Icons.timelapse_rounded,
      ),
      OpsPaymentPlan.pending => (
        LightColor.sunkenColor,
        LightColor.secondaryTextColor,
        Icons.hourglass_empty_rounded,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(
            'Payment status',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              methods == null ? plan.label : '${plan.label} · $methods',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.paddingX8),
      child: Text(
        text.toUpperCase(),
        style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
          letterSpacing: 0.6,
          fontWeight: FontWeight.w800,
          color: LightColor.hintTextColor,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX46,
      child: CustomButton(
        text: label,
        isLoading: busy,
        onPressed: onPressed,
        minWidth: 0,
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.step});

  final int step;

  static const List<String> _labels = <String>['Slots', 'Customer', 'Review'];

  @override
  Widget build(BuildContext context) {
    Widget dot(int i) {
      final bool done = i < step;
      final bool current = i == step;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done || current
              ? LightColor.secondaryColor
              : LightColor.cardColor,
          border: Border.all(
            color: done || current
                ? LightColor.secondaryColor
                : LightColor.dividerColor,
            width: 1.5,
          ),
        ),
        child: done
            ? const Icon(
                Icons.check_rounded,
                size: 13,
                color: LightColor.onBrandSurface,
              )
            : Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: current
                      ? LightColor.onBrandSurface
                      : LightColor.secondaryTextColor,
                ),
              ),
      );
    }

    return Semantics(
      container: true,
      label: 'Step ${step + 1} of 3, ${_labels[step.clamp(0, 2)]}',
      child: ExcludeSemantics(
        child: Row(
          children: <Widget>[
            for (int i = 0; i < _labels.length; i++) ...<Widget>[
              dot(i),
              const SizedBox(width: 6),
              Text(
                _labels[i],
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: i == step ? FontWeight.w800 : FontWeight.w600,
                  color: i <= step
                      ? LightColor.primaryTextColor
                      : LightColor.hintTextColor,
                ),
              ),
              if (i < _labels.length - 1)
                Expanded(
                  child: Container(
                    height: 1.5,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: i < step
                        ? LightColor.secondaryColor
                        : LightColor.dividerColor,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CourtGroup extends StatelessWidget {
  const _CourtGroup({
    required this.ranges,
    required this.conflictKey,
    required this.onRemove,
  });

  final List<OpsBookingRange> ranges;
  final String? conflictKey;
  final void Function(OpsBookingRange range, OpsSelectionItem item) onRemove;

  @override
  Widget build(BuildContext context) {
    final List<OpsSelectionItem> items = <OpsSelectionItem>[
      for (final OpsBookingRange r in ranges) ...r.items,
    ];
    final bool unpriced = items.any((OpsSelectionItem i) => i.price == null);
    final double subtotal = items.fold<double>(
      0,
      (double s, OpsSelectionItem i) => s + (i.price ?? 0),
    );
    final String total = unpriced && subtotal == 0
        ? 'Priced on hold'
        : '${unpriced ? 'from ' : ''}${Money.npr(subtotal)}';
    final bool conflict = ranges.any(
      (OpsBookingRange r) => r.key == conflictKey,
    );

    final List<Widget> lines = <Widget>[];
    String? date;
    for (final OpsBookingRange r in ranges) {
      if (r.date != date) {
        date = r.date;
        final DateTime? d = DateTime.tryParse(r.date);
        lines.add(
          Padding(
            padding: EdgeInsets.only(top: lines.isEmpty ? 0 : 6, bottom: 6),
            child: Text(
              d == null
                  ? r.date
                  : KathmanduClock.isToday(d)
                  ? 'Today · ${DateFmt.date(d)}'
                  : DateFmt.date(d),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: LightColor.secondaryTextColor,
              ),
            ),
          ),
        );
      }
      for (final OpsSelectionItem item in r.items) {
        lines.add(
          _SelectionLine(
            item: item,
            conflict: conflictKey == r.key,
            onRemove: () => onRemove(r, item),
          ),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: conflict ? LightColor.redColor : LightColor.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    ranges.first.courtName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                ),
                Text(
                  '${items.length} ${items.length == 1 ? 'slot' : 'slots'} · '
                  '$total',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: LightColor.brandTextColor,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...lines,
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.lines});

  final List<(IconData, String, bool)> lines;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final (IconData icon, String text, bool strong) in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    icon,
                    size: AppDimens.sizeX16,
                    color: LightColor.iconGrey,
                  ),
                  const SizedBox(width: AppDimens.paddingX8),
                  Expanded(
                    child: Text(
                      text,
                      style:
                          (strong
                                  ? textTheme.bodyTextMedium
                                  : textTheme.bodyTextSmall)
                              ?.copyWith(
                                fontWeight: strong
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: strong
                                    ? LightColor.primaryTextColor
                                    : LightColor.secondaryTextColor,
                              ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color fg = onPressed == null
        ? LightColor.greyBorderColor
        : LightColor.primaryTextColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Ink(
          height: AppDimens.sizeX46,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX12),
          decoration: BoxDecoration(
            color: LightColor.whiteColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(color: LightColor.greyBorderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: AppDimens.sizeX16, color: fg),
                const SizedBox(width: AppDimens.sizeX8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(fontWeight: FontWeight.w600, color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
