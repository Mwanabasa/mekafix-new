import 'package:flutter/material.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final phone = TextEditingController();
  final name = TextEditingController();
  final password = TextEditingController();
  final garage = TextEditingController();
  String role = 'owner';
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'owner', label: Text('Vehicle owner')),
              ButtonSegment(value: 'mechanic', label: Text('Mechanic')),
            ],
            selected: {role},
            onSelectionChanged: (value) => setState(() => role = value.first),
          ),
          const SizedBox(height: 16),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
          const SizedBox(height: 12),
          TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number')),
          const SizedBox(height: 12),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          if (role == 'mechanic') ...[
            const SizedBox(height: 12),
            TextField(controller: garage, decoration: const InputDecoration(labelText: 'Garage name')),
          ],
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
                    final ok = await session.register(
                      phone: phone.text.trim(),
                      fullName: name.text.trim(),
                      password: password.text,
                      role: role,
                      garageName: garage.text.trim(),
                    );
                    if (ok && context.mounted) Navigator.pop(context);
                    if (context.mounted) setState(() => busy = false);
                  },
            child: const Text('Register with phone'),
          ),
        ],
      ),
    );
  }
}
