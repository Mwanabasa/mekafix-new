import 'package:flutter/material.dart';
import 'package:mekafix/screens/register_screen.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController(text: '256700000001');
  final password = TextEditingController(text: 'pass123');
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Text('MekaFix', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Nearby verified mechanics. Live roadside help. Clear estimates before you commit.'),
            const SizedBox(height: 28),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number', hintText: '2567...'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (session.error != null) ...[
              const SizedBox(height: 12),
              Text(session.error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      setState(() => busy = true);
                      await session.login(phone.text.trim(), password.text);
                      if (mounted) setState(() => busy = false);
                    },
              child: Text(busy ? 'Signing in...' : 'Sign in'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              child: const Text('Create an account'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
