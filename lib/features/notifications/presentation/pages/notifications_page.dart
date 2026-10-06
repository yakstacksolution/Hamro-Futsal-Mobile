import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/features/notifications/data/model/notification_model.dart';
import 'package:hamro_futsal/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:hamro_futsal/features/notifications/domain/repository/notification_repository.dart';
import 'package:hamro_futsal/features/notifications/domain/usecase/notification_use_case.dart';
import 'package:hamro_futsal/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:hamro_futsal/features/notifications/presentation/widgets/notification_widgets.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, this.repository});

  final NotificationRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationBloc>(
      create: (_) => NotificationBloc(
        NotificationUseCase(repository ?? NotificationRepositoryImpl()),
      )..add(const FetchNotificationsEvent()),
      child: const _NotificationsView(),
    );
  }
}

const double _kFeedMaxWidth = 760;

double _feedGutter(BuildContext context) {
  if (!context.isTabletOrWider) return AppDimens.paddingX20;
  return math.max(
    AppDimens.paddingX24,
    (context.screenWidth - _kFeedMaxWidth) / 2,
  );
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  Future<void> _refresh(BuildContext context) async {
    final NotificationBloc bloc = context.read<NotificationBloc>();
    final int startTick = bloc.state.refreshTick;
    bloc.add(const FetchNotificationsEvent(silent: true));
    await bloc.stream
        .firstWhere((NotificationState s) => s.refreshTick != startTick)
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: StringConstants.notifications,
        actions: <Widget>[
          BlocBuilder<NotificationBloc, NotificationState>(
            buildWhen: (NotificationState p, NotificationState c) =>
                p.unreadCount != c.unreadCount,
            builder: (BuildContext context, NotificationState state) {
              // Tablet / desktop carry it in the feed's header instead.
              if (state.unreadCount == 0 || context.isTabletOrWider) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: AppDimens.paddingX8),
                child: Tooltip(
                  message: StringConstants.markAllAsRead,
                  child: IconButton(
                    key: const Key('mark-all-read-button'),
                    onPressed: () => context.read<NotificationBloc>().add(
                      const MarkAllNotificationsReadEvent(),
                    ),
                    icon: const Icon(
                      Icons.done_all_rounded,
                      color: LightColor.secondaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listenWhen: (NotificationState p, NotificationState c) =>
              p.errorMessage != c.errorMessage && c.errorMessage != null,
          listener: (BuildContext context, NotificationState state) {
            // Surface action errors (mark read/unread) as a snackbar. Load
            // failures already render a full error view below.
            if (state.status == NotificationStatus.success) {
              AppUtils().showSnackBar(
                context,
                MsgType.error,
                state.errorMessage ?? StringConstants.couldNotLoadNotifications,
              );
            }
          },
          builder: (BuildContext context, NotificationState state) {
            final Widget filterBar = NotificationFilterBar(
              selectedFilter: state.filter,
              unreadCount: state.unreadCount,
              onChanged: (NotificationFilter filter) => context
                  .read<NotificationBloc>()
                  .add(ChangeNotificationFilterEvent(filter)),
            );
            final bool wide = context.isTabletOrWider;
            final double side = _feedGutter(context);
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    side,
                    wide ? AppDimens.paddingX20 : AppDimens.paddingX10,
                    side,
                    wide ? AppDimens.paddingX16 : AppDimens.paddingX14,
                  ),
                  // Tablet / desktop: a compact switch on the left and the
                  // mark-all action on the right, on the feed's edges.
                  child: wide
                      ? Row(
                          children: <Widget>[
                            SizedBox(width: 280, child: filterBar),
                            const Spacer(),
                            if (state.unreadCount > 0)
                              TextButton.icon(
                                key: const Key('mark-all-read-button'),
                                onPressed: () => context
                                    .read<NotificationBloc>()
                                    .add(const MarkAllNotificationsReadEvent()),
                                // No right inset: the label ends on the
                                // cards' right edge.
                                style: TextButton.styleFrom(
                                  foregroundColor: LightColor.secondaryColor,
                                  padding: const EdgeInsets.only(left: 8),
                                ),
                                icon: const Icon(
                                  Icons.done_all_rounded,
                                  size: AppDimens.sizeX18,
                                ),
                                label: const Text(
                                  StringConstants.markAllAsRead,
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        )
                      : filterBar,
                ),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationState state) {
    if (state.status == NotificationStatus.idle ||
        state.status == NotificationStatus.loading) {
      return _centred(context, const NotificationSkeletonLoader());
    }

    if (state.status == NotificationStatus.failure &&
        state.notifications.isEmpty) {
      return _centred(
        context,
        NotificationErrorView(
          message:
              state.errorMessage ?? StringConstants.couldNotLoadNotifications,
          onRetry: () => context.read<NotificationBloc>().add(
            const FetchNotificationsEvent(),
          ),
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return RefreshIndicator(
        color: LightColor.secondaryColor,
        onRefresh: () => _refresh(context),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: NotificationEmptyView(
                      unreadOnly: state.filter == NotificationFilter.unread,
                    ),
                  ),
                ],
              ),
        ),
      );
    }

    final DateTime now = DateTime.now();
    final DateTime todayStart = DateTime(now.year, now.month, now.day);
    final List<NotificationModel> today = <NotificationModel>[];
    final List<NotificationModel> earlier = <NotificationModel>[];
    for (final NotificationModel n in state.notifications) {
      final DateTime? created = n.createdAt;
      if (created != null && !created.isBefore(todayStart)) {
        today.add(n);
      } else {
        earlier.add(n);
      }
    }

    return RefreshIndicator(
      color: LightColor.secondaryColor,
      onRefresh: () => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          _feedGutter(context),
          0,
          _feedGutter(context),
          AppDimens.paddingX32,
        ),
        children: <Widget>[
          if (today.isNotEmpty)
            NotificationSection(
              title: StringConstants.today,
              notifications: today,
            ),
          if (today.isNotEmpty && earlier.isNotEmpty)
            const SizedBox(height: AppDimens.sizeX22),
          if (earlier.isNotEmpty)
            NotificationSection(
              title: StringConstants.earlier,
              notifications: earlier,
            ),
        ],
      ),
    );
  }

  Widget _centred(BuildContext context, Widget child) {
    if (!context.isTabletOrWider) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _kFeedMaxWidth + 2 * AppDimens.paddingX24,
        ),
        child: child,
      ),
    );
  }
}
