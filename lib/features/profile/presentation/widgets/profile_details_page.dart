import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_date_picker.dart';
import 'package:hamro_footsall/core/widgets/custom_dropdown_field.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:intl/intl.dart';
import 'package:hamro_footsall/features/media/presentation/widgets/media_library_sheet.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_footsall/features/vendor/data/repositories/vendor_onboarding_repository_impl.dart';
import 'package:hamro_footsall/features/vendor/domain/usecase/vendor_onboarding_usecase.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key, this.user});

  final UserData? user;

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  static const List<String> _genderOptions = <String>[
    'Male',
    'Female',
    'Others',
  ];

  late String _selectedGender;
  DateTime? _dateOfBirth;
  String? _avatarUrl;
  int? _avatarMediaId;
  bool _isPhotoOnlyUpdate = false;

  late final TextEditingController _fullnameController;
  late final TextEditingController _dobController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  late final FocusNode _fullnameFocus;
  late final FocusNode _dobFocus;
  late final FocusNode _genderFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _phoneFocus;
  late final FocusNode _addressFocus;

  late final VendorOnboardingCubit _mediaCubit;

  @override
  void initState() {
    super.initState();
    final UserData? user =
        context.read<ProfileBloc>().state.profile?.data ?? widget.user;

    _selectedGender = _resolvedGender(user);
    _dateOfBirth = user?.dateOfBirth;
    _avatarUrl = _resolvedAvatar(user);

    _fullnameController = TextEditingController(text: _resolvedFullName(user));
    _dobController = TextEditingController(
      text: _dateOfBirth == null
          ? ''
          : DateFormat('dd MMM y').format(_dateOfBirth!),
    );
    _emailController = TextEditingController(
      text: _resolvedValue(user?.email, ''),
    );
    _phoneController = TextEditingController(
      text: _resolvedValue(user?.phone, ''),
    );
    _addressController = TextEditingController(text: _resolvedAddress(user));

    _fullnameFocus = FocusNode();
    _dobFocus = FocusNode();
    _genderFocus = FocusNode();
    _emailFocus = FocusNode();
    _phoneFocus = FocusNode();
    _addressFocus = FocusNode();

    _mediaCubit = VendorOnboardingCubit(
      const EphemeralVendorDraftRepository(),
      onboardingUseCase: VendorOnboardingUseCase(
        VendorOnboardingRepositoryImpl(),
      ),
    );

    context.read<ProfileBloc>().add(const FetchProfileEvent());
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    _fullnameFocus.dispose();
    _dobFocus.dispose();
    _genderFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();

    _mediaCubit.close();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    FocusScope.of(context).unfocus();

    final DateTime? picked = await showCustomDatePicker(
      context,
      type: CustomDatePickerType.dateOfBirth,
      initialDate: _dateOfBirth,
    );

    if (picked == null) return;
    setState(() {
      _dateOfBirth = picked;
      _dobController.text = DateFormat('dd MMM y').format(picked);
    });
  }

  Future<void> _changeProfilePhoto() async {
    FocusScope.of(context).unfocus();

    final List<UploadRef>? picked = await showVendorMediaLibrarySheet(
      context: context,
      cubit: _mediaCubit,
      allowedExtensions: const <String>['png', 'jpg', 'jpeg', 'webp'],
      allowMultiple: false,
      title: StringConstants.profilePhoto,
      subtitle: StringConstants.chooseASavedImageOrUploadANewOne,
    );

    if (picked == null || picked.isEmpty) return;
    final UploadRef selected = picked.first;
    final String? remoteUrl = selected.remoteUrl;
    if (remoteUrl == null || remoteUrl.trim().isEmpty) return;

    setState(() {
      _avatarUrl = remoteUrl;
      _avatarMediaId = selected.id;
    });

    if (selected.id == null) return;
    if (!mounted) return;
    _isPhotoOnlyUpdate = true;
    context.read<ProfileBloc>().add(_buildUpdateEvent());
  }

  UpdateProfileEvent _buildUpdateEvent() {
    return UpdateProfileEvent(
      fullName: _fullnameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _dateOfBirth,
      gender: _selectedGender,
      address: _addressController.text.trim(),
      profilePhoto: _avatarMediaId?.toString(),
      profilePhotoUrl: _avatarMediaId == null ? null : _avatarUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: StringConstants.personalDetails,
        centerTitle: false,
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              (current.status == ProfileStatus.updateSuccess ||
                  current.status == ProfileStatus.success ||
                  (current.status == ProfileStatus.failure &&
                      current.errorMessage != null)),
          listener: (context, state) {
            if (state.status == ProfileStatus.success) {
              _syncFromProfile(state.profile?.data);
              return;
            }
            if (state.status == ProfileStatus.updateSuccess) {
              final bool wasPhotoOnly = _isPhotoOnlyUpdate;
              _isPhotoOnlyUpdate = false;
              AppUtils().showSnackBar(
                context,
                MsgType.success,
                state.successMessage ?? 'Profile updated successfully.',
              );
              if (!wasPhotoOnly) {
                Navigator.of(context).maybePop();
              }
              return;
            }
            if (state.status == ProfileStatus.failure &&
                state.errorMessage != null) {
              _isPhotoOnlyUpdate = false;
              setState(() => _avatarUrl = state.profileImage);
              AppUtils().showSnackBar(
                context,
                MsgType.error,
                state.errorMessage!,
              );
            }
          },
          builder: (context, state) {
            final bool isUpdating = state.isUpdating;
            final bool isFetching = state.status == ProfileStatus.loading;
            return Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: _buildBody(context, isUpdating: isUpdating),
                ),
                if (isFetching)
                  Positioned.fill(
                    child: Center(
                      child: const LoadingWidget(
                        isButtonLoading: false,
                        isTransparentBackground: true,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Summary banner (phone/tablet) or side column (desktop), plus the form.
  Widget _buildBody(BuildContext context, {required bool isUpdating}) {
    final Widget summary = _ProfileSummaryCard(
      name: _resolvedFullName(widget.user),
      address: _resolvedAddress(widget.user),
      avatarUrl: _avatarUrl ?? '',
      onChangeImageTap: _changeProfilePhoto,
    );

    final EdgeInsets padding = EdgeInsets.only(
      left: context.responsive<double>(
        mobile: AppDimens.paddingX20,
        tablet: AppDimens.paddingX32,
      ),
      right: context.responsive<double>(
        mobile: AppDimens.paddingX20,
        tablet: AppDimens.paddingX32,
      ),
      top: AppDimens.paddingX16,
      bottom: AppDimens.paddingX32,
    );

    if (context.isDesktop) {
      // Summary beside the form rather than stacked above it. The form itself
      // stays one field per row at every width.
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth:
                  AppDimens.profileSummaryColumnWidth +
                  AppDimens.formContentMaxWidth +
                  AppDimens.paddingX32,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: AppDimens.profileSummaryColumnWidth,
                  child: summary,
                ),
                const SizedBox(width: AppDimens.paddingX32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _formSections(context, isUpdating: isUpdating),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: padding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimens.formContentMaxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    summary,
                    const SizedBox(height: AppDimens.paddingX20),
                    ..._formSections(context, isUpdating: isUpdating),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The two section cards plus the save action. Identical at every width —
  /// one field per row, never paired.
  List<Widget> _formSections(BuildContext context, {required bool isUpdating}) {
    return <Widget>[
      _sectionLabel(context, 'Personal information'),
      const SizedBox(height: AppDimens.paddingX10),
      _SectionCard(
        children: [
          CustomTextField(
            controller: _fullnameController,
            focusNode: _fullnameFocus,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _pickDateOfBirth(),
            labelText: StringConstants.fullNameSentenceCase,
            hintText: StringConstants.enterYourFullName,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: AppDimens.paddingX16),
          CustomTextField(
            controller: _dobController,
            focusNode: _dobFocus,
            keyboardType: TextInputType.datetime,
            labelText: StringConstants.dateOfBirth,
            hintText: StringConstants.selectDateOfBirth,
            icon: Icons.cake_outlined,
            readOnly: true,
            onTap: _pickDateOfBirth,
            suffixIcon: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pickDateOfBirth,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: LightColor.secondaryTextColor,
                  size: AppDimens.sizeX18,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingX16),
          CustomDropdownField<String>(
            key: const Key('personal-details-gender-field'),
            labelText: StringConstants.gender,
            icon: Icons.wc_rounded,
            hintText: StringConstants.selectGender,
            initialValue: _selectedGender,
            focusNode: _genderFocus,
            items: _genderOptions
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedGender = value);
            },
          ),
        ],
      ),
      const SizedBox(height: AppDimens.paddingX20),
      _sectionLabel(context, 'Contact information'),
      const SizedBox(height: AppDimens.paddingX10),
      _SectionCard(
        children: [
          CustomTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_phoneFocus),
            labelText: StringConstants.emailAddressSentenceCase,
            hintText: StringConstants.nameExampleCom,
            icon: Icons.email_outlined,
            readOnly: true,
          ),
          const SizedBox(height: AppDimens.paddingX16),
          CustomTextField(
            controller: _phoneController,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_addressFocus),
            labelText: StringConstants.phoneNumberSentenceCase,
            hintText: '+977 #########',
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: AppDimens.paddingX16),
          CustomTextField(
            controller: _addressController,
            focusNode: _addressFocus,
            keyboardType: TextInputType.streetAddress,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            labelText: StringConstants.address,
            hintText: StringConstants.enterYourAddress,
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
      const SizedBox(height: AppDimens.paddingX28),
      // Full width on a phone; capped and trailing-aligned once the column is
      // wide, where an edge-to-edge button looks like a banner.
      if (context.isTabletOrWider)
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimens.formActionMaxWidth,
            ),
            child: SizedBox(
              width: AppDimens.formActionMaxWidth,
              child: CustomButton(
                text: StringConstants.saveChanges,
                isLoading: isUpdating,
                onPressed: _onSavePressed,
              ),
            ),
          ),
        )
      else
        CustomButton(
          text: StringConstants.saveChanges,
          isLoading: isUpdating,
          onPressed: _onSavePressed,
        ),
    ];
  }

  void _syncFromProfile(UserData? user) {
    if (user == null) return;
    setState(() {
      _selectedGender = _resolvedGender(user);
      _dateOfBirth = user.dateOfBirth;
      _avatarUrl = _resolvedAvatar(user);
      _fullnameController.text = _resolvedFullName(user);
      _dobController.text = _dateOfBirth == null
          ? ''
          : DateFormat('dd MMM y').format(_dateOfBirth!);
      _emailController.text = _resolvedValue(user.email, '');
      _phoneController.text = _resolvedValue(user.phone, '');
      _addressController.text = _resolvedAddress(user);
    });
  }

  void _onSavePressed() {
    FocusScope.of(context).unfocus();

    final ProfileBloc bloc = context.read<ProfileBloc>();
    if (bloc.state.isUpdating) return;

    bloc.add(_buildUpdateEvent());
  }

  Widget _sectionLabel(BuildContext context, String label) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.only(left: AppDimens.paddingX4),
      child: Text(
        label,
        style: textTheme.bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _resolvedFullName(UserData? user) {
    if (user == null) return 'Profile unavailable';
    if (user.fullName.trim().isNotEmpty) return user.fullName;
    return 'Name not provided';
  }

  String _resolvedAddress(UserData? user) {
    if (user == null) return '';
    if (user.address != null && user.address!.trim().isNotEmpty) {
      return user.address!;
    }
    if (user.designation != null && user.designation!.trim().isNotEmpty) {
      return user.designation!;
    }
    if (user.latitude != null && user.longitude != null) {
      return '${user.latitude}, ${user.longitude}';
    }
    return '';
  }

  String _resolvedGender(UserData? user) {
    final String? raw = user?.gender?.trim();
    if (raw == null || raw.isEmpty) return 'Others';
    if (raw.toLowerCase() == 'other' || raw.toLowerCase() == 'others') {
      return 'Others';
    }
    final String normalized =
        raw[0].toUpperCase() + raw.substring(1).toLowerCase();
    if (_genderOptions.contains(normalized)) return normalized;
    return 'Others';
  }

  String? _resolvedAvatar(UserData? user) {
    final String? profilePhoto = user?.profilePhoto?.remoteUrl;
    if (profilePhoto == null || profilePhoto.trim().isEmpty) return null;
    return profilePhoto;
  }

  String _resolvedValue(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.name,
    required this.address,
    required this.avatarUrl,
    required this.onChangeImageTap,
  });

  final String name;
  final String address;
  final String avatarUrl;
  final VoidCallback onChangeImageTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final String addressLabel = address.isEmpty ? 'Address not set' : address;

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: LightColor.secondaryColor.withValues(alpha: 0.15),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomImageView(
                url: avatarUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingX14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: AppDimens.sizeX14,
                      color: LightColor.hintTextColor,
                    ),
                    const SizedBox(width: AppDimens.paddingX4),
                    Expanded(
                      child: Text(
                        addressLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingX10),
                _ChangePhotoButton(onTap: onChangeImageTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangePhotoButton extends StatelessWidget {
  const _ChangePhotoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: LightColor.secondaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: AppDimens.sizeX14,
                color: LightColor.secondaryColor,
              ),
              const SizedBox(width: AppDimens.paddingX6),
              Text(
                StringConstants.changePhoto,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX16,
        vertical: AppDimens.paddingX18,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
