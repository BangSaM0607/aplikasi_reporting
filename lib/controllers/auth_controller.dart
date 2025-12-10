import '../supabase_config.dart';

class AuthController {
  Future<String?> login(String email, String password) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res.session?.accessToken;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      final res = await supabase.auth.signUp(email: email, password: password);
      return res.user?.id;
    } catch (e) {
      return e.toString();
    }
  }

  void logout() {
    supabase.auth.signOut();
  }
}
