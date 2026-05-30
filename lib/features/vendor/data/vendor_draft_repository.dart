import 'dart:convert';

import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';

abstract class VendorDraftRepository {
  bool get persistsLocally;

  Future<VendorOnboardingState?> load();

  Future<void> save(VendorOnboardingState state);

  Future<void> clear();
}

class SharedPreferencesVendorDraftRepository implements VendorDraftRepository {
  const SharedPreferencesVendorDraftRepository();

  @override
  bool get persistsLocally => true;

  static const int _schemaVersion = 2;

  @override
  Future<VendorOnboardingState?> load() async {
    final String? raw = AppSettings().vendorOnboardingDraftJson;
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return null;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
    final int storedVersion = map['__schemaVersion'] is int
        ? map['__schemaVersion'] as int
        : 0;
    if (storedVersion < _schemaVersion) {
      await clear();
      return null;
    }

    return VendorOnboardingState.fromJson(map);
  }

  @override
  Future<void> save(VendorOnboardingState state) async {
    final Map<String, dynamic> body = state.toJson();
    body['__schemaVersion'] = _schemaVersion;
    AppSettings().vendorOnboardingDraftJson = jsonEncode(body);
  }

  @override
  Future<void> clear() async => AppSettings().clearVendorOnboardingDraft();
}

class EphemeralVendorDraftRepository implements VendorDraftRepository {
  const EphemeralVendorDraftRepository();

  @override
  bool get persistsLocally => false;

  @override
  Future<VendorOnboardingState?> load() async => null;

  @override
  Future<void> save(VendorOnboardingState state) async {}

  @override
  Future<void> clear() async {}
}
