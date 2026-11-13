import 'package:flutter/material.dart';
import 'package:mekafix/core/api.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});
  @override
  State<BusinessDashboardScreen> createState() =>
      _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await ApiClient.instance.dio.get('/mechanics/me/');
      if (mounted)
        setState(() {
          profile = Map<String, dynamic>.from(response.data);
          loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  void _message(String message) {
    if (mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _availability(bool value, SessionState session) async {
    try {
      final response = await ApiClient.instance.dio
          .post('/mechanics/me/availability/', data: {
        'is_available': value,
        'latitude': session.latitude,
        'longitude': session.longitude,
      });
      if (mounted)
        setState(() => profile = Map<String, dynamic>.from(response.data));
    } catch (_) {
      _message('Could not update availability.');
    }
  }

  Future<void> _edit() async {
    final p = profile ?? {};
    final garage = TextEditingController(text: p['garage_name'] ?? '');
    final specialty = TextEditingController(text: p['specialty'] ?? '');
    final address = TextEditingController(text: p['address'] ?? '');
    final hours = TextEditingController(text: p['business_hours'] ?? '');
    final bio = TextEditingController(
        text: p['business_description'] ?? p['bio'] ?? '');
    final qualifications =
        TextEditingController(text: p['qualifications'] ?? '');
    final types = List<String>.from(p['supported_vehicle_types'] ?? []);
    const options = [
      'Sedan',
      'SUV',
      '4x4',
      'Pickup',
      'Luxury',
      'European',
      'Hybrid',
      'Electric',
      'Commercial'
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialog) => AlertDialog(
          title: const Text('Manage business profile'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: garage,
                    decoration:
                        const InputDecoration(labelText: 'Business name')),
                const SizedBox(height: 8),
                TextField(
                    controller: specialty,
                    decoration: const InputDecoration(labelText: 'Specialty')),
                const SizedBox(height: 8),
                TextField(
                    controller: address,
                    decoration:
                        const InputDecoration(labelText: 'Address / area')),
                const SizedBox(height: 8),
                TextField(
                    controller: hours,
                    decoration:
                        const InputDecoration(labelText: 'Business hours')),
                const SizedBox(height: 8),
                TextField(
                    controller: bio,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Business description')),
                const SizedBox(height: 8),
                TextField(
                    controller: qualifications,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(labelText: 'Qualifications')),
                const SizedBox(height: 10),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Vehicle types supported')),
                Wrap(
                    spacing: 4,
                    children: options
                        .map((type) => FilterChip(
                              label: Text(type),
                              selected: types.contains(type),
                              onSelected: (selected) => setDialog(() {
                                if (selected) {
                                  types.add(type);
                                } else {
                                  types.remove(type);
                                }
                              }),
                            ))
                        .toList()),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      setState(() => saving = true);
                      try {
                        final response = await ApiClient.instance.dio
                            .patch('/mechanics/me/', data: {
                          'garage_name': garage.text,
                          'specialty': specialty.text,
                          'address': address.text,
                          'business_hours': hours.text,
                          'business_description': bio.text,
                          'qualifications': qualifications.text,
                          'supported_vehicle_types': types,
                        });
                        if (mounted)
                          setState(() => profile =
                              Map<String, dynamic>.from(response.data));
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } catch (_) {
                        _message('Could not save business details.');
                      } finally {
                        if (mounted) setState(() => saving = false);
                      }
                    },
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final jobs = context.watch<JobsState>();
    final p = profile ?? {};
    final completed = jobs.jobs.where((j) => j.status == 'completed').length;
    final active = jobs.jobs
        .where(
            (j) => ['accepted', 'en_route', 'in_progress'].contains(j.status))
        .length;
    final pending = jobs.jobs.where((j) => j.status == 'pending').length;
    final earnings = jobs.jobs.fold<int>(0, (sum, job) {
      final payment = job.payment;
      return sum +
          ((payment != null && payment['status'] == 'confirmed')
              ? ((payment['amount'] as num?)?.toInt() ?? 0)
              : 0);
    });

    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Business dashboard'), actions: [
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
      ]),
      body: RefreshIndicator(
        onRefresh: () async {
          await _load();
          await jobs.refresh();
        },
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFF123B30),
                borderRadius: BorderRadius.circular(22)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['garage_name'] ?? 'Your garage',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(p['address'] ?? 'Add your business address',
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: Text(
                        p['is_available'] == true
                            ? 'Visible to nearby drivers'
                            : 'Currently unavailable',
                        style: const TextStyle(color: Colors.white))),
                Switch(
                    value: p['is_available'] == true,
                    onChanged: (value) => _availability(value, session),
                    activeColor: Colors.white),
              ]),
            ]),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              _metric('New requests', '$pending', Icons.inbox_outlined),
              _metric('Active jobs', '$active', Icons.engineering_outlined),
              _metric('Completed jobs', '$completed', Icons.task_alt),
              _metric(
                  'Rating', '${p['rating_avg'] ?? 0} ★', Icons.star_outline),
              _metric('Paid revenue', 'UGX $earnings', Icons.payments_outlined),
            ],
          ),
          const SizedBox(height: 18),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Garage classification',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(
                              p['garage_type'] == 'specialist'
                                  ? Icons.workspace_premium
                                  : Icons.handyman,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(
                                  p['garage_type'] == 'specialist'
                                      ? 'Specialist garage'
                                      : 'Standard garage',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700))),
                          if (p['garage_type'] == 'specialist')
                            Chip(
                                label: Text(p['specialist_approved'] == true
                                    ? 'Approved'
                                    : 'Pending review')),
                        ]),
                        Text(
                            'Supported vehicles: ${(p['supported_vehicle_types'] as List? ?? []).join(', ').isEmpty ? 'Not specified' : (p['supported_vehicle_types'] as List).join(', ')}'),
                        if ((p['qualifications'] ?? '').toString().isNotEmpty)
                          Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                  'Qualifications: ${p['qualifications']}')),
                      ]))),
          const SizedBox(height: 12),
          Card(
              child: ListTile(
                  leading: const Icon(Icons.storefront_outlined),
                  title: const Text('Business information'),
                  subtitle: Text(p['business_hours'] ??
                      'Add opening hours and business details'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: _edit)),
          const SizedBox(height: 12),
          const Card(
              child: ListTile(
                  leading: Icon(Icons.payments_outlined),
                  title: Text('Earnings and payments'),
                  subtitle: Text(
                      'Revenue above includes only confirmed payment records.'))),
        ]),
      ),
    );
  }

  Widget _metric(String title, String value, IconData icon) => Card(
        child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: const Color(0xFF087F5B)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900)),
                  Text(title, style: const TextStyle(color: Colors.black54)),
                ])),
      );
}
