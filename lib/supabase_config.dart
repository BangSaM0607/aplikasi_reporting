import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://qwzwldauwkdaclaaeefa.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3endsZGF1d2tkYWNsYWFlZWZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzNzMyOTYsImV4cCI6MjA4MDk0OTI5Nn0.U8-eogvyq5x7BF0-Cm7rbx_HNMpMlITJnu28wn0VlMM';

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}

final supabase = Supabase.instance.client;
