import 'package:flutter/material.dart';
import 'package:mekafix/screens/job_detail_screen.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';

class MechanicInboxScreen extends StatelessWidget {
  const MechanicInboxScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobsState>();
    final session = context.watch<SessionState>();
    final pending = jobs.jobs.where((j) => j.status == 'pending').length;
    return Scaffold(
        appBar: AppBar(title: const Text('Job requests'), actions: [
          IconButton(onPressed: jobs.refresh, icon: const Icon(Icons.refresh))
        ]),
        body: RefreshIndicator(
            onRefresh: jobs.refresh,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: const Color(0xFF123B30),
                    borderRadius: BorderRadius.circular(22)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Good to see you, ${session.user?.fullName.split(' ').first ?? 'Mechanic'}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('$pending requests waiting for your response',
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      const Text(
                          'Review each request before accepting. You can decline requests that are outside your expertise.',
                          style: TextStyle(color: Colors.white, height: 1.4))
                    ]),
              ),
              const SizedBox(height: 18),
              Text('Your inbox',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (jobs.jobs.isEmpty)
                const Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(children: [
                      Icon(Icons.inbox_outlined,
                          size: 48, color: Colors.black38),
                      SizedBox(height: 10),
                      Text('No requests right now'),
                      Text('Pull down to refresh when you are available.',
                          style: TextStyle(color: Colors.black54))
                    ])),
              ...jobs.jobs.map((job) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                  child: Text(job.customerName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16))),
                              Chip(label: Text(job.status.replaceAll('_', ' ')))
                            ]),
                            const SizedBox(height: 4),
                            Text(
                                '${job.kind == 'roadside' ? 'Roadside assistance' : 'Appointment'} · Request #${job.id}',
                                style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 8),
                            Text(job.description),
                            if (job.address.isNotEmpty)
                              Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(job.address,
                                      style: const TextStyle(
                                          color: Colors.black54))),
                            const SizedBox(height: 12),
                            if (job.status == 'pending')
                              Row(children: [
                                Expanded(
                                    child: OutlinedButton.icon(
                                        onPressed: () async {
                                          try {
                                            await jobs.reject(job.id);
                                          } catch (_) {
                                            if (context.mounted)
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Could not decline request.')));
                                          }
                                        },
                                        icon: const Icon(Icons.close),
                                        label: const Text('Decline'))),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: FilledButton.icon(
                                        onPressed: () async {
                                          try {
                                            await jobs.accept(job.id);
                                          } catch (_) {
                                            if (context.mounted)
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Request may already have been taken. Refresh your inbox.')));
                                          }
                                        },
                                        icon: const Icon(Icons.check),
                                        label: const Text('Accept')))
                              ])
                            else
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => JobDetailScreen(
                                                  jobId: job.id))),
                                      icon: const Icon(Icons.open_in_new),
                                      label: const Text('Manage job')))
                          ]))))
            ])));
  }
}
