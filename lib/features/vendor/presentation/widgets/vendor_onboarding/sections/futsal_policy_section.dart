import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_quill_editor.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_templates/public_templates_bloc.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/utils/vendor_template_defaults.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/sections/futsal_plan_selection_widget.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class FutsalPolicySection extends StatefulWidget {
  const FutsalPolicySection({
    super.key,
    required this.cubit,
    required this.draft,
    required this.subsectionIndex,
  });

  final VendorOnboardingCubit cubit;
  final FutsalDraft draft;
  final int subsectionIndex;

  @override
  State<FutsalPolicySection> createState() => _FutsalPolicySectionState();
}

class _FutsalPolicySectionState extends State<FutsalPolicySection> {
  final ScrollController _policyScrollController = ScrollController();
  final ScrollController _rulesScrollController = ScrollController();

  late final QuillController _policyQuillController;
  late final QuillController _rulesQuillController;

  Timer? _policyDebounceTimer;
  Timer? _rulesDebounceTimer;

  String _lastPolicyHtml = '';
  String _lastRulesHtml = '';

  bool _policyInitialized = false;
  bool _rulesInitialized = false;
  bool _isFlushRegistered = false;
  final Object _flushOwner = Object();

  @override
  void initState() {
    super.initState();
    _lastPolicyHtml = widget.draft.cancellationPolicy;
    _lastRulesHtml = widget.draft.futsalRules;

    if (_usesRichTextEditors(widget.subsectionIndex)) {
      _registerFlush();
      _initializeEditorForSubsection(widget.subsectionIndex);
    }
  }

  bool _usesRichTextEditors(int index) => index == 0 || index == 1;

  @override
  void didUpdateWidget(covariant FutsalPolicySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subsectionIndex != widget.subsectionIndex) {
      if (_usesRichTextEditors(oldWidget.subsectionIndex)) {
        _flushPendingChangesFor(oldWidget.subsectionIndex);
      }
      if (_usesRichTextEditors(widget.subsectionIndex)) {
        _registerFlush();
        _initializeEditorForSubsection(widget.subsectionIndex);
      } else {
        _unregisterFlush();
      }
    }

