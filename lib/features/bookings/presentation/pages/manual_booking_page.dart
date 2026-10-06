import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/app_message_view.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/core/widgets/loading_widget.dart';
import 'package:hamro_futsal/features/bookings/data/model/candidate_model.dart';
import 'package:hamro_futsal/features/bookings/data/model/manual_booking_details.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_futsal/features/courts/data/repositories/venue_court_repository_impl.dart';
import 'package:hamro_futsal/features/courts/domain/model/venue_court_purpose.dart';
import 'package:hamro_futsal/features/courts/domain/usecase/get_venue_court_use_case.dart';
import 'package:hamro_futsal/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/slots_selection_route_args.dart';

class ManualBookingPage extends StatefulWidget {
  const ManualBookingPage({super.key});

  @override
  State<ManualBookingPage> createState() => _ManualBookingPageState();
}

class _ManualBookingPageState extends State<ManualBookingPage> {
  static const int _candidatePageSize = 20;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _note = TextEditingController(
    text: 'Paid at counter',
  );

  final TextEditingController _totalAmount = TextEditingController();

  List<VenueCourtModel> _venues = const <VenueCourtModel>[];
  VenueCourtModel? _venue;
  bool _loading = true;
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
  String _paymentMethod = 'cash';
  String _paymentStatus = 'paid';
  String _bookingStatus = 'confirmed';

  @override
  void initState() {
    super.initState();
    _loadVenues();
    _loadCandidates();
  }

