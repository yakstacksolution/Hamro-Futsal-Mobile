import 'package:hamro_footsall/core/utils/image_constants.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// One dashboard tab destination.
///
/// Shared by [CustomBottomNavigationBar] (phone) and [DashboardSideNav]
/// (tablet/desktop) so the two presentations cannot drift apart. The list index
/// is the `IndexedStack` index in `DashboardScreen`.
class DashboardNavDestination {
  const DashboardNavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  /// Asset path for the inactive (outline) icon.
  final String icon;

  /// Asset path for the active (filled) icon.
  final String activeIcon;

  final String label;
}

/// The five dashboard tabs, in `IndexedStack` order.
const List<DashboardNavDestination> dashboardNavDestinations =
    <DashboardNavDestination>[
      DashboardNavDestination(
        icon: ImageConstants.navHome,
        activeIcon: ImageConstants.navHomeFill,
        label: StringConstants.home,
      ),
      DashboardNavDestination(
        icon: ImageConstants.navBooking,
        activeIcon: ImageConstants.navBookingFill,
        label: StringConstants.bookings,
      ),
      DashboardNavDestination(
        icon: ImageConstants.navMessage,
        activeIcon: ImageConstants.navMessageFill,
        label: StringConstants.chat,
      ),
      DashboardNavDestination(
        icon: ImageConstants.navHeart,
        activeIcon: ImageConstants.navHeartFill,
        label: StringConstants.wishlist,
      ),
      DashboardNavDestination(
        icon: ImageConstants.navProfile,
        activeIcon: ImageConstants.navProfileFill,
        label: StringConstants.profile,
      ),
    ];
