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
    if (text.isEmpty) return 'Full name is required';
    if (text.length < 3) return 'Enter your full name';
    if (text.length > 80) return 'Full name cannot exceed 80 characters';
    if (!_humanNamePattern.hasMatch(text)) {
      return 'Full name can contain letters and spaces only';
    }
    return null;
  }

  static String? email(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (text.length > 254) return 'Email address is too long';
    if (!_emailPattern.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? nepalMobile(String? value, {bool required = true}) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return required ? 'Phone number is required' : null;
    }
    if (RegExp(r'[^0-9+\s-]').hasMatch(text) ||
        text.indexOf('+') > 0 ||
        '+'.allMatches(text).length > 1) {
      return 'Enter a valid Nepal mobile number';
    }
    if (normalizeNepalMobile(text) == null) {
      return 'Use a 97/98 mobile number with optional +977 prefix';
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
