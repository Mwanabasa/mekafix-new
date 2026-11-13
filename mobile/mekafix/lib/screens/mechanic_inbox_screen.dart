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
    return Scaffold(
      appBar: AppBar(title: Text('Jobs · ${session.user?.fullName ?? ''}')),
      body: RefreshIndicator(
        onRefresh: jobs.refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (jobs.jobs.isEmpty) const Text('No incoming requests yet. Stay available to appear in nearby search.'),
            ...jobs.jobs.map(
              (job) => Card(
                child: ListTile(
                  title: Text('${job.customerName} · ${job.kind}'),
                  subtitle: Text('${job.status}\n${job.description}'),
                  isThreeLine: true,
                  trailing: job.status == 'pending'
                      ? FilledButton(
                          onPressed: () => jobs.accept(job.id),
                          child: const Text('Accept'),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job.id))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
