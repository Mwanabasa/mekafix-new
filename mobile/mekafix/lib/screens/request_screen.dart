import 'package:flutter/material.dart';
import 'package:mekafix/models.dart';
import 'package:mekafix/state/jobs_state.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key, required this.kind, this.mechanic});
  final String kind;
  final Mechanic? mechanic;

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final description = TextEditingController();
  final address = TextEditingController(text: 'Makerere / Wandegeya, Kampala');
  DateTime? scheduled;
  int? vehicleId;
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final jobs = context.watch<JobsState>();
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.kind == 'roadside'
              ? 'Roadside assistance'
              : 'Book appointment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.mechanic != null)
            Text('Mechanic: ${widget.mechanic!.garageName}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: description,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'What happened?'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: address,
            decoration:
                const InputDecoration(labelText: 'Location description'),
          ),
          const SizedBox(height: 12),
          if (jobs.vehicles.isNotEmpty)
            DropdownButtonFormField<int>(
              initialValue: vehicleId ?? jobs.vehicles.first['id'] as int,
              items: jobs.vehicles
                  .map((v) => DropdownMenuItem(
                      value: v['id'] as int,
                      child: Text('${v['plate']} ${v['make']}')))
                  .toList(),
              onChanged: (value) => setState(() => vehicleId = value),
              decoration: const InputDecoration(labelText: 'Vehicle'),
            ),
          if (widget.kind == 'booking') ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (date == null) return;
                if (!context.mounted) return;
                final time = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 9, minute: 0));
                if (time == null) return;
                setState(() => scheduled = DateTime(
                    date.year, date.month, date.day, time.hour, time.minute));
              },
              child: Text(scheduled == null
                  ? 'Pick appointment time'
                  : scheduled.toString()),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: busy
                ? null
                : () async {
                    setState(() => busy = true);
                    try {
                      await jobs.createJob({
                        'kind': widget.kind,
                        'description': description.text.trim(),
                        'address': address.text.trim(),
                        'latitude': session.latitude,
                        'longitude': session.longitude,
                        if (widget.mechanic != null)
                          'mechanic': widget.mechanic!.id,
                        if (vehicleId != null) 'vehicle': vehicleId,
                        if (scheduled != null)
                          'scheduled_at': scheduled!.toUtc().toIso8601String(),
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Request sent. You will get a push/SMS when it is accepted.')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Could not send request. Check your connection.')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => busy = false);
                    }
                  },
            child: Text(widget.kind == 'roadside'
                ? 'Share live location & request help'
                : 'Confirm booking'),
          ),
        ],
      ),
    );
  }
}