  Future<void> _loadVenues() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final Either<AppException, List<VenueCourtModel>> result =
        await GetVenueCourtUseCase(
          VenueCourtRepositoryImpl(),
        ).getAllVenueCourts(
          // A walk-in is a booking being taken now, so this asks for the
          // bookable venues and courts rather than the whole portfolio.
          purpose: VenueCourtPurpose.booking,
        );
    if (!mounted) return;
    result.fold(
      (AppException error) => setState(() {
        _loading = false;
        _error = error.errorMessage;
      }),
      (List<VenueCourtModel> venues) => setState(() {
        _loading = false;
        _venues = venues
            .where((VenueCourtModel item) => item.id != null)
            .toList();
        _venue = _venues.length == 1 ? _venues.first : null;
      }),
    );
  }

  @override
  void dispose() {
    _candidateSearchDebounce?.cancel();
    _name.dispose();
    _phone.dispose();
    _totalAmount.dispose();
    _note.dispose();
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

  Future<void> _continue() async {
    if (!(_formKey.currentState?.validate() ?? false) || _venue == null) return;
    final VenueCourtModel venue = _venue!;
    final bool? booked = await context.pushNamed<bool>(
      AppRouterParams.slotsSelection.name,
      extra: SlotsSelectionRouteArgs(
        court: CourtDetailModel(
          venueId: venue.id,
          venueSlug: venue.slug,
          name: venue.title,
          location: venue.address,
          address: venue.address,
          price: '',
          rating: 0,
          reviewCount: 0,
          images: venue.imageUrl == null
              ? const <String>[]
              : <String>[venue.imageUrl!],
          isOpen: venue.isActive,
          distance: '',
          features: const <String>[],
          description: '',
          hostedByName: '',
          hostedByAvatar: '',
          hostedSince: '',
          hostedCourts: venue.courts.length,
          responseRate: 0,
          policies: const <String>[],
          rules: const <String>[],
          reviews: const <ReviewModel>[],
          openTime: '',
          closeTime: '',
          courtType: '',
          surfaceType: '',
          maxPlayers: 0,
        ),
        manualBooking: ManualBookingDetails(
          customerName: _name.text.trim(),
          customerPhone: _phone.text.trim(),
          totalAmount: _parsedTotalAmount,
          paymentMethod: _paymentMethod,
          paymentType: _paymentMethod,
          paymentStatus: _paymentStatus,
          bookingStatus: _bookingStatus,
          paymentNote: _note.text.trim(),
        ),
      ),
    );
    if (booked == true && mounted) Navigator.of(context).pop(true);
  }

  double? get _parsedTotalAmount {
    final String raw = _totalAmount.text.trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  String? _optionalAmount(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;
    final double? amount = double.tryParse(raw);
    if (amount == null) return 'Enter an amount like 1200 or 1200.50.';
    if (amount <= 0) return 'Enter an amount greater than zero.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Manual booking & adjustments'),
      bottomNavigationBar: _loading || _error != null || _venues.isEmpty
          ? null
          : _ManualBookingActionBar(onContinue: _continue),
      body: _loading
          // The app's loader, as on venue onboarding.
          ? Center(
              child: CustomLoading(
                color: LightColor.secondaryColor,
                size: 30,
                strokeWidth: 3.5,
                secondCircleColor: LightColor.secondaryLight,
                thirdCircleColor: LightColor.secondaryLight,
              ),
            )
          : _error != null
          ? AppMessageView(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load your venues',
              message: _error!,
              actionLabel: 'Retry',
              onAction: _loadVenues,
            )
          : _venues.isEmpty
          // Nothing to book at: say so rather than show a form that cannot
          // be sent.
          ? AppMessageView(
              icon: Icons.stadium_outlined,
              title: 'No venues to book yet',
              message:
                  'Once a venue with courts is approved, you can take '
                  'walk-in bookings for it here.',
              actionLabel: 'Refresh',
              onAction: _loadVenues,
            )
          : SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  // The app's page margins, as on venue onboarding.
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.paddingX16,
                    AppDimens.paddingX16,
                    AppDimens.paddingX16,
                    AppDimens.paddingX20,
                  ),
                  children: <Widget>[
                    _buildHeader(context),
                    _sectionGap(),
                    _sectionCard(
                      context,
                      title: 'Venue',
                      subtitle: 'Choose where this booking will be created.',
                      icon: Icons.stadium_outlined,
                      children: <Widget>[
                        CustomDropdownField<VenueCourtModel>(
                          labelText: 'Futsal venue',
                          hintText: 'Select a venue',
                          icon: Icons.stadium_outlined,
                          initialValue: _venue,
                          isRequired: true,
                          items: _venues
                              .map(
                                (VenueCourtModel venue) =>
                                    DropdownMenuItem<VenueCourtModel>(
                                      value: venue,
                                      child: Text(
                                        venue.title,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                              )
                              .toList(),
                          onChanged: (VenueCourtModel? value) =>
                              setState(() => _venue = value),
                          validator: (VenueCourtModel? value) =>
                              value == null ? 'Select a venue.' : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ],
                    ),
                    _sectionGap(),
                    _sectionCard(
                      context,
                      title: 'Customer details',
                      subtitle: 'Contact information for the walk-in customer.',
                      icon: Icons.person_outline_rounded,
                      children: <Widget>[
                        _field(
                          _name,
                          'Customer name',
                          TextInputType.name,
                          hint: 'Full name',
                          icon: Icons.person_outline_rounded,
                          capitalization: TextCapitalization.words,
                          autofillHints: const <String>[AutofillHints.name],
                          onChanged: _onCandidateSearchChanged,
                          validator: (String? v) => (v?.trim().isEmpty ?? true)
                              ? 'Enter the customer\'s name'
                              : null,
                        ),
                        _gap(),
                        _field(
                          _phone,
                          'Phone number',
                          TextInputType.phone,
                          hint: '98XXXXXXXX',
                          icon: Icons.phone_outlined,
                          autofillHints: const <String>[
                            AutofillHints.telephoneNumber,
                          ],
                          onChanged: _onCandidateSearchChanged,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          validator: (String? v) {
                            final String t = v?.trim() ?? '';
                            if (t.isEmpty) {
                              return 'Enter the customer\'s phone number';
                            }
                            if (t.length < 7) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        _candidatePicker(context),
                      ],
                    ),
                    _sectionGap(),
                    _sectionCard(
                      context,
                      title: 'Booking details',
                      subtitle: 'Set the initial payment and booking status.',
                      icon: Icons.payments_outlined,
                      children: <Widget>[
                        CustomTextField(
                          key: const Key('manual-booking-total-amount'),
                          labelText: 'Total amount (NPR)',
                          // Optional: blank lets the server price the slots.
                          hintText: 'Leave blank to use slot prices',
                          controller: _totalAmount,
                          // CustomTextField marks every label required by
                          // default; this one genuinely is not.
                          isRequired: false,
                          icon: Icons.payments_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          ensureVisibleOnFocus: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          inputFormatters: <TextInputFormatter>[
                            // Digits and at most one decimal point, so the
                            // value always parses.
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: _optionalAmount,
                        ),
                        _gap(),
                        _dropdown(
                          label: 'Payment method',
                          icon: Icons.account_balance_wallet_outlined,
                          value: _paymentMethod,
                          values: const <String>['cash', 'online'],
                          onChanged: (String value) =>
                              setState(() => _paymentMethod = value),
                        ),
                        _gap(),
                        _dropdown(
                          label: 'Payment status',
                          icon: Icons.verified_outlined,
                          value: _paymentStatus,
                          values: const <String>['paid', 'pending', 'unpaid'],
                          onChanged: (String value) =>
                              setState(() => _paymentStatus = value),
                        ),
                        _gap(),
                        _dropdown(
                          label: 'Booking status',
                          icon: Icons.event_available_outlined,
                          value: _bookingStatus,
                          values: const <String>['confirmed', 'pending'],
                          onChanged: (String value) =>
                              setState(() => _bookingStatus = value),
                        ),
                        _gap(),
                        CustomTextField(
                          labelText: 'Payment note',
                          hintText: 'Add a payment remark',
                          controller: _note,
                          icon: Icons.notes_rounded,
                          maxLines: 2,
                          isRequired: false,
                          textCapitalization: TextCapitalization.sentences,
                          ensureVisibleOnFocus: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX14,
        vertical: AppDimens.paddingX12,
      ),
      decoration: BoxDecoration(
        color: LightColor.secondarySoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: AppDimens.sizeX32,
            height: AppDimens.sizeX32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: LightColor.secondaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              '1',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.inverseTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Enter booking details',
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX2),
                Text(
                  'Next, select an available date and time slot.',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX16,
              vertical: AppDimens.paddingX12,
            ),
            color: LightColor.cardColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: AppDimens.sizeX36,
                  height: AppDimens.sizeX36,
                  decoration: BoxDecoration(
                    color: LightColor.background,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    border: Border.all(color: LightColor.dividerColor),
                  ),
                  child: Icon(
                    icon,
                    size: AppDimens.sizeX18,
                    color: LightColor.secondaryTextColor,
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: FutsalTheme.getTextTheme(context).bodyTextMedium
                            ?.copyWith(
                              color: LightColor.primaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppDimens.paddingX2),
                      Text(
                        subtitle,
                        style: FutsalTheme.getTextTheme(context).bodyTextSmall
                            ?.copyWith(
                              color: LightColor.secondaryTextColor,
                              height: 1.3,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: LightColor.dividerColor),
          Padding(
            padding: const EdgeInsets.all(AppDimens.paddingX16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gap() => const SizedBox(height: AppDimens.paddingX16);

  Widget _sectionGap() => const SizedBox(height: AppDimens.paddingX14);

  Widget _field(
    TextEditingController controller,
    String label,
    TextInputType keyboardType, {
    required String hint,
    required IconData icon,
    required FormFieldValidator<String> validator,
    ValueChanged<String>? onChanged,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
  }) {
    return CustomTextField(
      controller: controller,
      labelText: label,
      hintText: hint,
      icon: icon,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      textInputAction: TextInputAction.next,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      onChanged: onChanged,
      ensureVisibleOnFocus: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
    );
  }

  Widget _candidatePicker(BuildContext context) {
    if (!_showCandidatePicker) {
      return const SizedBox.shrink();
    }
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingX10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: LightColor.background,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          border: Border.all(color: LightColor.dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingX12,
                AppDimens.paddingX10,
                AppDimens.paddingX12,
                AppDimens.paddingX6,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.person_search_outlined,
                    size: AppDimens.sizeX18,
                    color: LightColor.secondaryTextColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX8),
                  Expanded(
                    child: Text(
                      'Existing candidates',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _showCandidatePicker = false),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.paddingX4),
                      child: Icon(
                        Icons.close_rounded,
                        size: AppDimens.sizeX18,
                        color: LightColor.secondaryTextColor,
                      ),
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
                  'No existing candidate found. This booking will use the new customer details.',
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
                        backgroundColor: LightColor.secondarySoft,
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: AppDimens.sizeX18,
                          color: LightColor.secondaryColor,
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: candidate.phone.isEmpty
                          ? null
                          : Text(
                              candidate.phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return CustomDropdownField<String>(
      labelText: label,
      icon: icon,
      initialValue: value,
      items: values
          .map(
            (String item) => DropdownMenuItem<String>(
              value: item,
              child: Text(_displayOption(item)),
            ),
          )
          .toList(),
      onChanged: (String? item) {
        if (item != null) onChanged(item);
      },
      isRequired: true,
    );
  }

  String _displayOption(String value) {
    final String normalized = value.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return normalized;
    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}

class _ManualBookingActionBar extends StatelessWidget {
  const _ManualBookingActionBar({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        border: Border(top: BorderSide(color: LightColor.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX16,
            AppDimens.paddingX10,
            AppDimens.paddingX16,
            AppDimens.paddingX10,
          ),
          child: SizedBox(
            height: AppDimens.sizeX46,
            child: CustomButton(
              text: 'Continue to slot selection',
              icon: Icons.arrow_forward_rounded,
              onPressed: onContinue,
            ),
          ),
        ),
      ),
    );
  }
}
