import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20)));
  List<Map<String, dynamic>> hospitals = [];
  bool loading = false;
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      initialized = true;
      final s = context.read<SessionState>();
      load(s.latitude, s.longitude);
    }
  }

  String? error;

  Future<void> load(double lat, double lon) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      const endpoint = 'https://overpass-api.de/api/interpreter';
      final query =
          '[out:json][timeout:20];(node["amenity"="hospital"](around:15000,$lat,$lon);way["amenity"="hospital"](around:15000,$lat,$lon);relation["amenity"="hospital"](around:15000,$lat,$lon););out center tags;';
      final response =
          await dio.get(endpoint, queryParameters: {'data': query});
      final elements =
          List<Map<String, dynamic>>.from(response.data['elements'] ?? []);
      hospitals = elements
          .map((e) {
            final tags = Map<String, dynamic>.from(e['tags'] ?? {});
            final center = e['center'] as Map<String, dynamic>?;
            return {
              'name': tags['name'] ?? 'Unnamed hospital',
              'lat': e['lat'] ?? center?['lat'],
              'lon': e['lon'] ?? center?['lon'],
              'emergency': tags['emergency'] == 'yes',
              'phone': tags['phone'] ?? tags['contact:phone'] ?? '',
              'address': [
                tags['addr:street'],
                tags['addr:suburb'],
                tags['addr:city']
              ].where((v) => v != null && v.toString().isNotEmpty).join(', '),
              'tags': tags
            };
          })
          .where((h) => h['lat'] != null && h['lon'] != null)
          .toList();
      hospitals.sort((a, b) => _distance(lat, lon, (a['lat'] as num).toDouble(),
              (a['lon'] as num).toDouble())
          .compareTo(_distance(lat, lon, (b['lat'] as num).toDouble(),
              (b['lon'] as num).toDouble())));
    } catch (_) {
      error =
          'Could not load hospital listings. Check your internet connection.';
    }
    if (mounted) setState(() => loading = false);
  }

  double _distance(double a, double b, double c, double d) {
    const r = 6371.0;
    final p1 = a * math.pi / 180;
    final p2 = c * math.pi / 180;
    final dp = (c - a) * math.pi / 180;
    final dl = (d - b) * math.pi / 180;
    final h = math.pow(math.sin(dp / 2), 2) +
        math.cos(p1) * math.cos(p2) * math.pow(math.sin(dl / 2), 2);
    return 2 * r * math.asin(math.sqrt(h));
  }

  Future<void> _directions(Map<String, dynamic> h) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${h['lat']},${h['lon']}&travelmode=driving');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    return Scaffold(
        appBar: AppBar(title: const Text('Emergency & hospitals'), actions: [
          IconButton(
              onPressed: () => load(session.latitude, session.longitude),
              icon: const Icon(Icons.refresh))
        ]),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFF9F2424),
                  borderRadius: BorderRadius.circular(22)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.health_and_safety,
                        color: Colors.white, size: 34),
                    const SizedBox(height: 10),
                    const Text('Need urgent medical help?',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text(
                        'If someone is in immediate danger, contact emergency services first. Do not rely on this directory for emergency dispatch.',
                        style: TextStyle(color: Colors.white, height: 1.4)),
                    const SizedBox(height: 16),
                    SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF9F2424)),
                            onPressed: () => launchUrl(Uri.parse('tel:112')),
                            icon: const Icon(Icons.call),
                            label: const Text('Call emergency services')))
                  ])),
          const SizedBox(height: 22),
          Text('Hospitals near your location',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
              'Listings are sourced from OpenStreetMap. Call the facility to confirm emergency department availability before travelling.',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          if (hospitals.isEmpty && !loading)
            FilledButton.tonalIcon(
                onPressed: () => load(session.latitude, session.longitude),
                icon: const Icon(Icons.local_hospital_outlined),
                label: const Text('Find nearby hospitals')),
          if (loading)
            const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator())),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          ...hospitals.map((h) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.local_hospital,
                              color: Color(0xFF087F5B)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(h['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)))
                        ]),
                        if ((h['address'] as String).isNotEmpty)
                          Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(h['address'])),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, children: [
                          Chip(
                              label: Text(h['emergency']
                                  ? 'Emergency tagged'
                                  : 'Call to confirm'),
                              backgroundColor: h['emergency']
                                  ? const Color(0xFFE4F4EB)
                                  : const Color(0xFFFFF3E0))
                        ]),
                        Row(children: [
                          if ((h['phone'] as String).isNotEmpty)
                            TextButton.icon(
                                onPressed: () =>
                                    launchUrl(Uri.parse('tel:${h['phone']}')),
                                icon: const Icon(Icons.call),
                                label: const Text('Call')),
                          const Spacer(),
                          FilledButton.tonalIcon(
                              onPressed: () => _directions(h),
                              icon: const Icon(Icons.directions),
                              label: const Text('Directions'))
                        ])
                      ])))),
        ]));
  }
}