    if (oldWidget.draft.cancellationPolicy != widget.draft.cancellationPolicy &&
        _policyInitialized) {
      if (widget.draft.cancellationPolicy != _lastPolicyHtml) {
        _replacePolicyContent(widget.draft.cancellationPolicy);
      }
    }
    if (oldWidget.draft.futsalRules != widget.draft.futsalRules &&
        _rulesInitialized) {
      if (widget.draft.futsalRules != _lastRulesHtml) {
        _replaceRulesContent(widget.draft.futsalRules);
      }
    }
  }

  void _registerFlush() {
    if (_isFlushRegistered) return;
    widget.cubit.registerActiveEditorFlush(_flushOwner, _flushPendingChanges);
    _isFlushRegistered = true;
  }

  void _unregisterFlush() {
    if (!_isFlushRegistered) return;
    widget.cubit.unregisterActiveEditorFlush(_flushOwner);
    _isFlushRegistered = false;
  }

  void _initializeEditorForSubsection(int subsectionIndex) {
    if (subsectionIndex == 0 && !_policyInitialized) {
      _policyQuillController = _initializeQuillController(
        html: widget.draft.cancellationPolicy,
      );
      _policyQuillController.addListener(_onPolicyChanged);
      setState(() => _policyInitialized = true);
      return;
    }

    if (subsectionIndex == 1 && !_rulesInitialized) {
      _rulesQuillController = _initializeQuillController(
        html: widget.draft.futsalRules,
      );
      _rulesQuillController.addListener(_onRulesChanged);
      setState(() => _rulesInitialized = true);
    }
  }

  void _replacePolicyContent(String html) {
    _lastPolicyHtml = html;
    final Document document = _buildDocumentFromHtml(html);
    _policyQuillController.document = document;
    _policyQuillController.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
  }

  void _replaceRulesContent(String html) {
    _lastRulesHtml = html;
    final Document document = _buildDocumentFromHtml(html);
    _rulesQuillController.document = document;
    _rulesQuillController.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
  }

  void _onPolicyChanged() {
    _policyDebounceTimer?.cancel();
    _policyDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _policyDebounceTimer = null;

      final delta = _policyQuillController.document.toDelta();
      final String htmlConverter = QuillDeltaToHtmlConverter(
        delta.toJson(),
      ).convert();

      if (htmlConverter != _lastPolicyHtml) {
        _lastPolicyHtml = htmlConverter;
        widget.cubit.updateFutsal(
          widget.draft.copyWith(cancellationPolicy: htmlConverter),
        );
      }
    });
  }

  void _onRulesChanged() {
    _rulesDebounceTimer?.cancel();
    _rulesDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _rulesDebounceTimer = null;

      final delta = _rulesQuillController.document.toDelta();
      final String htmlConverter = QuillDeltaToHtmlConverter(
        delta.toJson(),
      ).convert();

      if (htmlConverter != _lastRulesHtml) {
        _lastRulesHtml = htmlConverter;
        widget.cubit.updateFutsal(
          widget.draft.copyWith(futsalRules: htmlConverter),
        );
      }
    });
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
      final delta = HtmlToDelta().convert(html);
      return Document.fromDelta(delta);
    }
    return Document();
  }

  void _flushPendingChanges() {
    _flushPendingChangesFor(widget.subsectionIndex);
  }

  void _flushPendingChangesFor(int subsectionIndex) {
    final FutsalDraft current = widget.cubit.state.futsal;

    if (subsectionIndex == 0 &&
        _policyInitialized &&
        _policyDebounceTimer != null) {
      final delta = _policyQuillController.document.toDelta();
      final String html = QuillDeltaToHtmlConverter(delta.toJson()).convert();
      if (html != _lastPolicyHtml) {
        _lastPolicyHtml = html;
        widget.cubit.updateFutsal(current.copyWith(cancellationPolicy: html));
      }
    }

    if (subsectionIndex == 1 &&
        _rulesInitialized &&
        _rulesDebounceTimer != null) {
      final delta = _rulesQuillController.document.toDelta();
      final String html = QuillDeltaToHtmlConverter(delta.toJson()).convert();
      if (html != _lastRulesHtml) {
        _lastRulesHtml = html;
        widget.cubit.updateFutsal(current.copyWith(futsalRules: html));
      }
    }
  }

  void _resetCancellationPolicy(String html) {
    final String normalized = html.trim();
    if (normalized.isEmpty) return;

    if (_policyInitialized) {
      _replacePolicyContent(normalized);
    }

    widget.cubit.updateFutsal(
      widget.cubit.state.futsal.copyWith(cancellationPolicy: normalized),
    );
  }

  void _resetFutsalRules(String html) {
    final String normalized = html.trim();
    if (normalized.isEmpty) return;

    if (_rulesInitialized) {
      _replaceRulesContent(normalized);
    }

    widget.cubit.updateFutsal(
      widget.cubit.state.futsal.copyWith(futsalRules: normalized),
    );
  }

  @override
  void dispose() {
    _flushPendingChanges();
    _unregisterFlush();
    _policyDebounceTimer?.cancel();
    _rulesDebounceTimer?.cancel();

    if (_policyInitialized) {
      _policyQuillController.removeListener(_onPolicyChanged);
      _policyQuillController.dispose();
    }
    if (_rulesInitialized) {
      _rulesQuillController.removeListener(_onRulesChanged);
      _rulesQuillController.dispose();
    }

    _policyScrollController.dispose();
    _rulesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = _sectionMeta(widget.subsectionIndex);
    final List<String?> templateDefaults = context.select((
      PublicTemplatesBloc bloc,
    ) {
      return <String?>[
        templateDefaultFor(
          bloc.state.templates,
          VendorTemplateField.cancellationPolicy,
        ),
        templateDefaultFor(
          bloc.state.templates,
          VendorTemplateField.futsalRules,
        ),
      ];
    });
    final String? defaultCancellationPolicy = templateDefaults[0];
    final String? defaultFutsalRules = templateDefaults[1];

    return VendorPanel(
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VendorOnboardingSectionHeader(
            title: meta.title,
            subtitle: meta.subtitle,
            icon: meta.icon,
            trailing: switch (widget.subsectionIndex) {
              0
                  when defaultCancellationPolicy != null &&
                      defaultCancellationPolicy.trim().isNotEmpty =>
                _TemplateResetButton(
                  onTap: () =>
                      _resetCancellationPolicy(defaultCancellationPolicy),
                ),
              1
                  when defaultFutsalRules != null &&
                      defaultFutsalRules.trim().isNotEmpty =>
                _TemplateResetButton(
                  onTap: () => _resetFutsalRules(defaultFutsalRules),
                ),
              _ => null,
            },
          ),
          const SizedBox(height: AppDimens.sizeX12),
          if (widget.subsectionIndex == 0) _buildCancellationPolicy(),
          if (widget.subsectionIndex == 1) _buildFutsalRules(),
          if (widget.subsectionIndex == 2) const FutsalPlanSelectionWidget(),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicy() {
    if (!_policyInitialized) {
      return const SizedBox(height: 450, child: Center(child: LoadingWidget()));
    }
    return SizedBox(
      height: 450,
      child: CustomQuillEditor(
        isReadOnly: false,
        controller: _policyQuillController,
        scrollController: _policyScrollController,
        hintText: StringConstants.describeYourCancellationAndRefundPolicy,
      ),
    );
  }

  Widget _buildFutsalRules() {
    if (!_rulesInitialized) {
      return const SizedBox(height: 450, child: Center(child: LoadingWidget()));
    }
    return SizedBox(
      height: 450,
      child: CustomQuillEditor(
        isReadOnly: false,
        controller: _rulesQuillController,
        scrollController: _rulesScrollController,
        hintText: StringConstants.listYourFutsalHouseRulesForPlayers,
      ),
    );
  }

  _PolicySectionMeta _sectionMeta(int index) {
    switch (index) {
      case 0:
        return const _PolicySectionMeta(
          title: StringConstants.refundCancellationPolicyCompact,
          subtitle:
              StringConstants.refundCancellationAndCustomerBookingGuidelines,
          icon: Icons.policy_rounded,
        );
      case 1:
        return const _PolicySectionMeta(
          title: StringConstants.futsalRules,
          subtitle: StringConstants.venueRulesAndPlayerConductDetails,
          icon: Icons.rule_rounded,
        );
      case 2:
        return const _PolicySectionMeta(
          title: StringConstants.chooseYourPlan,
          subtitle: StringConstants.commissionPackageAndPlatformSupportDetails,
          icon: Icons.workspace_premium_rounded,
        );
      default:
        return const _PolicySectionMeta(
          title: StringConstants.policyAndRules,
          subtitle: StringConstants.completeTheRequiredDetails,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _TemplateResetButton extends StatelessWidget {
  const _TemplateResetButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: StringConstants.resetToDefaultTemplate,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: AppDimens.sizeX30,
          height: AppDimens.sizeX30,
          decoration: BoxDecoration(
            color: LightColor.secondaryLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            Icons.refresh_rounded,
            size: AppDimens.sizeX16,
            color: LightColor.inverseTextColor,
          ),
        ),
      ),
    );
  }
}

class _PolicySectionMeta {
  const _PolicySectionMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
