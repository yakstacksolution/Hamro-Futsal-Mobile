import 'dart:convert';

import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class VendorDraftRepository {
  Future<VendorOnboardingState?> load();

  Future<void> save(VendorOnboardingState state);

  Future<void> clear();
}

class SharedPreferencesVendorDraftRepository implements VendorDraftRepository {
  const SharedPreferencesVendorDraftRepository();

  static const String _draftKey = 'vendor_onboarding_draft_v1';

  @override
  Future<VendorOnboardingState?> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_draftKey);
    if (raw == null || raw.isEmpty) return null;

    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return VendorOnboardingState.fromJson(Map<String, dynamic>.from(decoded));
  }

  @override
  Future<void> save(VendorOnboardingState state) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_draftKey, jsonEncode(state.toJson()));
  }

  @override
  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_draftKey);
  }
}
