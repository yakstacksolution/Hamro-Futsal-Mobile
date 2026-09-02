import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';

abstract class VendorDraftRepository {
  Future<VendorOnboardingState?> load();

  Future<void> save(VendorOnboardingState state);

  Future<void> clear();
}

class EphemeralVendorDraftRepository implements VendorDraftRepository {
  const EphemeralVendorDraftRepository();

  @override
  Future<VendorOnboardingState?> load() async => null;

  @override
  Future<void> save(VendorOnboardingState state) async {}

  @override
  Future<void> clear() async {}
}
