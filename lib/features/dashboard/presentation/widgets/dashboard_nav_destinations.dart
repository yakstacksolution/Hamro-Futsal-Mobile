import 'package:hamro_futsal/core/utils/image_constants.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class DashboardNavDestination {
  const DashboardNavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String icon;

  final String activeIcon;

  final String label;
}

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
