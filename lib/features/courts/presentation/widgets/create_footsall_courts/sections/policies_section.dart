import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/courts/presentation/bloc/create_footsall_courts_bloc.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/policy_toggle_tile.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

class PoliciesSection extends StatelessWidget {
  const PoliciesSection({super.key, required this.bloc});

  final CreateFootsallCourtsBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        PolicyToggleTile(
          title: StringConstants.allowCancellations,
          subtitle: StringConstants
              .enableUsersToCancelConfirmedBookingsBeforeMatchDay,
          value: bloc.state.allowCancellation,
          onChanged: bloc.toggleAllowCancellation,
        ),
        const SizedBox(height: 12),
        // Not optional: every court collects an advance of at least
        // kMinimumAdvancePercent% before a booking is confirmed. The tile is
        // rendered read-only (null onChanged) rather than hidden, so the
        // policy stays visible to the vendor.
        PolicyToggleTile(
          title: StringConstants.requireAdvancePayment,
          subtitle:
              'Required on every court — at least '
              '${kMinimumAdvancePercent.toStringAsFixed(0)}% is collected '
              'before a booking is confirmed.',
          value: true,
          onChanged: null,
        ),
        const SizedBox(height: 12),
        PolicyToggleTile(
          title: StringConstants.supportRefunds,
          subtitle:
              StringConstants.offerRefundsWhenCancellationsMeetYourVenuePolicy,
          value: bloc.state.supportsRefunds,
          onChanged: bloc.state.allowCancellation
              ? bloc.toggleSupportsRefunds
              : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: bloc.bookingAdvanceDaysController,
          focusNode: bloc.bookingAdvanceDaysFocus,
          ensureVisibleOnFocus: true,
          labelText: StringConstants.bookingAdvanceLimitDays,
          hintText: '30',
          icon: Icons.calendar_month_rounded,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => bloc.state.allowCancellation
              ? bloc.cancellationWindowFocus.requestFocus()
              : bloc.houseRulesFocus.requestFocus(),
          validator: bloc.bookingAdvanceDaysValidator,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.cancellationWindowController,
          focusNode: bloc.cancellationWindowFocus,
          ensureVisibleOnFocus: true,
          labelText: StringConstants.cancellationWindowHours,
          hintText: bloc.state.allowCancellation ? '12' : 'Disabled',
          icon: Icons.access_time_filled_rounded,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => bloc.houseRulesFocus.requestFocus(),
          enabled: bloc.state.allowCancellation,
          isRequired: bloc.state.allowCancellation,
          validator: bloc.cancellationWindowValidator,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.houseRulesController,
          focusNode: bloc.houseRulesFocus,
          ensureVisibleOnFocus: true,
          labelText: StringConstants.houseRules,
          hintText: StringConstants
              .exampleNonMarkingShoesOnlyReport15MinutesEarlyNo3d1a39a7,
          icon: Icons.gavel_rounded,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: 3,
          maxLines: 5,
          validator: bloc.houseRulesValidator,
        ),
      ],
    );
  }
}
