import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';

void main() {
  test('parses vendor lifecycle and finance capability from auth me', () {
    final user = UserData.fromJson(<String, dynamic>{
      'id': 7,
      'full_name': 'Venue Owner',
      'email': 'owner@example.com',
      'role': 'vendor',
      'requires_vendor_onboarding': false,
      'vendor_status': 'action_required',
      'vendor_status_reason': 'Update tax document',
      'profile_completion': 85,
      'business_verified': true,
      'is_vendor_requested': true,
      'capabilities': <String>['vendor.finance.read'],
    });

    expect(user.vendorStatus, VendorLifecycleStatus.actionRequired);
    expect(user.vendorStatusReason, 'Update tax document');
    expect(user.profileCompletion, 85);
    expect(user.businessVerified, isTrue);
    expect(user.financeAccess, isTrue);
    expect(user.isVendorRequested, isTrue);
  });
}
