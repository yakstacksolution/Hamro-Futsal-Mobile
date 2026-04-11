import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/widgets/custom_quill_editor.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'dart:async';

class CourtInformationSection extends StatelessWidget {
  const CourtInformationSection({
    super.key,
    required this.cubit,
    required this.court,
    required this.subsectionIndex,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;
  final int subsectionIndex;

  @override
  Widget build(BuildContext context) {
    switch (subsectionIndex) {
      case 0:
        return _CourtBasicInfoSubsection(cubit: cubit, court: court);
      case 1:
        return _CourtDescriptionSubsection(cubit: cubit, court: court);
      case 2:
        return _CourtTimeSchedulesSubsection(cubit: cubit, court: court);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _CourtBasicInfoSubsection extends StatelessWidget {
  const _CourtBasicInfoSubsection({required this.cubit, required this.court});

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const VendorPanelHeading(
            title: 'Court Info',
            subtitle: 'Set the name, base price, and type for this court.',
          ),
          const SizedBox(height: 18),
          VendorInputField(
            label: 'Court name',
            initialValue: court.name,
            onChanged: (String value) =>
                cubit.updateActiveCourt(court.copyWith(name: value)),
          ),
          const SizedBox(height: 14),
          VendorInputField(
            label: 'Base price',
            initialValue: formatDouble(court.basePrice),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (String value) => cubit.updateActiveCourt(
              court.copyWith(
                basePrice: parseDouble(value),
                clearBasePrice: value.trim().isEmpty,
              ),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: court.courtType,
            items: courtTypeOptions
                .map(
                  (String item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
            decoration: vendorInputDecoration('Court type'),
            onChanged: (String? value) => cubit.updateActiveCourt(
              court.copyWith(courtType: value, clearCourtType: value == null),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtDescriptionSubsection extends StatefulWidget {
  const _CourtDescriptionSubsection({required this.cubit, required this.court});

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  State<_CourtDescriptionSubsection> createState() =>
      _CourtDescriptionSubsectionState();
}

class _CourtDescriptionSubsectionState
    extends State<_CourtDescriptionSubsection> {
  final ScrollController _scrollController = ScrollController();
  late final QuillController _quillController;
  Timer? _debounceTimer;
  String _lastHtmlContent = '';
  bool _initialized = false;
  final Object _flushOwner = Object();

  @override
  void initState() {
    super.initState();
    _lastHtmlContent = widget.court.description;

    widget.cubit.registerActiveEditorFlush(_flushOwner, _flushPendingChanges);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEditor();
    });
  }

  void _initializeEditor() {
    if (_initialized) return;

    _quillController = _initializeQuillController(
      html: widget.court.description,
    );
    _quillController.addListener(_onEditorChanged);

    setState(() => _initialized = true);
  }

  QuillController _initializeQuillController({String? html}) {
    late final Document document;

    if (html != null && html.trim().isNotEmpty) {
      final delta = HtmlToDelta().convert(html);
      document = Document.fromDelta(delta);
    } else {
      document = Document();
    }

    return QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void _onEditorChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final delta = _quillController.document.toDelta();
      final String htmlConverter =
          QuillDeltaToHtmlConverter(delta.toJson()).convert();

      if (htmlConverter != _lastHtmlContent) {
        _lastHtmlContent = htmlConverter;
        widget.cubit.updateActiveCourt(
          widget.court.copyWith(description: htmlConverter),
        );
      }
    });
  }

  void _flushPendingChanges() {
    if (!_initialized) return;

    final delta = _quillController.document.toDelta();
    final String htmlConverter =
        QuillDeltaToHtmlConverter(delta.toJson()).convert();

    if (htmlConverter == _lastHtmlContent) return;
    _lastHtmlContent = htmlConverter;
    widget.cubit.updateActiveCourt(
      widget.cubit.state.activeCourt?.copyWith(description: htmlConverter) ??
          widget.court.copyWith(description: htmlConverter),
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _CompactCourtDescriptionHeader(
            title: 'Description',
            subtitle:
                'Tell customers about this court. Describe the surface, size, and any unique features.',
            icon: Icons.description_rounded,
          ),
          const SizedBox(height: 12),
          if (!_initialized)
            const SizedBox(
              height: 450,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 450,
              child: CustomQuillEditor(
                isReadOnly: false,
                controller: _quillController,
                scrollController: _scrollController,
                hintText: 'Description about your court...',
              ),
            ),
        ],
      ),
    );
  }
}

class _CompactCourtDescriptionHeader extends StatelessWidget {
  const _CompactCourtDescriptionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

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
            child: Icon(icon, size: 18, color: LightColor.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: LightColor.titleText,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
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

class _CourtTimeSchedulesSubsection extends StatelessWidget {
  const _CourtTimeSchedulesSubsection({
    required this.cubit,
    required this.court,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const VendorPanelHeading(
            title: 'Time Schedules',
            subtitle:
                'Configure which days this court is available and set operating hours.',
          ),
          const SizedBox(height: 18),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: court.availability.isOpen24Hours,
            activeThumbColor: LightColor.secondary,
            title: const Text(
              'Open 24 hours',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'If enabled, open/close time fields are hidden.',
            ),
            onChanged: (bool value) => cubit.updateActiveCourt(
              court.copyWith(
                availability: court.availability.copyWith(
                  isOpen24Hours: value,
                  openTime: value ? '' : court.availability.openTime,
                  closeTime: value ? '' : court.availability.closeTime,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const VendorFieldLabel('Availability days'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: weekdayOptions
                .map(
                  (String day) => VendorSelectableChip(
                    label: day,
                    isSelected: court.availability.days.contains(day),
                    onTap: () => cubit.toggleAvailabilityDay(day),
                  ),
                )
                .toList(),
          ),
          if (!court.availability.isOpen24Hours) ...<Widget>[
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: VendorInputField(
                    label: 'Open time',
                    initialValue: court.availability.openTime,
                    onChanged: (String value) => cubit.updateActiveCourt(
                      court.copyWith(
                        availability: court.availability.copyWith(
                          openTime: value,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VendorInputField(
                    label: 'Close time',
                    initialValue: court.availability.closeTime,
                    onChanged: (String value) => cubit.updateActiveCourt(
                      court.copyWith(
                        availability: court.availability.copyWith(
                          closeTime: value,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
