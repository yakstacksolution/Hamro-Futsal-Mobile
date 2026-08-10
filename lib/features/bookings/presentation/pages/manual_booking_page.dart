import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/bookings/data/model/manual_booking_details.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/courts/data/repositories/venue_court_repository_impl.dart';
import 'package:hamro_footsall/features/courts/domain/usecase/get_venue_court_use_case.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/slots_selection_route_args.dart';

class ManualBookingPage extends StatefulWidget {
  const ManualBookingPage({super.key});

  @override
  State<ManualBookingPage> createState() => _ManualBookingPageState();
}

class _ManualBookingPageState extends State<ManualBookingPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _note = TextEditingController(
    text: 'Paid at counter',
  );

  List<VenueCourtModel> _venues = const <VenueCourtModel>[];
  VenueCourtModel? _venue;
  bool _loading = true;
  String? _error;
  String _paymentMethod = 'cash';
  String _paymentStatus = 'paid';
  String _bookingStatus = 'confirmed';

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final Either<AppException, List<VenueCourtModel>> result =
        await GetVenueCourtUseCase(
          VenueCourtRepositoryImpl(),
        ).getAllVenueCourts();
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
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!(_formKey.currentState?.validate() ?? false) || _venue == null) return;
    final VenueCourtModel venue = _venue!;
    final bool? booked = await context.pushNamed<bool>(
      AppRouterParams.slotsSelection.name,
      extra: SlotsSelectionRouteArgs(
        court: CourtDetailModel(
          venueId: venue.id,
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
          customerEmail: _email.text.trim(),
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

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Manual booking'),
      bottomNavigationBar: _loading || _error != null
          ? null
          : _ManualBookingActionBar(
              enabled: _venues.isNotEmpty,
              onContinue: _continue,
            ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: LightColor.secondaryColor,
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.paddingX24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.cloud_off_rounded,
                      color: LightColor.secondaryTextColor,
                      size: AppDimens.sizeX44,
                    ),
                    const SizedBox(height: AppDimens.paddingX12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: FutsalTheme.getTextTheme(context).bodyTextMedium
                          ?.copyWith(color: LightColor.secondaryTextColor),
                    ),
                    const SizedBox(height: AppDimens.paddingX16),
                    SizedBox(
                      width: AppDimens.sizeX130,
                      child: CustomButton(
                        text: 'Retry',
                        icon: Icons.refresh_rounded,
                        onPressed: _loadVenues,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.paddingX20,
                    AppDimens.paddingX12,
                    AppDimens.paddingX20,
                    AppDimens.paddingX32,
                  ),
                  children: <Widget>[
                    _buildHeader(context),
                    const SizedBox(height: AppDimens.paddingX18),
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
                    const SizedBox(height: AppDimens.paddingX14),
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
                          icon: Icons.person_outline_rounded,
                          capitalization: TextCapitalization.words,
                        ),
                        _gap(),
                        _field(
                          _phone,
                          'Phone number',
                          TextInputType.phone,
                          icon: Icons.phone_outlined,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                        ),
                        _gap(),
                        CustomTextField(
                          labelText: 'Email address',
                          hintText: 'customer@example.com',
                          controller: _email,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          ensureVisibleOnFocus: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String? value) {
                            final String? required = _required(value);
                            if (required != null) return required;
                            return value!.contains('@')
                                ? null
                                : 'Enter a valid email.';
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.paddingX16),
                    _sectionCard(
                      context,
                      title: 'Booking details',
                      subtitle: 'Set the initial payment and booking status.',
                      icon: Icons.payments_outlined,
                      children: <Widget>[
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

  Widget _field(
    TextEditingController controller,
    String label,
    TextInputType keyboardType, {
    required IconData icon,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return CustomTextField(
      controller: controller,
      labelText: label,
      hintText: label,
      icon: icon,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      textInputAction: TextInputAction.next,
      inputFormatters: inputFormatters,
      ensureVisibleOnFocus: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _required,
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
  const _ManualBookingActionBar({
    required this.enabled,
    required this.onContinue,
  });

  final bool enabled;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: EdgeInsets.fromLTRB(
        AppDimens.paddingX20,
        AppDimens.paddingX12,
        AppDimens.paddingX20,
        AppDimens.paddingX12 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        border: Border(top: BorderSide(color: LightColor.dividerColor)),
      ),
      child: CustomButton(
        text: 'Continue to slot selection',
        icon: Icons.arrow_forward_rounded,
        onPressed: enabled ? onContinue : null,
        minHeight: AppDimens.sizeX48,
      ),
    );
  }
}
