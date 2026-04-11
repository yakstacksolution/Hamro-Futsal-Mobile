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

    return VendorOnboardingState.fromJson(Map<String, dynamic>.from(decoded));
  }

  @override
  Future<void> save(VendorOnboardingState state) async {
    AppSettings().vendorOnboardingDraftJson = jsonEncode(state.toJson());
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
