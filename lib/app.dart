import 'package:flutter/material.dart';
import 'login_page.dart';
import 'Teknisi/pages/home_page.dart';
import 'supabase_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: session == null ? const LoginPage() : const HomePage(),
    );
  }
}
