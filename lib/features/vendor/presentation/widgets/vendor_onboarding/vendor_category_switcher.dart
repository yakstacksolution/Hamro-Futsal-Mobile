import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class VendorCategorySwitcher extends StatefulWidget {
  const VendorCategorySwitcher({
    super.key,
    required this.activeCategory,
    required this.onCategorySelected,
  });

  final VendorCategory activeCategory;
  final ValueChanged<VendorCategory> onCategorySelected;

  @override
  State<VendorCategorySwitcher> createState() => _VendorCategorySwitcherState();
}

class _VendorCategorySwitcherState extends State<VendorCategorySwitcher>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: VendorCategory.values.length,
      vsync: this,
      initialIndex: _indexForCategory(widget.activeCategory),
    );
  }

  @override
  void didUpdateWidget(covariant VendorCategorySwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int nextIndex = _indexForCategory(widget.activeCategory);
    if (_tabController.index != nextIndex) {
      _tabController.animateTo(nextIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _indexForCategory(VendorCategory category) {
    return category == VendorCategory.futsal ? 0 : 1;
  }

  VendorCategory _categoryForIndex(int index) {
    return index == 0 ? VendorCategory.futsal : VendorCategory.court;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = FutsalTheme.getTextTheme(
      context,
    ).bodyTextSmall?.copyWith(fontWeight: FontWeight.w800);

    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX4),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.greyBorderColor),
        boxShadow: [
          BoxShadow(
            color: LightColor.primaryTextColor.withValues(alpha: 0.04),
            blurRadius: AppDimens.radiusX16,
            offset: const Offset(0, AppDimens.sizeX8),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (int index) {
          widget.onCategorySelected(_categoryForIndex(index));
        },
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: LightColor.secondaryColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        ),
        labelColor: LightColor.whiteColor,
        unselectedLabelColor: LightColor.primaryTextColor,
        labelStyle: labelStyle,
        unselectedLabelStyle: labelStyle,
        tabs: const <Widget>[
          _CategoryTab(
            icon: Icons.storefront_rounded,
            title: StringConstants.futsal,
          ),
          _CategoryTab(
            icon: Icons.stadium_rounded,
            title: StringConstants.court,
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: AppDimens.sizeX44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppDimens.sizeX16),
          const SizedBox(width: AppDimens.sizeX8),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
