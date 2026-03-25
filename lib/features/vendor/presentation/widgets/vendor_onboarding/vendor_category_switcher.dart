import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';

class VendorCategorySwitcher extends StatelessWidget {
  const VendorCategorySwitcher({
    super.key,
    required this.activeCategory,
    required this.canAccessCourtCategory,
    required this.onCategorySelected,
  });

  final VendorCategory activeCategory;
  final bool canAccessCourtCategory;
  final ValueChanged<VendorCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: LightColor.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LightColor.border),
        boxShadow: [
          BoxShadow(
            color: LightColor.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              title: 'Futsal',
              icon: Icons.storefront_rounded,
              isSelected: activeCategory == VendorCategory.futsal,
              isLocked: false,
              onTap: () => onCategorySelected(VendorCategory.futsal),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _Tab(
              title: 'Court',
              icon: Icons.stadium_rounded,
              isSelected: activeCategory == VendorCategory.court,
              isLocked: !canAccessCourtCategory,
              onTap: canAccessCourtCategory
                  ? () => onCategorySelected(VendorCategory.court)
                  : () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = isSelected
        ? LightColor.secondary
        : const Color(0xFFF8FAFC);

    final Color textColor = isSelected
        ? LightColor.white
        : isLocked
        ? const Color(0xFF94A3B8)
        : LightColor.titleText;

    final Color iconColor = isSelected
        ? LightColor.white
        : isLocked
        ? const Color(0xFF94A3B8)
        : LightColor.secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondary
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? LightColor.white.withValues(alpha: 0.16)
                      : LightColor.secondaryLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  isLocked ? Icons.lock_rounded : icon,
                  size: 18,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isLocked ? 'Court (Locked)' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: LightColor.white,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:hamro_footsall/core/theme/light_color.dart';
// import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';

// class VendorCategorySwitcher extends StatelessWidget {
//   const VendorCategorySwitcher({
//     super.key,
//     required this.activeCategory,
//     required this.canAccessCourtCategory,
//     required this.onCategorySelected,
//   });

//   final VendorCategory activeCategory;
//   final bool canAccessCourtCategory;
//   final ValueChanged<VendorCategory> onCategorySelected;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: <Widget>[
//         Expanded(
//           child: _CategoryTile(
//             title: 'Category 0',
//             subtitle: 'Futsal',
//             isSelected: activeCategory == VendorCategory.futsal,
//             isLocked: false,
//             icon: Icons.storefront_rounded,
//             onTap: () => onCategorySelected(VendorCategory.futsal),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _CategoryTile(
//             title: 'Category 1',
//             subtitle: 'Court',
//             isSelected: activeCategory == VendorCategory.court,
//             isLocked: !canAccessCourtCategory,
//             icon: Icons.stadium_rounded,
//             onTap: () => onCategorySelected(VendorCategory.court),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _CategoryTile extends StatelessWidget {
//   const _CategoryTile({
//     required this.title,
//     required this.subtitle,
//     required this.isSelected,
//     required this.isLocked,
//     required this.icon,
//     required this.onTap,
//   });

//   final String title;
//   final String subtitle;
//   final bool isSelected;
//   final bool isLocked;
//   final IconData icon;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: onTap,
//         child: Ink(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: isSelected ? LightColor.primaryLight : LightColor.surface,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: isSelected ? LightColor.primary : LightColor.border,
//               width: isSelected ? 1.4 : 1,
//             ),
//           ),
//           child: Row(
//             children: <Widget>[
//               Container(
//                 width: 42,
//                 height: 42,
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? LightColor.primary
//                       : LightColor.backgroundWarm,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Icon(
//                   isLocked ? Icons.lock_outline_rounded : icon,
//                   color: isSelected ? Colors.white : LightColor.primary,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         color: LightColor.subtitleText,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         color: LightColor.titleText,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
