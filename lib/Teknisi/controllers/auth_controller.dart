import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final _client = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    // jika tidak throw error, login sukses
    print('Login sukses: ${res.user?.id}');
  }

  Future<void> register(String email, String password) async {
    final res = await _client.auth.signUp(email: email, password: password);
    print('Register sukses: ${res.user?.id}');
  }
}
