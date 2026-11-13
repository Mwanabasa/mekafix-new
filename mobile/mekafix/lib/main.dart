import 'package:flutter/material.dart';
import 'package:mekafix/app.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:mekafix/state/mechanic_state.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionState()..bootstrap()),
        ChangeNotifierProxyProvider<SessionState, MechanicState>(
          create: (_) => MechanicState(),
          update: (_, session, previous) =>
              (previous ?? MechanicState())..bind(session),
        ),
        ChangeNotifierProxyProvider<SessionState, JobsState>(
          create: (_) => JobsState(),
          update: (_, session, previous) =>
              (previous ?? JobsState())..bind(session),
        ),
      ],
      child: const MekaFixApp(),
    ),
  );
}
