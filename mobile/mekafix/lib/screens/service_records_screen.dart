import 'package:flutter/material.dart';
import 'package:mekafix/core/api.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:mekafix/state/mechanic_state.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';

class ServiceRecordsScreen extends StatefulWidget {
  const ServiceRecordsScreen({super.key});
  @override
  State<ServiceRecordsScreen> createState() => _ServiceRecordsScreenState();
}

class _ServiceRecordsScreenState extends State<ServiceRecordsScreen> {
  List<Map<String, dynamic>> records = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response =
          await ApiClient.instance.dio.get('/jobs/service-records/');
      records = List<Map<String, dynamic>>.from(response.data);
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  Future<void> _create() async {
    final jobs = context
        .read<JobsState>()
        .jobs
        .where((job) => job.status == 'completed' && job.raw['vehicle'] != null)
        .toList();
    if (jobs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Complete a job linked to a registered vehicle before creating a service record.')));
      return;
    }
    int selectedJob = jobs.first.id;
    final title = TextEditingController();
    final odometer = TextEditingController();
    final diagnosis = TextEditingController();
    final work = TextEditingController();
    final parts = TextEditingController();
    final recommendations = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialog) => AlertDialog(
          title: const Text('Create vehicle service record'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<int>(
                  value: selectedJob,
                  items: jobs
                      .map((job) => DropdownMenuItem(
                          value: job.id,
                          child: Text('Job #${job.id} · ${job.description}',
                              overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (value) => setDialog(() => selectedJob = value!),
                  decoration: const InputDecoration(labelText: 'Completed job'),
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: title,
                    decoration:
                        const InputDecoration(labelText: 'Record title')),
                const SizedBox(height: 8),
                TextField(
                    controller: odometer,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Odometer (km)')),
                const SizedBox(height: 8),
                TextField(
                    controller: diagnosis,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Diagnosis / observations')),
                const SizedBox(height: 8),
                TextField(
                    controller: work,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(labelText: 'Work carried out')),
                const SizedBox(height: 8),
                TextField(
                    controller: parts,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Parts used')),
                const SizedBox(height: 8),
                TextField(
                    controller: recommendations,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Recommendations for next visit')),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (title.text.trim().isEmpty || work.text.trim().isEmpty)
                  return;
                try {
                  await ApiClient.instance.dio
                      .post('/jobs/service-records/', data: {
                    'service_request': selectedJob,
                    'title': title.text.trim(),
                    'odometer_km': int.tryParse(odometer.text),
                    'diagnosis': diagnosis.text,
                    'work_done': work.text,
                    'parts_used': parts.text,
                    'recommendations': recommendations.text,
                    'shared_with_owner': true,
                  });
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  await _load();
                } catch (_) {
                  if (dialogContext.mounted)
                    ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(
                        content: Text(
                            'Could not save record. Confirm the completed job has a vehicle.')));
                }
              },
              child: const Text('Save and share'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(Map<String, dynamic> record) async {
    final mechanics = context
        .read<MechanicState>()
        .items
        .where((mechanic) => mechanic.isVerified)
        .toList();
    if (mechanics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'No verified mechanics are loaded. Open Find Help and refresh nearby mechanics first.')));
      return;
    }
    int selectedMechanic = mechanics.first.id;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialog) => AlertDialog(
          title: const Text('Share vehicle history'),
          content: DropdownButtonFormField<int>(
            value: selectedMechanic,
            items: mechanics
                .map((mechanic) => DropdownMenuItem(
                    value: mechanic.id,
                    child: Text(mechanic.garageName,
                        overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (value) => setDialog(() => selectedMechanic = value!),
            decoration:
                const InputDecoration(labelText: 'Choose verified mechanic'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                try {
                  await ApiClient.instance.dio.post(
                      '/jobs/service-records/${record['id']}/share/',
                      data: {'mechanic_profile_id': selectedMechanic});
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Vehicle history shared with the selected mechanic.')));
                } catch (_) {
                  if (dialogContext.mounted)
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                            content: Text('Could not share this record.')));
                }
              },
              child: const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMechanic = context.watch<SessionState>().user?.isMechanic == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle service records'), actions: [
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
      ]),
      floatingActionButton: isMechanic
          ? FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.note_add_outlined),
              label: const Text('Add record'))
          : null,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: records.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 120),
                      Icon(Icons.history, size: 48, color: Colors.black38),
                      SizedBox(height: 12),
                      Center(child: Text('No shared service records yet'))
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Text(record['title'] ?? 'Service record',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                            subtitle: Text(
                                '${record['vehicle_label'] ?? ''} · ${record['created_at']?.toString().split('T').first ?? ''}'),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            children: [
                              if ((record['mechanic_name'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                _detail('Recorded by', record['mechanic_name']),
                              if (record['odometer_km'] != null)
                                _detail(
                                    'Odometer', '${record['odometer_km']} km'),
                              _detail('Diagnosis', record['diagnosis']),
                              _detail('Work done', record['work_done']),
                              _detail('Parts used', record['parts_used']),
                              _detail('Next visit', record['recommendations']),
                              if (!isMechanic)
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                        onPressed: () => _share(record),
                                        icon: const Icon(Icons.share_outlined),
                                        label: const Text(
                                            'Share with a mechanic'))),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _detail(String label, dynamic value) => Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 105,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(
              child: Text(
                  (value ?? '').toString().isEmpty ? '—' : value.toString())),
        ]),
      );
}
