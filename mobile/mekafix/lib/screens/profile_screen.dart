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
    final user = session.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
        appBar: AppBar(title: const Text('Your profile')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFF123B30),
                  borderRadius: BorderRadius.circular(22)),
              child: Row(children: [
                Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.14),
                        borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 30)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(user.fullName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(
                          '${user.role == 'owner' ? 'Driver' : user.role} · ${user.phone}',
                          style: const TextStyle(color: Colors.white70))
                    ]))
              ])),
          const SizedBox(height: 16),
          if (user.isMechanic)
            Card(
                child: ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Update business location'),
                    subtitle: Text(
                        '${session.latitude.toStringAsFixed(5)}, ${session.longitude.toStringAsFixed(5)}'),
                    trailing: const Icon(Icons.refresh),
                    onTap: () async {
                      await session.refreshLocation();
                      try {
                        await ApiClient.instance.dio
                            .post('/mechanics/me/availability/', data: {
                          'latitude': session.latitude,
                          'longitude': session.longitude
                        });
                      } catch (_) {}
                    })),
          if (!user.isMechanic) ...[
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My vehicles',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 8),
                          if (jobs.vehicles.isEmpty)
                            const Text(
                                'Add your vehicle details to keep service history together.',
                                style: TextStyle(color: Colors.black54)),
                          ...jobs.vehicles.map((v) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading:
                                  const Icon(Icons.directions_car_outlined),
                              title: Text('${v['plate']}'),
                              subtitle: Text('${v['make']} ${v['model']}'))),
                          OutlinedButton.icon(
                              onPressed: () => _addVehicle(context, jobs),
                              icon: const Icon(Icons.add),
                              label: const Text('Add vehicle'))
                        ]))),
          ],
          const SizedBox(height: 16),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recent notifications',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 8),
                        if (jobs.notifications.isEmpty)
                          const Text('No notifications yet.',
                              style: TextStyle(color: Colors.black54)),
                        ...jobs.notifications.take(5).map((n) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.notifications_none),
                            title: Text(n['title'] as String? ?? ''),
                            subtitle: Text(n['body'] as String? ?? '')))
                      ]))),
          const SizedBox(height: 16),
          Card(
              child: ListTile(
                  leading: const Icon(Icons.location_searching),
                  title: const Text('Location permission'),
                  subtitle: const Text(
                      'Used to find nearby mechanics and calculate routes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => session.refreshLocation())),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
              onPressed: () async => session.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out')),
          const SizedBox(height: 12),
          Text('MekaFix · ${ApiConfig.baseUrl}',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black45))
        ]));
  }

  Future<void> _addVehicle(BuildContext context, JobsState jobs) async {
    final plate = TextEditingController();
    final make = TextEditingController();
    final model = TextEditingController();
    final year = TextEditingController();
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Add vehicle'),
                content: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: plate,
                      decoration: const InputDecoration(
                          labelText: 'Registration number')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: make,
                      decoration: const InputDecoration(labelText: 'Make')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: model,
                      decoration: const InputDecoration(labelText: 'Model')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: year,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Year'))
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () async {
                        if (plate.text.trim().isEmpty ||
                            make.text.trim().isEmpty ||
                            model.text.trim().isEmpty) return;
                        try {
                          await jobs.addVehicle({
                            'plate': plate.text.trim(),
                            'make': make.text.trim(),
                            'model': model.text.trim(),
                            'year': int.tryParse(year.text)
                          });
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (_) {
                          if (ctx.mounted)
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                                content: Text(
                                    'Could not add vehicle. Check the registration number.')));
                        }
                      },
                      child: const Text('Save vehicle'))
                ]));
  }
}
