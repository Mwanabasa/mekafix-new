import 'package:flutter/material.dart';
import 'package:mekafix/core/api.dart';
import 'package:mekafix/core/config.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final jobs = context.watch<JobsState>();
    final user = session.user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(user.fullName, style: Theme.of(context).textTheme.headlineSmall),
          Text('${user.role} · ${user.phone}'),
          const SizedBox(height: 12),
          Text('GPS: ${session.latitude.toStringAsFixed(5)}, ${session.longitude.toStringAsFixed(5)}'),
          const SizedBox(height: 16),
          if (user.isMechanic)
            FilledButton.tonal(
              onPressed: () async {
                await ApiClient.instance.dio.post('/mechanics/me/availability/', data: {
                  'is_available': true,
                  'latitude': session.latitude,
                  'longitude': session.longitude,
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You are available. Location updated for nearby search.')),
                  );
                }
              },
              child: const Text('Go available at my current location'),
            ),
          const SizedBox(height: 16),
          if (!user.isMechanic) ...[
            const Text('Vehicles', style: TextStyle(fontWeight: FontWeight.w700)),
            ...jobs.vehicles.map((v) => ListTile(title: Text('${v['plate']}'), subtitle: Text('${v['make']} ${v['model']}'))),
            OutlinedButton(
              onPressed: () => _addVehicle(context, jobs),
              child: const Text('Add vehicle'),
            ),
          ],
          const SizedBox(height: 16),
          const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
          ...jobs.notifications.take(8).map(
                (n) => ListTile(
                  dense: true,
                  title: Text(n['title'] as String? ?? ''),
                  subtitle: Text('${n['channel']} · ${n['body']}'),
                ),
              ),
          const SizedBox(height: 20),
          FilledButton.tonal(
            onPressed: () async {
              await session.logout();
            },
            child: const Text('Sign out'),
          ),
          const SizedBox(height: 8),
          Text('API ${ApiConfig.baseUrl}', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Future<void> _addVehicle(BuildContext context, JobsState jobs) async {
    final plate = TextEditingController();
    final make = TextEditingController(text: 'Toyota');
    final model = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: plate, decoration: const InputDecoration(labelText: 'Plate')),
            TextField(controller: make, decoration: const InputDecoration(labelText: 'Make')),
            TextField(controller: model, decoration: const InputDecoration(labelText: 'Model')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await jobs.addVehicle({'plate': plate.text, 'make': make.text, 'model': model.text, 'year': 2015});
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
