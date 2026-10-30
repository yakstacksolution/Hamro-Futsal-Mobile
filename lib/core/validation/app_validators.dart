import 'package:hamro_futsal/core/utils/string_constants.dart';

class AppValidators {
  const AppValidators._();

  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _humanNamePattern = RegExp(
    r'^[\p{L}\p{M}]+(?: [\p{L}\p{M}]+)*$',
    unicode: true,
  );

  static String? fullName(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return StringConstants.fullNameRequired;
    if (text.length < 3) return StringConstants.enterYourFullName;
    if (text.length > 80) return StringConstants.fullNameTooLong;
    if (!_humanNamePattern.hasMatch(text)) {
      return StringConstants.fullNameLettersOnly;
    }
    return null;
  }

  static String? email(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return StringConstants.emailRequired;
    if (text.length > 254) return StringConstants.emailTooLong;
    if (!_emailPattern.hasMatch(text)) {
      return StringConstants.enterValidEmailAddress;
    }
    return null;
  }

  static String? nepalMobile(String? value, {bool required = true}) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return required ? StringConstants.phoneNumberRequired : null;
    }
    if (RegExp(r'[^0-9+\s-]').hasMatch(text) ||
        text.indexOf('+') > 0 ||
        '+'.allMatches(text).length > 1) {
      return StringConstants.enterValidNepalMobile;
    }
    if (normalizeNepalMobile(text) == null) {
      return StringConstants.useNepalMobileFormat;
    }
    return null;
  }

  static String? normalizeNepalMobile(String? value) {
    String text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    text = text.replaceAll(RegExp(r'[\s-]'), '');
    if (text.startsWith('+977')) {
      text = text.substring(4);
    } else if (text.startsWith('977')) {
      text = text.substring(3);
    }
    if (!RegExp(r'^9[78]\d{8}$').hasMatch(text)) return null;
    return '+977$text';
  }
}
