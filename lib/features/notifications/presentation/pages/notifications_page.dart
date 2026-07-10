import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/features/notifications/data/model/notification_model.dart';
import 'package:hamro_footsall/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:hamro_footsall/features/notifications/domain/repository/notification_repository.dart';
import 'package:hamro_footsall/features/notifications/domain/usecase/notification_use_case.dart';
import 'package:hamro_footsall/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:hamro_footsall/features/notifications/presentation/widgets/notification_widgets.dart';

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
              if (state.unreadCount == 0) return const SizedBox.shrink();
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
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.paddingX20,
                    AppDimens.paddingX8,
                    AppDimens.paddingX20,
                    AppDimens.paddingX16,
                  ),
                  child: NotificationFilterBar(
                    selectedFilter: state.filter,
                    unreadCount: state.unreadCount,
                    onChanged: (NotificationFilter filter) => context
                        .read<NotificationBloc>()
                        .add(ChangeNotificationFilterEvent(filter)),
                  ),
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
      return const NotificationSkeletonLoader();
    }

    if (state.status == NotificationStatus.failure &&
        state.notifications.isEmpty) {
      return NotificationErrorView(
        message: state.errorMessage ?? StringConstants.couldNotLoadNotifications,
        onRetry: () => context.read<NotificationBloc>().add(
          const FetchNotificationsEvent(),
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
        padding: const EdgeInsets.fromLTRB(
          AppDimens.paddingX20,
          0,
          AppDimens.paddingX20,
          AppDimens.paddingX28,
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
}
