import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_review_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_details_bloc/booking_details_bloc.dart';

/// Rate-your-booking, shown on a completed booking in the customer's own view.
///
/// Three states, driven by `GET /bookings/{id}/review`: the check in flight,
/// the form when no review exists, and the submitted review once one does.
/// Nothing is shown while the check is unresolved or has failed — offering the
/// form on a guess would invite a submission the server rejects as duplicate.
class BookingReviewSection extends StatefulWidget {
  const BookingReviewSection({super.key, required this.bookingId});

  final int bookingId;

  @override
  State<BookingReviewSection> createState() => _BookingReviewSectionState();
}

class _BookingReviewSectionState extends State<BookingReviewSection> {
  final TextEditingController _reviewCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _rating = 0;
  bool _ratingMissing = false;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final bool textValid = _formKey.currentState?.validate() ?? false;
    setState(() => _ratingMissing = _rating == 0);
    if (!textValid || _rating == 0) return;
    FocusScope.of(context).unfocus();
    context.read<BookingDetailsBloc>().add(
      SubmitBookingReviewEvent(
        bookingId: widget.bookingId,
        rating: _rating.toDouble(),
        review: _reviewCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingDetailsBloc, BookingDetailsState>(
      buildWhen: (BookingDetailsState p, BookingDetailsState c) =>
          p.reviewStatus != c.reviewStatus ||
          p.review != c.review ||
          p.reviewError != c.reviewError,
      builder: (BuildContext context, BookingDetailsState state) {
        if (state.isCheckingReview) return const _ReviewCheckingCard();
        if (state.hasReviewed && state.review != null) {
          return _SubmittedReviewCard(review: state.review!);
        }
        if (!state.canReview && !state.isSubmittingReview) {
          return const SizedBox.shrink();
        }
        return _ReviewForm(
          formKey: _formKey,
          controller: _reviewCtrl,
          rating: _rating,
          ratingMissing: _ratingMissing,
          isSubmitting: state.isSubmittingReview,
          errorText: state.reviewError,
          onRating: (int value) => setState(() {
            _rating = value;
            _ratingMissing = false;
          }),
          onSubmit: _submit,
        );
      },
    );
  }
}

class _ReviewForm extends StatelessWidget {
  const _ReviewForm({
    required this.formKey,
    required this.controller,
    required this.rating,
    required this.ratingMissing,
    required this.isSubmitting,
    required this.errorText,
    required this.onRating,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final int rating;
  final bool ratingMissing;
  final bool isSubmitting;
  final String? errorText;
  final ValueChanged<int> onRating;
  final VoidCallback onSubmit;

  static const List<String> _ratingWords = <String>[
    'Poor',
    'Fair',
    'Good',
    'Great',
    'Excellent',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return _ReviewCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'How was your game?',
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX2),
            Text(
              'Your rating helps other players choose a venue.',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX12),
            Row(
              children: <Widget>[
                for (int star = 1; star <= 5; star++)
                  _StarButton(
                    filled: star <= rating,
                    onTap: isSubmitting ? null : () => onRating(star),
                  ),
                if (rating > 0) ...<Widget>[
                  const SizedBox(width: AppDimens.sizeX8),
                  Text(
                    _ratingWords[rating - 1],
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.brandTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
            if (ratingMissing) ...<Widget>[
              const SizedBox(height: AppDimens.sizeX4),
              Text(
                'Pick a star rating first.',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.redColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppDimens.sizeX12),
            CustomTextField(
              labelText: 'Your review',
              hintText: 'Court condition, facilities, how it all went…',
              controller: controller,
              minLines: 3,
              maxLines: 5,
              readOnly: isSubmitting,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              ensureVisibleOnFocus: true,
              validator: (String? value) {
                final String text = value?.trim() ?? '';
                if (text.isEmpty) return 'Write a few words about the venue.';
                if (text.length < 10) return 'A little more detail, please.';
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            if (errorText != null) ...<Widget>[
              const SizedBox(height: AppDimens.sizeX8),
              Text(
                errorText!,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.redColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppDimens.sizeX14),
            CustomButton(
              text: 'Submit review',
              icon: Icons.rate_review_outlined,
              isLoading: isSubmitting,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmittedReviewCard extends StatelessWidget {
  const _SubmittedReviewCard({required this.review});

  final BookingReviewModel review;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return _ReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.check_circle_rounded,
                size: AppDimens.sizeX18,
                color: LightColor.brandTextColor,
              ),
              const SizedBox(width: AppDimens.sizeX6),
              Expanded(
                child: Text(
                  'You reviewed this booking',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX10),
          Row(
            children: <Widget>[
              for (int star = 1; star <= 5; star++)
                Icon(
                  star <= review.rating.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: AppDimens.sizeX18,
                  color: LightColor.ratingColor,
                ),
              const SizedBox(width: AppDimens.sizeX8),
              Text(
                review.rating.toStringAsFixed(1),
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (review.review.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX10),
            Text(
              review.review,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewCheckingCard extends StatelessWidget {
  const _ReviewCheckingCard();

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: AppDimens.sizeX16,
            height: AppDimens.sizeX16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: LightColor.brandTextColor,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX10),
          Text(
            'Checking your review…',
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: child,
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({required this.filled, required this.onTap});

  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(right: AppDimens.paddingX4),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: filled ? 1.08 : 1,
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: AppDimens.sizeX32,
            color: filled ? LightColor.ratingColor : LightColor.iconGrey,
          ),
        ),
      ),
    );
  }
}
