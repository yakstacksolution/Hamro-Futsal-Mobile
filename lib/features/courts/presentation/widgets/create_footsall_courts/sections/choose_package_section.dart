import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/features/courts/presentation/bloc/create_footsall_courts_bloc.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/package_option_card.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class ChoosePackageSection extends StatelessWidget {
  const ChoosePackageSection({super.key, required this.bloc});

  final CreateFootsallCourtsBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          StringConstants
              .chooseThePackageThatMatchesYourCurrentStageAndOp2398b90f,
          style: TextStyle(
            color: LightColor.secondaryTextColor,
            fontSize: 12.8,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        for (final option
            in CreateFootsallCourtsBloc.packageOptions) ...<Widget>[
          PackageOptionCard(
            option: option,
            isSelected: bloc.state.selectedPackageId == option.id,
            onTap: () => bloc.selectPackage(option.id),
          ),
          const SizedBox(height: 12),
        ],
        if (bloc.packageSelectionError() != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              bloc.packageSelectionError()!,
              style: const TextStyle(
                color: LightColor.secondaryTextColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
