import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_switch_widget.dart';
import 'package:hamro_futsal/core/widgets/loading_widget.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:hamro_futsal/core/widgets/custom_quill_editor.dart';
import 'package:hamro_futsal/features/public/data/model/public_option_model.dart';
import 'package:hamro_futsal/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_court_options_use_case.dart';
import 'package:hamro_futsal/features/public/presentation/bloc/public_court_options/public_court_options_bloc.dart';
import 'package:hamro_futsal/features/public/presentation/bloc/public_templates/public_templates_bloc.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_futsal/features/vendor/presentation/utils/vendor_template_defaults.dart';
import 'package:hamro_futsal/features/vendor/presentation/validation/vendor_onboarding_validator.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/sections/court_media_section.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

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
    final _CourtSectionMeta meta = _sectionMeta(subsectionIndex);
    switch (subsectionIndex) {
      case 0:
        return _CourtBasicInfoSubsection(
          cubit: cubit,
          court: court,
          meta: meta,
        );
      case 1:
        return _CourtDescriptionSubsection(
          cubit: cubit,
          court: court,
          meta: meta,
        );
      case 2:
        return CourtMediaSection(cubit: cubit, court: court);
      default:
        return const SizedBox.shrink();
    }
  }

  _CourtSectionMeta _sectionMeta(int index) {
    return switch (index) {
      0 => const _CourtSectionMeta(
        title: StringConstants.courtInfo,
        subtitle: StringConstants.courtIdentityPricingTypeAndPlayingFormat,
        icon: Icons.stadium_rounded,
      ),
      1 => const _CourtSectionMeta(
        title: StringConstants.description,
        subtitle: StringConstants.tellCustomersAboutThisCourtSubtitle,
        icon: Icons.description_rounded,
      ),
      2 => const _CourtSectionMeta(
        title: StringConstants.photosAndMemories,
        subtitle: StringConstants.courtPhotosAndMemoriesLabel,
        icon: Icons.photo_library_rounded,
      ),
      _ => const _CourtSectionMeta(
        title: StringConstants.courtInformation,
        subtitle: StringConstants.completeCourtDetails,
        icon: Icons.info_rounded,
      ),
    };
  }
}

