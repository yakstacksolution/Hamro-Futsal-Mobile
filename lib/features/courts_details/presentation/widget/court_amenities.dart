import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

class CourtAmenitiesSection extends StatelessWidget {
  const CourtAmenitiesSection({
    super.key,
    required this.features,
    this.categories,
  });

  final List<String> features;

 
  final Map<String, String>? categories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(
        top: AppDimens.paddingX12,
        left: AppDimens.paddingX16,
        right: AppDimens.paddingX16,
      ),
      child: Container(
        padding: AppUtils().getPadding(all: AppDimens.paddingX16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadowColor.withValues(alpha: 0.04),
              blurRadius: AppDimens.sizeX16,
              offset: const Offset(0, AppDimens.sizeX8),
            ),
          ],
        ),
        child: _FeaturesGrid(
          features: features,
          featureIcons: _featureIcons,
          featureColors: _featureColors,
          featureBgColors: _featureBgColors,
          featureCategories: categories ?? _featureCategories,
        ),
      ),
    );
  }
}

const Map<String, IconData> _featureIcons = <String, IconData>{
  'Indoor': Icons.house_rounded,
  'Outdoor': Icons.park_rounded,
  'Floodlight': Icons.lightbulb_rounded,
  'Parking': Icons.local_parking_rounded,
  'Changing Room': Icons.checkroom_rounded,
  'Cafeteria': Icons.local_cafe_rounded,
  'First Aid': Icons.medical_services_rounded,
  'WiFi': Icons.wifi_rounded,
  'AC': Icons.ac_unit_rounded,
};

const Map<String, Color> _featureColors = <String, Color>{
  'Indoor': Color(0xFF185FA5),
  'Outdoor': Color(0xFF3B6D11),
  'Floodlight': Color(0xFFBA7517),
  'Parking': Color(0xFF534AB7),
  'Changing Room': Color(0xFF0F6E56),
  'Cafeteria': Color(0xFF993C1D),
  'First Aid': Color(0xFFA32D2D),
  'WiFi': Color(0xFF185FA5),
  'AC': Color(0xFF0F6E56),
};

const Map<String, Color> _featureBgColors = <String, Color>{
  'Indoor': Color(0xFFE6F1FB),
  'Outdoor': Color(0xFFEAF3DE),
  'Floodlight': Color(0xFFFAEEDA),
  'Parking': Color(0xFFEEEDFE),
  'Changing Room': Color(0xFFE1F5EE),
  'Cafeteria': Color(0xFFFAECE7),
  'First Aid': Color(0xFFFCEBEB),
  'WiFi': Color(0xFFE6F1FB),
  'AC': Color(0xFFE1F5EE),
};

const Map<String, String> _featureCategories = <String, String>{
  'Indoor': 'Facility',
  'Outdoor': 'Facility',
  'Floodlight': 'Lighting',
  'Parking': 'Access',
  'Changing Room': 'Comfort',
  'Cafeteria': 'Food',
  'First Aid': 'Safety',
  'WiFi': 'Connectivity',
  'AC': 'Comfort',
};

class _FeaturesGrid extends StatefulWidget {
  const _FeaturesGrid({
    required this.features,
    required this.featureIcons,
    required this.featureColors,
    required this.featureBgColors,
    required this.featureCategories,
  });

  final List<String> features;
  final Map<String, IconData> featureIcons;
  final Map<String, Color> featureColors;
  final Map<String, Color> featureBgColors;
  final Map<String, String> featureCategories;

  @override
  State<_FeaturesGrid> createState() => _FeaturesGridState();
}

class _FeaturesGridState extends State<_FeaturesGrid> {
  String _selectedCategory = 'All';

  List<String> get _categories {
    final cats =
        widget.features
            .map((f) => widget.featureCategories[f] ?? 'Other')
            .toSet()
            .toList()
          ..sort();
    return ['All', ...cats];
  }

  List<String> get _visibleFeatures {
    if (_selectedCategory == 'All') return widget.features;
    return widget.features
        .where(
          (f) => (widget.featureCategories[f] ?? 'Other') == _selectedCategory,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final features = widget.features;
    final textTheme = FutsalTheme.getTextTheme(context);

    if (features.isEmpty) {
      return Container(
        padding: AppUtils().getPadding(
          horizontal: AppDimens.paddingX14,
          vertical: AppDimens.paddingX18,
        ),
        decoration: BoxDecoration(
          color: LightColor.inputFillColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: LightColor.secondaryTextColor,
              size: AppDimens.sizeX18,
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Expanded(
              child: Text(
                'No amenities information available yet.',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: AppUtils().getPadding(all: AppDimens.paddingX12),
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          ),
          child: Row(
            children: [
              Container(
                width: AppDimens.sizeX34,
                height: AppDimens.sizeX34,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: const Icon(
                  Icons.widgets_rounded,
                  size: AppDimens.sizeX18,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX10),
              Expanded(
                child: Text(
                  'Amenities & Features',
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: LightColor.primaryTextColor,
                  ),
                ),
              ),
              Container(
                padding: AppUtils().getPadding(
                  horizontal: AppDimens.paddingX10,
                  vertical: AppDimens.paddingX4,
                ),
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX50),
                ),
                child: Text(
                  '${_visibleFeatures.length}/${features.length}',
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.inverseTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.sizeX14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isActive = cat == _selectedCategory;
              return Padding(
                padding: AppUtils().getPadding(right: AppDimens.paddingX6),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: AppUtils().getPadding(
                      horizontal: AppDimens.paddingX14,
                      vertical: AppDimens.paddingX8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? LightColor.secondaryColor
                          : LightColor.whiteColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX50),
                    ),
                    child: Text(
                      cat,
                      style: textTheme.bodySubTitle?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? LightColor.inverseTextColor
                            : LightColor.secondaryTextColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppDimens.sizeX14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _visibleFeatures.isEmpty
              ? Container(
                  key: const ValueKey('empty'),
                  width: double.infinity,
                  padding: AppUtils().getPadding(
                    vertical: AppDimens.paddingX20,
                  ),
                  decoration: BoxDecoration(
                    color: LightColor.inputFillColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX14),
                  ),
                  child: Center(
                    child: Text(
                      'No amenities in this category.',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                  ),
                )
              : Wrap(
                  key: ValueKey(_selectedCategory),
                  spacing: AppDimens.sizeX8,
                  runSpacing: AppDimens.sizeX8,
                  children: _visibleFeatures
                      .map((feature) => _buildFeatureTile(context, feature))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildFeatureTile(BuildContext context, String feature) {
    final icon = widget.featureIcons[feature] ?? Icons.check_circle_rounded;
    final color = widget.featureColors[feature] ?? const Color(0xFF185FA5);
    final textTheme = FutsalTheme.getTextTheme(context);

    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(minWidth: AppDimens.sizeX90),
        padding: AppUtils().getPadding(
          horizontal: AppDimens.paddingX10,
          vertical: AppDimens.paddingX8,
        ),
        decoration: BoxDecoration(
          color: LightColor.whiteColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppDimens.sizeX18, color: color),
            const SizedBox(width: AppDimens.sizeX8),
            Flexible(
              child: Text(
                feature,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySubTitle?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
