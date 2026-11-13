import 'package:flutter/material.dart';
import 'package:mekafix/screens/job_detail_screen.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:provider/provider.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobsState>();
    return Scaffold(
      appBar: AppBar(title: const Text('My requests')),
      body: RefreshIndicator(
        onRefresh: jobs.refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.jobs.length,
          itemBuilder: (context, index) {
            final job = jobs.jobs[index];
            return Card(
              child: ListTile(
                title: Text('${job.kind} · ${job.status}'),
                subtitle: Text(job.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job.id))),
              ),
            );
          },
        ),
      ),
    );
  }
}
