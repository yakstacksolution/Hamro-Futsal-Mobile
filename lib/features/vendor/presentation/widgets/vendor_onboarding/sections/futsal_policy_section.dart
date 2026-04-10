import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/widgets/custom_quill_editor.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

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
  final Object _flushOwner = Object();

  @override
  void initState() {
    super.initState();
    _lastPolicyHtml = widget.draft.cancellationPolicy;
    _lastRulesHtml = widget.draft.futsalRules;

    widget.cubit.registerActiveEditorFlush(_flushOwner, _flushPendingChanges);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEditors();
    });
  }

  @override
  void didUpdateWidget(covariant FutsalPolicySection oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  void _initializeEditors() {
    // Initialize cancellation policy editor
    _policyQuillController = _initializeQuillController(
      html: widget.draft.cancellationPolicy,
    );
    _policyQuillController.addListener(_onPolicyChanged);
    setState(() => _policyInitialized = true);

    // Initialize futsal rules editor
    _rulesQuillController = _initializeQuillController(
      html: widget.draft.futsalRules,
    );
    _rulesQuillController.addListener(_onRulesChanged);
    setState(() => _rulesInitialized = true);
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

      final delta = _policyQuillController.document.toDelta();
      final String htmlConverter =
          QuillDeltaToHtmlConverter(delta.toJson()).convert();

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

      final delta = _rulesQuillController.document.toDelta();
      final String htmlConverter =
          QuillDeltaToHtmlConverter(delta.toJson()).convert();

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
    final FutsalDraft current = widget.cubit.state.futsal;

    if (_policyInitialized) {
      final delta = _policyQuillController.document.toDelta();
      final String html =
          QuillDeltaToHtmlConverter(delta.toJson()).convert();
      if (html != _lastPolicyHtml) {
        _lastPolicyHtml = html;
        widget.cubit.updateFutsal(current.copyWith(cancellationPolicy: html));
      }
    }

    if (_rulesInitialized) {
      final delta = _rulesQuillController.document.toDelta();
      final String html =
          QuillDeltaToHtmlConverter(delta.toJson()).convert();
      if (html != _lastRulesHtml) {
        _lastRulesHtml = html;
        widget.cubit.updateFutsal(current.copyWith(futsalRules: html));
      }
    }
  }

  @override
  void dispose() {
    _flushPendingChanges();
    widget.cubit.unregisterActiveEditorFlush(_flushOwner);
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

    return VendorPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CompactPolicySectionHeader(meta: meta),
          const SizedBox(height: 12),
          if (widget.subsectionIndex == 0) _buildCancellationPolicy(),
          if (widget.subsectionIndex == 1) _buildFutsalRules(),
          if (widget.subsectionIndex == 2) _buildCommissionPackages(),
        ],
      ),
    );
  }

  Widget _buildCommissionPackages() {
    final selectedPercent = widget.draft.commissionPercent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _CommissionPackageCard(
              title: 'Basic',
              percentage: 5,
              isSelected: selectedPercent == 5,
              icon: Icons.rocket_launch_rounded,
              color: LightColor.primary,
              features: const [
                'Basic listing',
                'Standard visibility',
                'Email support',
              ],
              onTap: () => widget.cubit.updateFutsal(
                widget.draft.copyWith(commissionPercent: 5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CommissionPackageCard(
              title: 'Standard',
              percentage: 10,
              isSelected: selectedPercent == 10,
              icon: Icons.star_rounded,
              color: LightColor.secondary,
              isRecommended: true,
              features: const [
                'Priority support',
                'Featured listing',
                'Activity logs',
                'Detailed reports',
              ],
              onTap: () => widget.cubit.updateFutsal(
                widget.draft.copyWith(commissionPercent: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicy() {
    if (!_policyInitialized) {
      return const SizedBox(
        height: 450,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return SizedBox(
      height: 450,
      child: CustomQuillEditor(
        isReadOnly: false,
        controller: _policyQuillController,
        scrollController: _policyScrollController,
        hintText: 'Describe your cancellation and refund policy...',
      ),
    );
  }

  Widget _buildFutsalRules() {
    if (!_rulesInitialized) {
      return const SizedBox(
        height: 450,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return SizedBox(
      height: 450,
      child: CustomQuillEditor(
        isReadOnly: false,
        controller: _rulesQuillController,
        scrollController: _rulesScrollController,
        hintText: 'List your futsal house rules for players...',
      ),
    );
  }

  _PolicySectionMeta _sectionMeta(int index) {
    switch (index) {
      case 0:
        return const _PolicySectionMeta(
          title: 'Cancellation Policy',
          subtitle:
              'Define how refunds and booking cancellations are handled for your customers.',
          icon: Icons.policy_rounded,
        );
      case 1:
        return const _PolicySectionMeta(
          title: 'Futsal Rules',
          subtitle: 'Set house rules for players, bookings, and venue conduct.',
          icon: Icons.rule_rounded,
        );
      case 2:
        return const _PolicySectionMeta(
          title: 'Choose Your Plan',
          subtitle:
              'Select a commission package that fits your business needs.',
          icon: Icons.workspace_premium_rounded,
        );
      default:
        return const _PolicySectionMeta(
          title: 'Policy & Rules',
          subtitle: 'Complete the required details.',
          icon: Icons.info_rounded,
        );
    }
  }
}

class _CompactPolicySectionHeader extends StatelessWidget {
  const _CompactPolicySectionHeader({required this.meta});

  final _PolicySectionMeta meta;

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

class _CommissionPackageCard extends StatelessWidget {
  const _CommissionPackageCard({
    required this.title,
    required this.percentage,
    required this.isSelected,
    required this.icon,
    required this.color,
    required this.features,
    required this.onTap,
    this.isRecommended = false,
  });

  final String title;
  final double percentage;
  final bool isSelected;
  final IconData icon;
  final Color color;
  final List<String> features;
  final VoidCallback onTap;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${percentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        TextSpan(
                          text: ' / booking',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: isSelected ? color : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isRecommended)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Popular',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
