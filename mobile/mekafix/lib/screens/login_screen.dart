import 'package:flutter/material.dart';
import 'package:mekafix/screens/register_screen.dart';
import 'package:mekafix/state/session.dart';
import 'package:mekafix/theme.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (phone.text.trim().isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your phone number and password.')),
      );
      return;
    }
    setState(() => busy = true);
    await context.read<SessionState>().login(phone.text.trim(), password.text);
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: MekaTheme.seed,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.handyman_rounded,
                          color: Colors.white, size: 25),
                    ),
                    const SizedBox(width: 12),
                    const Text('MekaFix',
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5F1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              size: 14, color: MekaTheme.seed),
                          SizedBox(width: 5),
                          Text('Roadside care',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: MekaTheme.deepGreen)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 58),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3ED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.route_rounded,
                      size: 31, color: MekaTheme.seed),
                ),
                const SizedBox(height: 25),
                Text('Welcome..\nback.',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(fontSize: 34, height: 1.12)),
                const SizedBox(height: 12),
                const Text(
                    'Sign in to find trusted vehicle help or manage the work coming to your garage.',
                    style: TextStyle(
                        fontSize: 14, height: 1.6, color: MekaTheme.muted)),
                const SizedBox(height: 34),
                const Text('PHONE NUMBER',
                    style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                        color: MekaTheme.muted)),
                const SizedBox(height: 9),
                TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 256700000000',
                    prefixIcon: Icon(Icons.phone_iphone_rounded),
                  ),
                ),
                const SizedBox(height: 19),
                const Text('PASSWORD',
                    style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                        color: MekaTheme.muted)),
                const SizedBox(height: 9),
                TextField(
                  controller: password,
                  obscureText: obscurePassword,
                  onSubmitted: (_) => _signIn(),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                      icon: Icon(obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                    ),
                  ),
                ),
                if (session.error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFEEEE),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFB42318), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(session.error!,
                                style: const TextStyle(
                                    color: Color(0xFFB42318), fontSize: 12))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 25),
                FilledButton(
                  onPressed: busy ? null : _signIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (busy) ...[
                        const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white)),
                        const SizedBox(width: 10),
                      ],
                      Text(busy ? 'Signing you in...' : 'Sign in'),
                      if (!busy) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New to MekaFix?",
                        style: TextStyle(color: MekaTheme.muted, fontSize: 13)),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen())),
                      child: const Text('Create account',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_outlined,
                        size: 14, color: MekaTheme.muted),
                    SizedBox(width: 6),
                    Text('A smarter way to get back on the road',
                        style: TextStyle(color: MekaTheme.muted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
