import '../db/db.dart';

class AuthRepository {
  Future<void> logout() async {
    await AppDb().clearDb();
    AppDb().setApiKey(null);
    return;
  }

  bool isLoggedIn() {
    return AppDb().getApiKey() != null;
  }

  void login(String key) {
    AppDb().setApiKey(key);
  }
}