class _CourtBasicInfoSubsection extends StatefulWidget {
  const _CourtBasicInfoSubsection({
    required this.cubit,
    required this.court,
    required this.meta,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;
  final _CourtSectionMeta meta;

  @override
  State<_CourtBasicInfoSubsection> createState() =>
      _CourtBasicInfoSubsectionState();
}

class _CourtBasicInfoSubsectionState extends State<_CourtBasicInfoSubsection> {
  late final PublicCourtOptionsBloc _optionsBloc;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _basePriceFocus = FocusNode();
  final FocusNode _maxPlayersFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _optionsBloc = PublicCourtOptionsBloc(
      GetCourtOptionsUseCase(PublicRepositoryImpl()),
    )..add(const FetchPublicCourtOptionsEvent());
    widget.cubit.focusInvalidFieldRequest.addListener(
      _handleFocusInvalidRequest,
    );
  }

  void _handleFocusInvalidRequest() {
    final String? raw = widget.cubit.focusInvalidFieldRequest.value;
    if (raw == null) return;
    if (raw.split('#').first !=
        VendorOnboardingValidator.courtSubstepKey(widget.court.id, 0, 0)) {
      return;
    }
    final CourtDraft? court = widget.cubit.state.activeCourt;
    if (court == null) return;
    final FocusNode? target = court.name.trim().isEmpty
        ? _nameFocus
        : court.basePrice == null
        ? _basePriceFocus
        : null;
    if (target == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) target.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.cubit.focusInvalidFieldRequest.removeListener(
      _handleFocusInvalidRequest,
    );
    _nameFocus.dispose();
    _basePriceFocus.dispose();
    _maxPlayersFocus.dispose();
    _optionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PublicCourtOptionsBloc>.value(
      value: _optionsBloc,
      child: _CourtBasicInfoForm(
        cubit: widget.cubit,
        court: widget.court,
        meta: widget.meta,
        nameFocus: _nameFocus,
        basePriceFocus: _basePriceFocus,
        maxPlayersFocus: _maxPlayersFocus,
      ),
    );
  }
}

class _CourtBasicInfoForm extends StatelessWidget {
  const _CourtBasicInfoForm({
    required this.cubit,
    required this.court,
    required this.meta,
    required this.nameFocus,
    required this.basePriceFocus,
    required this.maxPlayersFocus,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;
  final _CourtSectionMeta meta;
  final FocusNode nameFocus;
  final FocusNode basePriceFocus;
  final FocusNode maxPlayersFocus;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PublicCourtOptionsBloc, PublicCourtOptionsState>(
      listenWhen:
          (PublicCourtOptionsState previous, PublicCourtOptionsState current) {
            return previous.courtTypes != current.courtTypes ||
                previous.matchFormats != current.matchFormats;
          },
      listener: (BuildContext context, PublicCourtOptionsState state) {
        _syncCourtOptions(state);
      },
      child: VendorPanel(
        padding: AppUtils().getPadding(all: AppDimens.paddingX12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            VendorOnboardingSectionHeader(
              title: meta.title,
              subtitle: meta.subtitle,
              icon: meta.icon,
            ),
            const SizedBox(height: AppDimens.sizeX22),
            VendorInputField(
              label: StringConstants.courtName,
              isRequired: true,
              focusNode: nameFocus,
              ensureVisibleOnFocus: true,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => basePriceFocus.requestFocus(),
              initialValue: court.name,
              onChanged: (String value) =>
                  cubit.updateActiveCourt(court.copyWith(name: value)),
            ),
            const SizedBox(height: AppDimens.sizeX16),
            VendorInputField(
              label: StringConstants.basePrice,
              isRequired: true,
              focusNode: basePriceFocus,
              ensureVisibleOnFocus: true,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => maxPlayersFocus.requestFocus(),
              initialValue: formatDouble(court.basePrice),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (String value) => cubit.setCourtBasePrice(
                value.trim().isEmpty ? null : parseDouble(value),
              ),
            ),
            const SizedBox(height: AppDimens.sizeX16),
            BlocBuilder<PublicCourtOptionsBloc, PublicCourtOptionsState>(
              builder: (BuildContext context, PublicCourtOptionsState state) {
                final List<PublicOptionModel> options = _options(
                  state.courtTypes,
                  fallback: _fallbackCourtTypes,
                );
                return VendorDropdownField<int>(
                  label: StringConstants.courtTypeSentenceCase,
                  hintText: state.status == PublicCourtOptionsStatus.loading
                      ? 'Loading court types...'
                      : null,
                  initialValue: _selectedId(court.courtTypeId, options),
                  items: _dropdownItems(options),
                  onChanged: (int? value) => cubit.updateActiveCourt(
                    court.copyWith(
                      courtTypeId: value,
                      courtType: _optionLabel(value, options),
                      clearCourtTypeId: value == null,
                      clearCourtType: value == null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimens.sizeX16),
            BlocBuilder<PublicCourtOptionsBloc, PublicCourtOptionsState>(
              builder: (BuildContext context, PublicCourtOptionsState state) {
                final List<PublicOptionModel> options = _options(
                  state.matchFormats,
                  fallback: _fallbackMatchFormats,
                );
                return VendorDropdownField<int>(
                  label: StringConstants.matchFormat,
                  hintText: state.status == PublicCourtOptionsStatus.loading
                      ? 'Loading match formats...'
                      : null,
                  initialValue: _selectedId(court.matchFormatId, options),
                  items: _dropdownItems(options),
                  onChanged: (int? value) => cubit.updateActiveCourt(
                    court.copyWith(
                      matchFormatId: value,
                      matchFormat: _optionLabel(value, options),
                      clearMatchFormatId: value == null,
                      clearMatchFormat: value == null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimens.sizeX16),
            VendorInputField(
              label: StringConstants.maxPlayers,
              isRequired: true,
              focusNode: maxPlayersFocus,
              ensureVisibleOnFocus: true,
              textInputAction: TextInputAction.done,
              initialValue: formatInt(court.maxPlayers),
              keyboardType: TextInputType.number,
              onChanged: (String value) => cubit.updateActiveCourt(
                court.copyWith(
                  maxPlayers: parseInt(value),
                  clearMaxPlayers: value.trim().isEmpty,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.sizeX16),
            _CourtStatusToggle(
              isActive: court.isActive,
              onChanged: (bool value) =>
                  cubit.updateActiveCourt(court.copyWith(isActive: value)),
            ),
            const SizedBox(height: AppDimens.sizeX16),
          ],
        ),
      ),
    );
  }

  void _syncCourtOptions(PublicCourtOptionsState state) {
    final List<PublicOptionModel> courtTypes = _options(
      state.courtTypes,
      fallback: const <PublicOptionModel>[],
    );
    final List<PublicOptionModel> matchFormats = _options(
      state.matchFormats,
      fallback: const <PublicOptionModel>[],
    );

    final PublicOptionModel? nextCourtType = _resolvedOptionValue(
      court.courtTypeId,
      court.courtType,
      courtTypes,
    );
    final PublicOptionModel? nextMatchFormat = _resolvedOptionValue(
      court.matchFormatId,
      court.matchFormat,
      matchFormats,
    );

    if (nextCourtType == null && nextMatchFormat == null) return;

    cubit.updateActiveCourt(
      court.copyWith(
        courtTypeId: nextCourtType?.idAsInt,
        courtType: nextCourtType?.name,
        matchFormatId: nextMatchFormat?.idAsInt,
        matchFormat: nextMatchFormat?.name,
      ),
    );
  }

  List<PublicOptionModel> _options(
    List<PublicOptionModel> models, {
    required List<PublicOptionModel> fallback,
  }) {
    final List<PublicOptionModel> options = models
        .where(
          (PublicOptionModel item) =>
              item.name.trim().isNotEmpty && item.idAsInt != null,
        )
        .toList(growable: false);
    return options.isEmpty ? fallback : options;
  }

  List<DropdownMenuItem<int>> _dropdownItems(List<PublicOptionModel> options) {
    return options
        .map(
          (PublicOptionModel item) => DropdownMenuItem<int>(
            value: item.idAsInt,
            child: Text(item.name),
          ),
        )
        .toList(growable: false);
  }

  int? _selectedId(int? value, List<PublicOptionModel> options) {
    if (value == null) return null;
    return options.any((PublicOptionModel item) => item.idAsInt == value)
        ? value
        : null;
  }

  String? _optionLabel(int? id, List<PublicOptionModel> options) {
    if (id == null) return null;
    return options
        .where((PublicOptionModel item) => item.idAsInt == id)
        .firstOrNull
        ?.name;
  }

  PublicOptionModel? _resolvedOptionValue(
    int? currentValue,
    String? currentLabel,
    List<PublicOptionModel> options,
  ) {
    if (options.isEmpty) return null;
    if (currentValue != null) {
      final PublicOptionModel? currentOption = options
          .where((PublicOptionModel item) => item.idAsInt == currentValue)
          .firstOrNull;
      if (currentOption != null) {
        return currentOption.name == currentLabel?.trim()
            ? null
            : currentOption;
      }
    }
    return options.first;
  }
}

class _CourtStatusToggle extends StatelessWidget {
  const _CourtStatusToggle({required this.isActive, required this.onChanged});

  final bool isActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.borderColor, width: 0.7),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  StringConstants.courtStatus,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  StringConstants.inactiveCourtsAreHiddenFromPlayers,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.sizeX12),
          Text(
            isActive ? StringConstants.active : StringConstants.inactive,
            style: textTheme.bodyTextSmall?.copyWith(
              color: isActive
                  ? LightColor.brandTextColor
                  : LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX8),
          CustomSwitchWidget(value: isActive, onChanged: onChanged),
        ],
      ),
    );
  }
}

const List<PublicOptionModel> _fallbackCourtTypes = <PublicOptionModel>[
  PublicOptionModel(id: '1', name: 'Indoor', raw: <String, dynamic>{}),
  PublicOptionModel(id: '2', name: 'Outdoor', raw: <String, dynamic>{}),
];

const List<PublicOptionModel> _fallbackMatchFormats = <PublicOptionModel>[
  PublicOptionModel(id: '1', name: '5v5', raw: <String, dynamic>{}),
  PublicOptionModel(id: '2', name: '6v6', raw: <String, dynamic>{}),
  PublicOptionModel(id: '3', name: '7v7', raw: <String, dynamic>{}),
];

class _CourtDescriptionSubsection extends StatefulWidget {
  const _CourtDescriptionSubsection({
    required this.cubit,
    required this.court,
    required this.meta,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;
  final _CourtSectionMeta meta;

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
    _initializeEditor();
  }

  @override
  void didUpdateWidget(covariant _CourtDescriptionSubsection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.court.description != widget.court.description &&
        _initialized &&
        widget.court.description != _lastHtmlContent) {
      _replaceEditorContent(widget.court.description);
    }
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
    final Document document = _buildDocumentFromHtml(html);

    return QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void _onEditorChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _debounceTimer = null;

      final delta = _quillController.document.toDelta();
      final String htmlConverter = QuillDeltaToHtmlConverter(
        delta.toJson(),
      ).convert();

      if (htmlConverter != _lastHtmlContent) {
        _lastHtmlContent = htmlConverter;
        widget.cubit.updateActiveCourt(
          widget.court.copyWith(description: htmlConverter),
        );
      }
    });
  }

  void _flushPendingChanges() {
    if (!_initialized || _debounceTimer == null) return;

    final delta = _quillController.document.toDelta();
    final String htmlConverter = QuillDeltaToHtmlConverter(
      delta.toJson(),
    ).convert();

    if (htmlConverter == _lastHtmlContent) return;
    _lastHtmlContent = htmlConverter;
    widget.cubit.updateActiveCourt(
      widget.cubit.state.activeCourt?.copyWith(description: htmlConverter) ??
          widget.court.copyWith(description: htmlConverter),
    );
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

  void _resetDescription(String html) {
    final String normalized = html.trim();
    if (normalized.isEmpty) return;

    if (_initialized) {
      _replaceEditorContent(normalized);
    }

    widget.cubit.updateActiveCourt(
      widget.cubit.state.activeCourt?.copyWith(description: normalized) ??
          widget.court.copyWith(description: normalized),
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
    final String? defaultDescription = context.select((
      PublicTemplatesBloc bloc,
    ) {
      return templateDefaultFor(
        bloc.state.templates,
        VendorTemplateField.courtDescription,
      );
    });

    return VendorPanel(
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VendorOnboardingSectionHeader(
            title: widget.meta.title,
            subtitle: widget.meta.subtitle,
            icon: widget.meta.icon,
            trailing:
                defaultDescription != null &&
                    defaultDescription.trim().isNotEmpty
                ? VendorTemplateResetButton(
                    onTap: () => _resetDescription(defaultDescription),
                  )
                : null,
          ),
          const SizedBox(height: AppDimens.sizeX12),
          if (!_initialized)
            const SizedBox(height: 450, child: Center(child: LoadingWidget()))
          else
            SizedBox(
              height: 450,
              child: CustomQuillEditor(
                isReadOnly: false,
                controller: _quillController,
                scrollController: _scrollController,
                hintText: StringConstants.descriptionAboutYourCourt,
              ),
            ),
        ],
      ),
    );
  }
}

class _CourtSectionMeta {
  const _CourtSectionMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
