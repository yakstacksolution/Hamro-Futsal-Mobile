import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/widgets/custom_quill_editor.dart';
import 'package:hamro_footsall/features/courts/presentation/models/picked_location.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/exact_location_picker_sheet.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

class FutsalInformationSection extends StatefulWidget {
  const FutsalInformationSection({
    super.key,
    required this.cubit,
    required this.draft,
    required this.subsectionIndex,
  });

  final VendorOnboardingCubit cubit;
  final FutsalDraft draft;
  final int subsectionIndex;

  @override
  State<FutsalInformationSection> createState() =>
      _FutsalInformationSectionState();
}

class _FutsalInformationSectionState extends State<FutsalInformationSection> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _exactLocationController =
      TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _websiteOrSocialLinkController =
      TextEditingController();
  late final QuillController _quillController;
  Timer? _debounceTimer;
  String _lastHtmlContent = '';
  bool _initialized = false;
  final Object _flushOwner = Object();

  @override
  void initState() {
    super.initState();
    _lastHtmlContent = widget.draft.description;
    _syncLocationControllers();

    widget.cubit.registerActiveEditorFlush(_flushOwner, _flushPendingChanges);

    if (widget.subsectionIndex == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeEditor();
      });
    }
  }

  @override
  void didUpdateWidget(covariant FutsalInformationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.location != widget.draft.location) {
      _syncLocationControllers();
    }

    if (oldWidget.draft.websiteOrSocialLink !=
        widget.draft.websiteOrSocialLink) {
      _websiteOrSocialLinkController.text = widget.draft.websiteOrSocialLink;
    }
    if (oldWidget.draft.description != widget.draft.description &&
        _initialized) {
      if (widget.draft.description != _lastHtmlContent) {
        _replaceEditorContent(widget.draft.description);
      }
    }
  }

  void _syncLocationControllers() {
    _exactLocationController.text = widget.draft.location.exactLocation;
    _longitudeController.text = formatDouble(widget.draft.location.longitude);
    _latitudeController.text = formatDouble(widget.draft.location.latitude);
    _websiteOrSocialLinkController.text = widget.draft.websiteOrSocialLink;
  }

  void _initializeEditor() {
    if (_initialized) return;

    _quillController = _initializeQuillController(
      html: widget.draft.description,
    );
    _quillController.addListener(_onEditorChanged);

    setState(() => _initialized = true);
  }

  void _replaceEditorContent(String html) {
    _lastHtmlContent = html;
    final Document document = _buildDocumentFromHtml(html);
    _quillController.document = document;
    _quillController.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
  }

  void _onEditorChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final String htmlConverter = _currentEditorHtml();

      if (htmlConverter != _lastHtmlContent) {
        _lastHtmlContent = htmlConverter;
        widget.cubit.updateFutsal(
          widget.draft.copyWith(description: htmlConverter),
        );
      }
    });
  }

  String _currentEditorHtml() {
    final delta = _quillController.document.toDelta();
    return QuillDeltaToHtmlConverter(delta.toJson()).convert();
  }

  void _flushPendingChanges() {
    if (!_initialized) return;

    final String html = _currentEditorHtml();
    if (html == _lastHtmlContent) return;

    _lastHtmlContent = html;
    widget.cubit.updateFutsal(
      widget.cubit.state.futsal.copyWith(description: html),
    );
  }

  @override
  void dispose() {
    _flushPendingChanges();
    widget.cubit.unregisterActiveEditorFlush(_flushOwner);
    _debounceTimer?.cancel();
    if (_initialized) {
      _quillController.removeListener(_onEditorChanged);
      _quillController.dispose();
    }
    _exactLocationController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _websiteOrSocialLinkController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final PickedLocation? result = await showModalBottomSheet<PickedLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExactLocationPickerSheet(
        initialLabel: widget.draft.location.exactLocation,
        initialLatitude: widget.draft.location.latitude,
        initialLongitude: widget.draft.location.longitude,
      ),
    );

    if (result != null && mounted) {
      widget.cubit.updateFutsal(
        widget.draft.copyWith(
          location: widget.draft.location.copyWith(
            exactLocation: result.label,
            latitude: result.latitude,
            longitude: result.longitude,
          ),
        ),
      );
    }
  }

  QuillController _initializeQuillController({String? html}) {
    final Document document = _buildDocumentFromHtml(html);

    return QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  Document _buildDocumentFromHtml(String? html) {
    if (html != null && html.trim().isNotEmpty) {
      try {
        final delta = HtmlToDelta().convert(html);
        return Document.fromDelta(delta);
      } catch (_) {
        final String fallbackText = _stripHtml(html);
        final Document doc = Document();
        if (fallbackText.isNotEmpty) {
          doc.insert(0, '$fallbackText\n');
        }
        return doc;
      }
    }
    return Document();
  }

  String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]+>'), '').trim();

  @override
  Widget build(BuildContext context) {
    final _SectionMeta meta = _sectionMeta(widget.subsectionIndex);

    return VendorPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CompactSectionHeader(meta: meta),
          const SizedBox(height: 12),
          if (widget.subsectionIndex == 0) _buildBasicInfo(),
          if (widget.subsectionIndex == 1) _buildDescription(),
          if (widget.subsectionIndex == 2) _buildLocationInfo(),
          if (widget.subsectionIndex == 3) _buildAmenitiesAndFeatures(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 10),
        VendorInputField(
          label: 'Futsal Club Name',
          isRequired: true,
          hintText: 'Enter futsal club name',
          enableIcon: true,
          initialValue: widget.draft.title,
          onChanged: widget.cubit.updateFutsalBasicIdentity,
        ),

        const SizedBox(height: 20),
        VendorInputField(
          isRequired: true,
          label: 'Registration Number',
          hintText: 'Enter Futsal registration number',
          enableIcon: true,
          readOnly: false,

          initialValue: widget.draft.registrationNumber,
          onChanged: (String value) => widget.cubit.updateFutsal(
            widget.draft.copyWith(registrationNumber: value),
          ),
        ),
        const SizedBox(height: 20),

        VendorInputField(
          label: 'Phone Number',
          hintText: '98XXXXXXXX',
          initialValue: widget.draft.phone,
          enableIcon: true,
          keyboardType: TextInputType.phone,
          isRequired: true,
          onChanged: (String value) =>
              widget.cubit.updateFutsal(widget.draft.copyWith(phone: value)),
        ),
        const SizedBox(height: 20),
        VendorInputField(
          isRequired: true,
          label: 'Email Address',
          hintText: 'futsal@gmail.com',
          initialValue: widget.draft.email,
          enableIcon: true,
          keyboardType: TextInputType.emailAddress,
          onChanged: (String value) =>
              widget.cubit.updateFutsal(widget.draft.copyWith(email: value)),
        ),
        const SizedBox(height: 20),
        VendorInputField(
          label: 'Website or Social Media Link',
          hintText: 'https://hamrofutsal.com/',
          controller: _websiteOrSocialLinkController,
          initialValue: widget.draft.websiteOrSocialLink,
          enableIcon: true,
          keyboardType: TextInputType.url,
          onChanged: widget.cubit.updateFutsalWebsiteOrSocialLink,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDescription() {
    if (!_initialized) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 450,
          child: CustomQuillEditor(
            isReadOnly: false,
            controller: _quillController,
            scrollController: _scrollController,
            hintText: 'Description about your futsal...',
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 10),
        VendorInputField(
          label: 'Futsal Address',
          enableIcon: true,
          hintText: 'Street, city, area',
          initialValue: widget.draft.location.fullAddress,
          onChanged: (String value) => widget.cubit.updateFutsal(
            widget.draft.copyWith(
              location: widget.draft.location.copyWith(fullAddress: value),
            ),
          ),
        ),

        const SizedBox(height: 20),
        VendorInputField(
          label: 'Exact location',
          hintText: 'Tap to pick location on map',
          controller: _exactLocationController,
          initialValue: '',
          enableIcon: true,
          readOnly: true,
          onTap: _openLocationPicker,
          onChanged: (_) {},
        ),
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Expanded(
              child: VendorInputField(
                label: 'Longitude',
                hintText: 'Auto-filled',
                controller: _longitudeController,
                initialValue: '',
                readOnly: true,
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: VendorInputField(
                label: 'Latitude',
                hintText: 'Auto-filled',
                controller: _latitudeController,
                initialValue: '',
                readOnly: true,
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesAndFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _CompactGroupCard(
          title: 'Amenities',
          icon: Icons.chair_alt_rounded,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 48,
            ),
            itemCount: futsalAmenityOptions.length,
            itemBuilder: (context, index) {
              final item = futsalAmenityOptions[index];
              return VendorSelectableChip(
                label: item,
                icon: futsalAmenityIcons[item],
                isSelected: widget.draft.amenities.contains(item),
                onTap: () => widget.cubit.toggleFutsalAmenity(item),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _CompactGroupCard(
          title: 'Features',
          icon: Icons.auto_awesome_rounded,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: 48,
            ),
            itemCount: futsalFeatureOptions.length,
            itemBuilder: (context, index) {
              final item = futsalFeatureOptions[index];
              return VendorSelectableChip(
                label: item,
                icon: futsalFeatureIcons[item],
                isSelected: widget.draft.features.contains(item),
                onTap: () => widget.cubit.toggleFutsalFeature(item),
              );
            },
          ),
        ),
      ],
    );
  }

  _SectionMeta _sectionMeta(int index) {
    switch (index) {
      case 0:
        return const _SectionMeta(
          title: 'Basic Information',
          subtitle: 'Venue identity and contact details',
          icon: Icons.storefront_rounded,
        );
      case 1:
        return const _SectionMeta(
          title: 'Description',
          subtitle: 'Tell customers about your futsal',
          icon: Icons.description_rounded,
        );
      case 2:
        return const _SectionMeta(
          title: 'Location Details',
          subtitle: 'Address and map coordinates',
          icon: Icons.location_on_rounded,
        );
      case 3:
        return const _SectionMeta(
          title: 'Amenities & Features',
          subtitle: 'Highlight what your futsal offers',
          icon: Icons.dashboard_customize_rounded,
        );
      default:
        return const _SectionMeta(
          title: 'Futsal Information',
          subtitle: 'Complete the required details',
          icon: Icons.info_rounded,
        );
    }
  }
}

class _CompactSectionHeader extends StatelessWidget {
  const _CompactSectionHeader({required this.meta});

  final _SectionMeta meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            LightColor.secondaryLight.withValues(alpha: 0.5),
            LightColor.secondaryLight.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.secondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: LightColor.secondaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(meta.icon, size: 18, color: LightColor.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  meta.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: LightColor.titleText,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meta.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: LightColor.subtitleText,
                    height: 1.3,
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

class _CompactGroupCard extends StatelessWidget {
  const _CompactGroupCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LightColor.backgroundWarm,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: LightColor.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: LightColor.secondary),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: LightColor.titleText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SectionMeta {
  const _SectionMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
