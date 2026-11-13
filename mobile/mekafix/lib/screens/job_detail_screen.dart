import 'package:flutter/material.dart';
import 'package:mekafix/models.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.jobId});
  final int jobId;

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobsState>();
    final session = context.watch<SessionState>();
    final job = jobs.jobs.where((j) => j.id == jobId).firstOrNull;
    if (job == null) {
      return const Scaffold(body: Center(child: Text('Job not found')));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Request #${job.id}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(job.status.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(job.description),
          Text(job.address),
          if (job.quoted != null) Text('Estimate: UGX ${job.quoted}'),
          const SizedBox(height: 12),
          if (session.user?.isMechanic == true) ...[
            Wrap(
              spacing: 8,
              children: [
                for (final status in ['en_route', 'in_progress', 'completed'])
                  OutlinedButton(
                    onPressed: () => jobs.updateStatus(job.id, status),
                    child: Text(status.replaceAll('_', ' ')),
                  ),
              ],
            ),
            FilledButton.icon(
              onPressed: () => launchUrl(Uri.parse('tel:${job.customerPhone}')),
              icon: const Icon(Icons.call),
              label: Text('Call ${job.customerName}'),
            ),
          ] else ...[
            if (job.mechanic != null)
              FilledButton.icon(
                onPressed: () => launchUrl(Uri.parse('tel:${job.mechanic?['user']?['phone'] ?? ''}')),
                icon: const Icon(Icons.call),
                label: const Text('Call mechanic'),
              ),
            if (job.status == 'completed' && job.rating == null)
              FilledButton.tonal(
                onPressed: () => _rate(context, jobs, job),
                child: const Text('Rate this job'),
              ),
            if (job.quoted != null && job.payment == null)
              OutlinedButton(
                onPressed: () async {
                  await jobs.pay(job.id, job.quoted!, session.user!.phone);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mobile-money sandbox marked this job as paid.')),
                    );
                  }
                },
                child: const Text('Mark paid (MoMo sandbox)'),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _rate(BuildContext context, JobsState jobs, JobRequest job) async {
    final comment = TextEditingController();
    int stars = 5;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rate service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setState) => Slider(
                  value: stars.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '$stars',
                  onChanged: (value) => setState(() => stars = value.round()),
                ),
              ),
              TextField(controller: comment, decoration: const InputDecoration(labelText: 'Comment')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await jobs.rate(job.id, stars, comment.text.trim());
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
