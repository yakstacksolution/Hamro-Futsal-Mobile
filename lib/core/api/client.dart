import 'package:hamro_footsall/core/api/manager/authmanager/auth_manager.dart';

abstract class InitializeClient {
  Client getInstance();
  void revokeAuth();
}

abstract class IClient {
  AuthManager getAuthManager();
}

class Client implements IClient {

  static Function? revokeAuth;

  Client._privateConstructor();

  static final Client _instance = Client._privateConstructor();

  factory Client({Function? logout}) {
    revokeAuth = logout;
    return _instance;
  }

  factory Client.instance() {
    return _instance;
  }

  factory Client.initialize(String? refreshToken, String? accessToken) {
    AuthManager.initializeData(refreshToken, accessToken);
    return _instance;
  }

  @override
  AuthManager getAuthManager() {
    return AuthManager();
  }

}