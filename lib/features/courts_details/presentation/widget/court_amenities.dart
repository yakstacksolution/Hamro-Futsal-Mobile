import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

class CourtAmenitiesSection extends StatelessWidget {
  const CourtAmenitiesSection({super.key, required this.features});

  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _FeaturesGrid(
          features: features,
          featureIcons: _featureIcons,
          featureColors: _featureColors,
          featureBgColors: _featureBgColors,
          featureCategories: _featureCategories,
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

    if (features.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF6B7280),
              size: 18,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No amenities information available yet.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: LightColor.secondaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.widgets_rounded,
                  size: 18,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Amenities & Features',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_visibleFeatures.length}/${features.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isActive = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? LightColor.secondaryColor
                          : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isActive
                            ? LightColor.secondaryColor
                            : const Color(0xFFD1D5DB),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _visibleFeatures.isEmpty
              ? Container(
                  key: const ValueKey('empty'),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Center(
                    child: Text(
                      'No amenities in this category.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ),
                )
              : LayoutBuilder(
                  key: ValueKey(_selectedCategory),
                  builder: (context, constraints) => GridView.builder(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _visibleFeatures.length,
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.5,
                        ),
                    itemBuilder: (context, index) =>
                        _buildFeatureTile(_visibleFeatures[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFeatureTile(String feature) {
    final icon = widget.featureIcons[feature] ?? Icons.check_circle_rounded;
    final color = widget.featureColors[feature] ?? const Color(0xFF185FA5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.secondaryColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 5),
          Text(
            feature,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
