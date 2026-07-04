import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_html_viewer.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/public/data/model/public_faq_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_help_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_faqs_use_case.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_helps_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/support/support_bloc.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Help & FAQ — two tabs backed by the public `GET /faqs` and `GET /helps`
/// endpoints, opened from the profile's Support section.
class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SupportBloc>(
      create: (_) {
        final PublicRepositoryImpl repository = PublicRepositoryImpl();
        return SupportBloc(
            GetFaqsUseCase(repository),
            GetHelpsUseCase(repository),
          )
          ..add(const FetchFaqsEvent())
          ..add(const FetchHelpsEvent());
      },
      child: const _HelpFaqView(),
    );
  }
}

class _HelpFaqView extends StatelessWidget {
  const _HelpFaqView();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: LightColor.background,
        appBar: const CustomAppBar(title: StringConstants.helpAndFaq),
        body: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              TabBar(
                labelColor: LightColor.secondaryColor,
                unselectedLabelColor: LightColor.secondaryTextColor,
                indicatorColor: LightColor.secondaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: LightColor.dividerColor,
                labelStyle: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                tabs: const <Widget>[
                  Tab(text: StringConstants.faqs, height: 40),
                  Tab(text: StringConstants.help, height: 40),
                ],
              ),
              Expanded(
                child: BlocBuilder<SupportBloc, SupportState>(
                  builder: (BuildContext context, SupportState state) {
                    return TabBarView(
                      children: <Widget>[
                        _SupportTab(
                          status: state.faqsStatus,
                          isEmpty: state.faqs.isEmpty,
                          errorMessage:
                              state.faqsError ?? 'Could not load FAQs.',
                          emptyTitle: 'No FAQs yet',
                          emptyMessage:
                              'Frequently asked questions will appear here.',
                          onRetry: () => context.read<SupportBloc>().add(
                            const FetchFaqsEvent(),
                          ),
                          child: _FaqList(faqs: state.faqs),
                        ),
                        _SupportTab(
                          status: state.helpsStatus,
                          isEmpty: state.helps.isEmpty,
                          errorMessage:
                              state.helpsError ?? 'Could not load help topics.',
                          emptyTitle: 'No help topics yet',
                          emptyMessage:
                              'Help and how-to guides will appear here.',
                          onRetry: () => context.read<SupportBloc>().add(
                            const FetchHelpsEvent(),
                          ),
                          child: _HelpList(helps: state.helps),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared loading / error / empty scaffolding for one tab.
class _SupportTab extends StatelessWidget {
  const _SupportTab({
    required this.status,
    required this.isEmpty,
    required this.errorMessage,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRetry,
    required this.child,
  });

  final SupportStatus status;
  final bool isEmpty;
  final String errorMessage;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (status == SupportStatus.initial || status == SupportStatus.loading) {
      return const Center(
        child: SizedBox(
          width: AppDimens.sizeX30,
          height: AppDimens.sizeX30,
          child: LoadingWidget(isTransparentBackground: true),
        ),
      );
    }
    if (status == SupportStatus.failure) {
      return _SupportMessage(
        icon: Icons.cloud_off_rounded,
        title: errorMessage,
        message: StringConstants.checkYourConnectionAndTryAgain,
        actionLabel: 'Retry',
        onAction: onRetry,
      );
    }
    if (isEmpty) {
      return _SupportMessage(
        icon: Icons.inbox_rounded,
        title: emptyTitle,
        message: emptyMessage,
      );
    }
    return child;
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList({required this.faqs});

  final List<PublicFaqModel> faqs;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX16,
      ),
      itemCount: faqs.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.paddingX10),
      itemBuilder: (BuildContext context, int index) =>
          _FaqTile(faq: faqs[index]),
    );
  }
}

/// Expandable question/answer card.
///
/// The surface (color + rounded border) is provided through the
/// [ExpansionTile.shape]/[ExpansionTile.collapsedShape] so the tile wraps its
/// own [Material]. Painting the background with an outer `Container` instead
/// would place a colored `DecoratedBox` between the inner `ListTile` and its
/// nearest `Material`, which trips the framework's
/// "ListTile background color or ink splashes may be invisible" assertion.
class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final PublicFaqModel faq;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final RoundedRectangleBorder tileShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      side: const BorderSide(color: LightColor.dividerColor),
    );

    return Theme(
      // Strip ExpansionTile's default top/bottom dividers; the rounded shape
      // already separates each card.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        clipBehavior: Clip.antiAlias,
        backgroundColor: LightColor.cardColor,
        collapsedBackgroundColor: LightColor.cardColor,
        shape: tileShape,
        collapsedShape: tileShape,
        tilePadding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX14,
          symmetricVertical: AppDimens.paddingX4,
        ),
        childrenPadding: AppUtils().getPadding(
          left: AppDimens.paddingX14,
          right: AppDimens.paddingX14,
          bottom: AppDimens.paddingX14,
        ),
        leading: Container(
          width: AppDimens.sizeX36,
          height: AppDimens.sizeX36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          ),
          child: const Icon(
            Icons.help_outline_rounded,
            size: AppDimens.sizeX18,
            color: LightColor.secondaryColor,
          ),
        ),
        iconColor: LightColor.secondaryColor,
        collapsedIconColor: LightColor.secondaryTextColor,
        title: Text(
          faq.question,
          style: textTheme.bodyTextMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: LightColor.primaryTextColor,
          ),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Divider(
            height: AppDimens.paddingX16,
            thickness: 1,
            color: LightColor.dividerColor,
          ),
          Text(
            faq.answer.isEmpty ? '—' : faq.answer,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpList extends StatelessWidget {
  const _HelpList({required this.helps});

  final List<PublicHelpModel> helps;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX16,
      ),
      itemCount: helps.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.paddingX10),
      itemBuilder: (BuildContext context, int index) =>
          _HelpTile(help: helps[index]),
    );
  }
}

