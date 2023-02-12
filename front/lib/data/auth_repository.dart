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

  String getKey() {
    return AppDb().getApiKey()!;
  }

  void login(String key) {
    AppDb().setApiKey(key);
  }
}
