import 'package:flutter/material.dart';
import 'package:mekafix/screens/job_detail_screen.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:provider/provider.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF087F5B);
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return const Color(0xFFB7791F);
      default:
        return const Color(0xFF2765A8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobsState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My requests'),
        actions: [
          IconButton(onPressed: jobs.refresh, icon: const Icon(Icons.refresh))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: jobs.refresh,
        child: jobs.jobs.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.assignment_outlined,
                      size: 52, color: Colors.black38),
                  SizedBox(height: 12),
                  Center(child: Text('No roadside requests yet')),
                  SizedBox(height: 6),
                  Center(
                      child: Text(
                          'Your requests and their progress will appear here.',
                          style: TextStyle(color: Colors.black54))),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jobs.jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs.jobs[index];
                  final color = _statusColor(job.status);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => JobDetailScreen(jobId: job.id))),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                  child: Text(
                                      '${job.kind == 'roadside' ? 'Roadside assistance' : 'Appointment'} · #${job.id}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800))),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    color: color.withOpacity(.10),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                    job.status
                                        .replaceAll('_', ' ')
                                        .toUpperCase(),
                                    style: TextStyle(
                                        color: color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ]),
                            const SizedBox(height: 8),
                            Text(job.description,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            if (job.address.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 16, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Expanded(
                                      child: Text(job.address,
                                          style: const TextStyle(
                                              color: Colors.black54),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis)),
                                ]),
                              ),
                            const SizedBox(height: 10),
                            const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('View request',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, size: 16)
                                ]),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
