import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/features/profile/data/model/feedback_history_model.dart';
import 'package:hamro_futsal/features/profile/data/repositories/feedback_repository_impl.dart';

class MyFeedbackPage extends StatefulWidget {
  const MyFeedbackPage({super.key});

  @override
  State<MyFeedbackPage> createState() => _MyFeedbackPageState();
}

class _MyFeedbackPageState extends State<MyFeedbackPage> {
  static final FeedbackRepositoryImpl _repository = FeedbackRepositoryImpl();

  bool _isLoading = true;
  String? _errorMessage;
  FeedbackListPage _page = const FeedbackListPage(items: <FeedbackListItem>[]);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.getMyFeedback(perPage: 15);
    if (!mounted) return;

    result.fold(
      (error) => setState(() {
        _isLoading = false;
        _errorMessage = error.errorMessage;
      }),
      (page) => setState(() {
        _isLoading = false;
        _page = page;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'My Feedback'),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const _FeedbackHistoryLoading()
            : _errorMessage != null
            ? _FeedbackHistoryError(message: _errorMessage!, onRetry: _load)
            : _page.items.isEmpty
            ? const _FeedbackHistoryEmpty()
            : RefreshIndicator(
                color: LightColor.secondaryColor,
                onRefresh: _load,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  itemCount: _page.items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppDimens.paddingX12),
                  itemBuilder: (context, index) {
                    final FeedbackListItem item = _page.items[index];
                    return _FeedbackListCard(
                      item: item,
                      onTap: () => context.pushNamed(
                        AppRouterParams.feedbackDetails.name,
                        extra: item.id,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _FeedbackListCard extends StatelessWidget {
  const _FeedbackListCard({required this.item, required this.onTap});

  final FeedbackListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color accent =
        _parseHexColor(item.typeColorHex) ?? LightColor.secondaryColor;

    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimens.paddingX16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX16),
            border: Border.all(color: LightColor.dividerColor),
            boxShadow: <BoxShadow>[
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _FeedbackTag(
                          label: item.categoryName.isEmpty
                              ? 'Category'
                              : item.categoryName,
                          background: LightColor.secondaryColor.withValues(
                            alpha: 0.08,
                          ),
                          foreground: LightColor.secondaryColor,
                        ),
                        _FeedbackTag(
                          label: item.typeName.isEmpty ? 'Type' : item.typeName,
                          background: accent.withValues(alpha: 0.10),
                          foreground: accent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX12),
                  Text(
                    _formatDate(item.createdAt),
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.paddingX12),
              Text(
                item.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.primaryTextColor,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX14),
              Row(
                children: <Widget>[
                  _StarRow(rating: item.rating),
                  const Spacer(),
                  Text(
                    'View details',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: LightColor.secondaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackTag extends StatelessWidget {
  const _FeedbackTag({
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

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(5, (index) {
        final bool selected = index < rating;
        return Padding(
          padding: EdgeInsets.only(right: index == 4 ? 0 : 4),
          child: Icon(
            selected ? Icons.star_rounded : Icons.star_border_rounded,
            size: 18,
            color: selected
                ? LightColor.warningColor
                : LightColor.hintTextColor,
          ),
        );
      }),
    );
  }
}

class _FeedbackHistoryLoading extends StatelessWidget {
  const _FeedbackHistoryLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 138,
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX16),
          border: Border.all(color: LightColor.dividerColor),
        ),
      ),
    );
  }
}

class _FeedbackHistoryError extends StatelessWidget {
  const _FeedbackHistoryError({required this.message, required this.onRetry});

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
            Icon(
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

class _FeedbackHistoryEmpty extends StatelessWidget {
  const _FeedbackHistoryEmpty();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rate_review_outlined,
                color: LightColor.secondaryColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No feedback yet',
              style: textTheme.bodyTextLarge?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your submitted feedback will appear here once you share it with us.',
              textAlign: TextAlign.center,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return DateFormat('dd MMM yyyy').format(value);
}

Color? _parseHexColor(String value) {
  final String normalized = value.trim().replaceFirst('#', '');
  if (normalized.isEmpty) return null;
  final String hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  if (hex.length != 8) return null;
  final int? parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? null : Color(parsed);
}
