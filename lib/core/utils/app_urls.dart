/// Web pages the app opens in its own web view.
///
/// Each carries `type=mobile`: the site serves a chrome-free rendering for
/// that flag — no marketing header, nav or footer — which is what belongs
/// inside the app. `InAppWebViewPage.resolveUrl` would add the flag anyway,
/// and leaves an explicit one such as these untouched.
final class AppUrls {
  const AppUrls._();

  static const String termsAndConditions =
      'https://hamrofutsal.com/terms-and-conditions?type=mobile';

  static const String privacyPolicy =
      'https://hamrofutsal.com/privacy-policy?type=mobile';
}
