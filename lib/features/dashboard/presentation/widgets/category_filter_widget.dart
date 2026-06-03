import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/loading/tab_selection_loading.dart';
import 'package:hamro_footsall/features/public/data/model/category_filter_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_category_filter_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/category_filter/category_filter_bloc.dart';

class CategoryFilterWidget extends StatelessWidget {
  const CategoryFilterWidget({
    super.key,
    this.selectedFilterIds = const <int>{},
    this.onSelectionChanged,
  });

  final Set<int> selectedFilterIds;
  final ValueChanged<Set<int>>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryFilterBloc>(
      create: (_) =>
          CategoryFilterBloc(GetCategoryFilterUseCase(PublicRepositoryImpl()))
            ..add(const FetchCategoryFilterEvent()),
      child: BlocBuilder<CategoryFilterBloc, CategoryFilterState>(
        builder: (BuildContext context, CategoryFilterState state) {
          if (state.status == CategoryFilterStatus.loading ||
              state.status == CategoryFilterStatus.idle) {
            return const TabSelectionLoading();
          }

          if (state.status == CategoryFilterStatus.success) {
            return _CategoryFilterRow(
              filters: state.filters,
              selectedFilterIds: selectedFilterIds,
              onSelectionChanged: onSelectionChanged,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CategoryFilterRow extends StatefulWidget {
  const _CategoryFilterRow({
    required this.filters,
    required this.selectedFilterIds,
    this.onSelectionChanged,
  });

  final List<CategoryFilterModel> filters;
  final Set<int> selectedFilterIds;
  final ValueChanged<Set<int>>? onSelectionChanged;

  @override
  State<_CategoryFilterRow> createState() => _CategoryFilterRowState();
}

class _CategoryFilterRowState extends State<_CategoryFilterRow> {
  @override
  Widget build(BuildContext context) {
    return _buildFilterRow();
  }

  void _toggle(CategoryFilterModel filter) {
    final int? id = int.tryParse(filter.id);
    if (id == null) return;

    final Set<int> next = <int>{...widget.selectedFilterIds};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    widget.onSelectionChanged?.call(next);
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: AppDimens.sizeX40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.filters.length,
        itemBuilder: (BuildContext context, int i) {
          final int? id = int.tryParse(widget.filters[i].id);
          final bool selected =
              id != null && widget.selectedFilterIds.contains(id);
          return GestureDetector(
            onTap: () => _toggle(widget.filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: AppUtils().getMargin(right: AppDimens.marginX10),
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX18,
                symmetricVertical: AppDimens.paddingX8,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? LightColor.secondaryColor
                    : LightColor.transparentColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                border: Border.all(
                  color: selected
                      ? LightColor.transparentColor
                      : LightColor.iconGrey.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                widget.filters[i].title,
                style: FutsalTheme.getTextTheme(context).bodyTextMedium
                    ?.copyWith(
                      color: selected
                          ? LightColor.whiteColor
                          : LightColor.secondaryTextColor,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
