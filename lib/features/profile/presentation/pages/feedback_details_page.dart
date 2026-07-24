import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/features/profile/data/model/feedback_history_model.dart';
import 'package:hamro_footsall/features/profile/data/repositories/feedback_repository_impl.dart';

class FeedbackDetailsPage extends StatefulWidget {
  const FeedbackDetailsPage({super.key, required this.feedbackId});

  final String feedbackId;

  @override
  State<FeedbackDetailsPage> createState() => _FeedbackDetailsPageState();
}

class _FeedbackDetailsPageState extends State<FeedbackDetailsPage> {
  static final FeedbackRepositoryImpl _repository = FeedbackRepositoryImpl();

  bool _isLoading = true;
  String? _errorMessage;
  FeedbackDetailsModel? _details;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.feedbackId.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Feedback details could not be opened.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.getFeedbackDetails(widget.feedbackId);
    if (!mounted) return;

    result.fold(
      (error) => setState(() {
        _isLoading = false;
        _errorMessage = error.errorMessage;
      }),
      (details) => setState(() {
        _isLoading = false;
        _details = details;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Feedback Details'),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: LightColor.secondaryColor,
                ),
              )
            : _errorMessage != null
            ? _DetailsError(message: _errorMessage!, onRetry: _load)
            : _DetailsContent(item: _details!.item),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({required this.item});

  final FeedbackListItem item;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        _parseHexColor(item.typeColorHex) ?? LightColor.secondaryColor;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppDimens.paddingX18),
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX18),
            border: Border.all(color: LightColor.dividerColor),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _DetailsTag(
                    label: item.categoryName.isEmpty
                        ? 'Category'
                        : item.categoryName,
                    background: LightColor.secondaryColor.withValues(
                      alpha: 0.08,
                    ),
                    foreground: LightColor.secondaryColor,
                  ),
                  _DetailsTag(
                    label: item.typeName.isEmpty ? 'Type' : item.typeName,
                    background: accent.withValues(alpha: 0.10),
                    foreground: accent,
                  ),
                  if (item.status.isNotEmpty)
                    _DetailsTag(
                      label: item.status,
                      background: LightColor.background,
                      foreground: LightColor.secondaryTextColor,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailsSection(
                label: 'Submitted on',
                value: _formatDateTime(item.createdAt),
              ),
              const SizedBox(height: 16),
              _DetailsSection(
                label: 'Rating',
                customValue: Row(
                  children: List<Widget>.generate(5, (index) {
                    final bool selected = index < item.rating;
                    return Padding(
                      padding: EdgeInsets.only(right: index == 4 ? 0 : 4),
                      child: Icon(
                        selected
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 20,
                        color: selected
                            ? LightColor.warningColor
                            : LightColor.hintTextColor,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              _DetailsSection(
                label: 'Message',
                value: item.message,
                multiline: true,
              ),
              if ((item.contactInfo ?? '').isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                _DetailsSection(
                  label: 'Contact info',
                  value: item.contactInfo!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.label,
    this.value,
    this.customValue,
    this.multiline = false,
  });

  final String label;
  final String? value;
  final Widget? customValue;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        customValue ??
            Text(
              value ?? '',
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.primaryTextColor,
                height: multiline ? 1.5 : 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
      ],
    );
  }
}

class _DetailsTag extends StatelessWidget {
  const _DetailsTag({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX50),
      ),
      child: Text(
        label,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: LightColor.redColor,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: LightColor.secondaryColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) return '-';
  return DateFormat('dd MMM yyyy, hh:mm a').format(value);
}

Color? _parseHexColor(String value) {
  final String normalized = value.trim().replaceFirst('#', '');
  if (normalized.isEmpty) return null;
  final String hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  if (hex.length != 8) return null;
  final int? parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? null : Color(parsed);
}
