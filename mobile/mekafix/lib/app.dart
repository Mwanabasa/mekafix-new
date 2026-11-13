import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mekafix/screens/home_shell.dart';
import 'package:mekafix/screens/login_screen.dart';
import 'package:mekafix/state/session.dart';
import 'package:mekafix/theme.dart';
import 'package:provider/provider.dart';

class MekaFixApp extends StatelessWidget {
  const MekaFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    return MaterialApp(
      title: 'MekaFix',
      debugShowCheckedModeBanner: false,
      theme: MekaTheme.light(GoogleFonts.plusJakartaSansTextTheme()),
      home: session.ready
          ? (session.isLoggedIn ? const HomeShell() : const LoginScreen())
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
