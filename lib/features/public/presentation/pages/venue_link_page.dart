import 'dart:async';

import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/helper/device_location_helper.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/routers/app_routers.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';
import 'package:hamro_futsal/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_futsal/features/public/domain/usecase/resolve_venue_link_use_case.dart';

/// Landing screen for a shared venue link.
///
/// A link carries a slug (and usually an id), not a venue — and the details
/// route takes a whole [PublicListingVenueModel] as its `extra`. So the link
/// gets its own route: it resolves the slug against the API, then replaces
/// itself with home + the details page, which leaves the user with a back
/// stack that goes somewhere instead of a dead end.
class VenueLinkPage extends StatefulWidget {
  const VenueLinkPage({super.key, this.slug, this.venueId, this.resolver});

  final String? slug;
  final int? venueId;

  /// Injected in tests so resolution runs without the network.
  final Future<PublicListingVenueModel?> Function({String? slug, int? id})?
  resolver;

  @override
  State<VenueLinkPage> createState() => _VenueLinkPageState();
}

enum _LinkStatus { resolving, notFound, failed }

class _VenueLinkPageState extends State<VenueLinkPage> {
  _LinkStatus _status = _LinkStatus.resolving;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_resolve());
  }

  Future<void> _resolve() async {
    setState(() {
      _status = _LinkStatus.resolving;
      _errorMessage = null;
    });

    final String? slug = widget.slug?.trim();
    final int? id = widget.venueId;
    if ((slug == null || slug.isEmpty) && id == null) {
      setState(() => _status = _LinkStatus.notFound);
      return;
    }

    PublicListingVenueModel? venue;
    String? failure;

    if (widget.resolver case final resolve?) {
      venue = await resolve(slug: slug, id: id);
    } else {
      final Either<AppException, PublicListingVenueModel?> response =
          await ResolveVenueLinkUseCase(PublicRepositoryImpl())(
            slug: slug,
            id: id,
            latitude: DeviceLocationHelper.instance.position.value?.latitude,
            longitude: DeviceLocationHelper.instance.position.value?.longitude,
          );
      response.fold(
        (AppException error) => failure = error.errorMessage,
        (PublicListingVenueModel? match) => venue = match,
      );
    }

    if (!mounted) return;

    if (venue case final resolved?) {
      _openDetails(resolved);
      return;
    }

    setState(() {
      _status = failure == null ? _LinkStatus.notFound : _LinkStatus.failed;
      _errorMessage = failure;
    });
  }

  /// Opens the details page in this page's place.
  ///
  /// A link tapped while the app is running has a stack to come back to, so
  /// the resolving page is simply replaced. A cold start has nothing behind
  /// it — home is laid down first, or the details page would have no back
  /// destination at all.
  void _openDetails(PublicListingVenueModel venue) {
    final GoRouter router = GoRouter.of(context);

    if (Navigator.of(context).canPop()) {
      router.pushReplacementNamed(
        AppRouterParams.courtDetails.name,
        extra: venue,
      );
      return;
    }

    router.go(AppRouters.startLocation);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.pushNamed<void>(AppRouterParams.courtDetails.name, extra: venue);
    });
  }

  void _goHome() => GoRouter.of(context).go(AppRouters.startLocation);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingX32),
            child: _status == _LinkStatus.resolving
                ? const _ResolvingView()
                : _UnresolvedView(
                    isFailure: _status == _LinkStatus.failed,
                    message: _errorMessage,
                    onRetry: _status == _LinkStatus.failed ? _resolve : null,
                    onHome: _goHome,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ResolvingView extends StatelessWidget {
  const _ResolvingView();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: AppDimens.sizeX28,
          height: AppDimens.sizeX28,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: LightColor.secondaryColor,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX16),
        Text(
          StringConstants.openingVenue,
          textAlign: TextAlign.center,
          style: textTheme.bodyTextMedium?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _UnresolvedView extends StatelessWidget {
  const _UnresolvedView({
    required this.isFailure,
    required this.onHome,
    this.message,
    this.onRetry,
  });

  final bool isFailure;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppDimens.paddingX16),
          decoration: BoxDecoration(
            color: LightColor.greyBorderColor.withValues(alpha: 1.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFailure ? Icons.wifi_off_rounded : Icons.link_off_rounded,
            size: AppDimens.sizeX28,
            color: LightColor.primaryTextColor,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX16),
        Text(
          isFailure
              ? StringConstants.couldNotOpenThisLink
              : StringConstants.venueNotAvailable,
          textAlign: TextAlign.center,
          style: textTheme.bodyTextMedium?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX8),
        Text(
          message ??
              (isFailure
                  ? StringConstants.checkYourConnectionAndTryAgain
                  : StringConstants.thisVenueIsNoLongerListed),
          textAlign: TextAlign.center,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.hintTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX20),
        if (onRetry case final retry?) ...<Widget>[
          CustomButton(
            text: StringConstants.retry,
            onPressed: retry,
            minHeight: AppDimens.sizeX46,
            minWidth: AppDimens.sizeX180,
            borderRadius: AppDimens.radiusX10,
          ),
          const SizedBox(height: AppDimens.sizeX10),
        ],
        CustomButton(
          text: StringConstants.browseVenues,
          onPressed: onHome,
          backgroundColor: LightColor.cardColor,
          foregroundColor: LightColor.primaryTextColor,
          minHeight: AppDimens.sizeX46,
          minWidth: AppDimens.sizeX180,
          borderRadius: AppDimens.radiusX10,
        ),
      ],
    );
  }
}