/// Expandable help article. The body content arrives as HTML from the server,
/// so it is rendered with [CustomHtmlReader].
class _HelpTile extends StatelessWidget {
  const _HelpTile({required this.help});

  final PublicHelpModel help;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final RoundedRectangleBorder tileShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      side: const BorderSide(color: LightColor.dividerColor),
    );

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        clipBehavior: Clip.antiAlias,
        backgroundColor: LightColor.cardColor,
        collapsedBackgroundColor: LightColor.cardColor,
        shape: tileShape,
        collapsedShape: tileShape,
        tilePadding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX14,
          symmetricVertical: AppDimens.paddingX4,
        ),
        childrenPadding: AppUtils().getPadding(
          left: AppDimens.paddingX14,
          right: AppDimens.paddingX14,
          bottom: AppDimens.paddingX14,
        ),
        leading: Container(
          width: AppDimens.sizeX36,
          height: AppDimens.sizeX36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: AppDimens.sizeX18,
            color: LightColor.secondaryColor,
          ),
        ),
        iconColor: LightColor.secondaryColor,
        collapsedIconColor: LightColor.secondaryTextColor,
        title: Text(
          help.title,
          style: textTheme.bodyTextMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: LightColor.primaryTextColor,
          ),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Divider(
            height: AppDimens.paddingX16,
            thickness: 1,
            color: LightColor.dividerColor,
          ),
          if (help.description.isEmpty)
            Text(
              '—',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            )
          else
            CustomHtmlReader(
              html: help.description,
              textStyle: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _SupportMessage extends StatelessWidget {
  const _SupportMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: AppUtils().getPadding(all: AppDimens.paddingX24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: AppDimens.sizeX40, color: LightColor.iconGrey),
            const SizedBox(height: AppDimens.paddingX12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppDimens.paddingX16),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: LightColor.secondaryColor,
                  side: const BorderSide(color: LightColor.secondaryColor),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
