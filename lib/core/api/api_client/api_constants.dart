import 'package:flutter_dotenv/flutter_dotenv.dart';

/// `per_page` sent to `GET /venues`.
///
/// Single source of truth for the venue-listing page size: the API client, the
/// repository, the use case, the filter payload and [PublicVenueBloc] all
/// default to it, so the wire value can never drift between them.
const int kVenueListPerPage = 5;

class APIEndpoint {
  // Read through [dotenv.maybeGet] with an empty fallback: a `!` here threw on
  // first access whenever .env was missing from the bundle, which surfaced as a
  // black screen rather than a failed request.
  static String _read(String key) =>
      dotenv.isInitialized ? (dotenv.maybeGet(key) ?? '') : '';

  static final String _appUrl = _read('API_URL');
  static final String _chatUrl = _read('CHAT_URL');
  static final String _chatXORKey = _read('CHAT_X_ORIGIN');

  static String get baseUrl => _appUrl;

  static String get chatUrl => _chatUrl;

  static String get chatXORKey => _chatXORKey;
}

// import 'package:flutter/foundation.dart';

// enum MainApiUrlType { base, fcm, backend, ticketing, package, subscription }

// class ApiConstants {
//   static String devBaseUrl =
//       "https://ispaas-subscribers.dev.geniussystems.com.np/";
//   static String liveBaseUrl =
//       "https://api-subscribers.ispaas.geniussystems.com.np/";
//   static String devTicketingBaseUrl =
//       "https://ispaas-ticketing.dev.geniussystems.com.np/";
//   static String liveTicketingBaseUrl =
//       "https://api-tickets.ispaas.geniussystems.com.np/";
//   static String devFcmBaseUrl =
//       "https://ispaas-fcm-notification.dev.geniussystems.com.np/";
//   static String liveFcmBaseUrl =
//       "https://fcm-notification.ispaas.geniussystems.com.np/";

//   static String devBackendBaseUrl =
//       "https://backend-ispaas.dev.geniussystems.com.np/";
//   static String liveBackendBaseUrl =
//       "https://api-admin.ispaas.geniussystems.com.np/";

//   static String devPackageBaseUrl =
//       "https://ispaas-package.dev.geniussystems.com.np/";
//   static String livePackageBaseUrl =
//       "https://package.ispaas.geniussystems.com.np/";

//   static String devSubscriptionBaseUrl =
//       "https://ispaas-subscriptions.dev.geniussystems.com.np/";
//   static String liveSubscriptionBaseUrl =
//       "https://api-subscriptions.ispaas.geniussystems.com.np/";

//   String getMainUrl(MainApiUrlType mainApiUrlType, bool appStatus) {
//     if (kDebugMode) {
//       return getUrl(mainApiUrlType, debugMode: true);
//     } else if (appStatus) {
//       return getUrl(mainApiUrlType, devModeEnable: true);
//     } else {
//       return getUrl(mainApiUrlType);
//     }
//     // return getUrl(mainApiUrlType);
//   }

//   String getUrl(MainApiUrlType urlType,
//       {bool devModeEnable = false, bool debugMode = false}) {
//     String mainUrl = "";
//     switch (urlType) {
//       case MainApiUrlType.base:
//         mainUrl = devModeEnable == true || debugMode == true
//             ? devBaseUrl
//             : liveBaseUrl;
//         break;
//       case MainApiUrlType.fcm:
//         mainUrl = devModeEnable == true || debugMode == true
//             ? devFcmBaseUrl
//             : liveFcmBaseUrl;
//         break;
//       case MainApiUrlType.ticketing:
//         mainUrl = devModeEnable == true || debugMode == true
//             ? devTicketingBaseUrl
//             : liveTicketingBaseUrl;
//         break;
//       case MainApiUrlType.package:
//         mainUrl = devModeEnable == true || debugMode == true
//             ? devPackageBaseUrl
//             : livePackageBaseUrl;
//         break;
//       case MainApiUrlType.subscription:
//         mainUrl = devModeEnable == true || debugMode == true
//             ? devSubscriptionBaseUrl
//             : liveSubscriptionBaseUrl;
//         break;
//       case MainApiUrlType.backend:
//         mainUrl = devModeEnable == true || debugMode == true
//             ? devBackendBaseUrl
//             : liveBackendBaseUrl;
//         break;
//     }
//     return mainUrl;
//   }

//   static String authUrl = "subscriber/authentication/v1/tenants/";
//   static String accountUrl = "subscriber/account/v1/tenants/";
//   static String subscriptionUrl = "subscriber/subscription/v1/tenants/";
//   static String fcmUrl = "subscriber/fcm/v1/tenants/";
//   static String docUrl = "subscriber/document/v1/tenants/";
//   static String serviceUrl = "subscriber/service/v1/tenants/";
//   static String ticketUrl = "subscriber/ticket/v1/tenants/";

//   static String loginUrl = "/subscribers/access-token";
//   static String refreshTokenUrl = "/subscribers/refresh-token";

//   static String userDetailUrl = "/subscribers/detail";
//   static String forgotPasswordUrl =
//       "public/account/v1/subscribers/forgot-password";
//   static String changePasswordUrl =
//       "public/account/v1/subscribers/change-password";
//   static String editPasswordUrl = "/subscribers/edit-password";
//   static String updateProfileUrl = "/subscribers/";
//   static String subscriptionHistoryUrl = "/subscribers/";
//   static String paymentHistoryUrl = "/subscribers/";
//   static String registerFcmToken = "/subscribers/";

//   static String supportTicketUrl = "/subscribers/";
//   static String addSupportTicketUrl = "/subscribers/";

//   static String notificationList = "/subscribers/";
//   static String document = "/subscribers/";

//   static String branchesUrl = "subscriber/branch/v1/tenants/";

//   static String currentPackageUrl = "public/package/v1/packages/";
//   static String packageRenewUrl = "subscriber/subscription/v1/tenants/";
//   static String routerUrl = "subscriber/subscriber/v1/tenants/";
//   static String ftthUrl = "subscriber/wlink-ftth/v1/tenants/"; //55/ftth"
// }
