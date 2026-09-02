import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/profile/data/model/profile_model.dart';
import 'package:hamro_futsal/features/profile/presentation/profile_bloc/profile_bloc.dart';

class VendorRequestBottomSheet extends StatefulWidget {
  const VendorRequestBottomSheet({super.key, required this.user});

  final UserData user;

  @override
  State<VendorRequestBottomSheet> createState() =>
      _VendorRequestBottomSheetState();
}

class _VendorRequestBottomSheetState extends State<VendorRequestBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _businessNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _messageController;
  late final FocusNode _businessNameFocusNode;
  late final FocusNode _phoneFocusNode;
  late final FocusNode _addressFocusNode;
  late final FocusNode _messageFocusNode;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _messageController = TextEditingController();
    _businessNameFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _messageFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _businessNameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<ProfileBloc>().add(
      RequestVendorUpgradeEvent(
        businessName: _businessNameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        message: _messageController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double sheetHeight = mediaQuery.size.height * 0.6;

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == ProfileStatus.vendorRequestSuccess,
      listener: (context, state) => Navigator.of(context).pop(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: sheetHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Upgrade to Vendor',
                        style: textTheme.bodyTextLarge?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingX22),
                      CustomTextField(
                        controller: _businessNameController,
                        focusNode: _businessNameFocusNode,
                        labelText: 'Business name',
                        hintText: 'Enter your business name',
                        icon: Icons.storefront_outlined,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        ensureVisibleOnFocus: true,
                        onSubmitted: (_) => _phoneFocusNode.requestFocus(),
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(255),
                        ],
                        validator: (value) =>
                            _requiredValidator(value, 'Business name'),
                      ),
                      const SizedBox(height: AppDimens.paddingX16),
                      CustomTextField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        labelText: 'Phone',
                        hintText: 'Enter your phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        ensureVisibleOnFocus: true,
                        onSubmitted: (_) => _addressFocusNode.requestFocus(),
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(30),
                        ],
                        validator: (value) =>
                            _requiredValidator(value, 'Phone'),
                      ),
                      const SizedBox(height: AppDimens.paddingX16),
                      CustomTextField(
                        controller: _addressController,
                        focusNode: _addressFocusNode,
                        labelText: 'Address',
                        hintText: 'Enter your business address',
                        icon: Icons.location_on_outlined,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        maxLines: 2,
                        minLines: 1,
                        ensureVisibleOnFocus: true,
                        onSubmitted: (_) => _messageFocusNode.requestFocus(),
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(500),
                        ],
                        validator: (value) =>
                            _requiredValidator(value, 'Address'),
                      ),
                      const SizedBox(height: AppDimens.paddingX16),
                      CustomTextField(
                        controller: _messageController,
                        focusNode: _messageFocusNode,
                        labelText: 'Message',
                        hintText: 'Add an optional message',
                        isRequired: false,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        minLines: 5,
                        maxLines: 7,
                        ensureVisibleOnFocus: true,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(1000),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _VendorRequestActionBar(onSubmit: _submit),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _VendorRequestActionBar extends StatelessWidget {
  const _VendorRequestActionBar({required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        height: 60,
        width: double.infinity,
        padding: const EdgeInsets.only(top: AppDimens.paddingX12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: LightColor.dividerColor, width: 0.8),
          ),
        ),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          buildWhen: (previous, current) =>
              previous.isRequestingVendor != current.isRequestingVendor,
          builder: (context, state) {
            return CustomButton(
              text: 'Submit request',
              icon: Icons.send_rounded,
              isLoading: state.isRequestingVendor,
              onPressed: state.isRequestingVendor ? null : onSubmit,
            );
          },
        ),
      ),
    );
  }
}
