import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mekafix/models.dart';
import 'package:mekafix/screens/mechanic_detail_screen.dart';
import 'package:mekafix/screens/request_screen.dart';
import 'package:mekafix/state/mechanic_state.dart';
import 'package:mekafix/state/session.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final service = TextEditingController();
  bool mapView = false;
  String? garageType;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final state = context.watch<MechanicState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find roadside help'),
        actions: [
          IconButton(
            onPressed: () => setState(() => mapView = !mapView),
            icon: Icon(mapView ? Icons.list : Icons.map_outlined),
          ),
        ],
      ),
      floatingActionButton: session.user?.isMechanic == true
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RequestScreen(kind: 'roadside'),
                  ),
                );
              },
              icon: const Icon(Icons.emergency_share),
              label: const Text('Roadside help'),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: service,
              decoration: InputDecoration(
                hintText: 'Search services, garages or repairs',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => state.search(
                      service: service.text.trim(), garageType: garageType),
                ),
              ),
              onSubmitted: (value) =>
                  state.search(service: value.trim(), garageType: garageType),
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(children: [
                Expanded(
                    child: ChoiceChip(
                        label: const Text('All garages'),
                        selected: garageType == null,
                        onSelected: (_) {
                          setState(() => garageType = null);
                          state.search(service: service.text.trim());
                        })),
                const SizedBox(width: 8),
                Expanded(
                    child: ChoiceChip(
                        label: const Text('Standard'),
                        selected: garageType == 'standard',
                        onSelected: (_) {
                          setState(() => garageType = 'standard');
                          state.search(
                              service: service.text.trim(),
                              garageType: 'standard');
                        })),
                const SizedBox(width: 8),
                Expanded(
                    child: ChoiceChip(
                        label: const Text('Specialists'),
                        selected: garageType == 'specialist',
                        onSelected: (_) {
                          setState(() => garageType = 'specialist');
                          state.search(
                              service: service.text.trim(),
                              garageType: 'specialist');
                        }))
              ])),
          if (state.fromCache)
            const Material(
              color: Color(0xFFFFF3E0),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                    'Offline cache — last nearby mechanics saved on this phone.'),
              ),
            ),
          if (state.error != null)
            Material(
              color: const Color(0xFFFFEBEE),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.info_outline),
                title: Text(state.error!),
                trailing: TextButton(
                  onPressed: () => state.search(
                      service: service.text.trim(), garageType: garageType),
                  child: const Text('Retry'),
                ),
              ),
            ),
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : mapView
                    ? _MapPane(
                        mechanics: state.items,
                        origin: LatLng(session.latitude, session.longitude))
                    : RefreshIndicator(
                        onRefresh: () => state.search(
                            service: service.text.trim(),
                            garageType: garageType),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                          itemCount: state.items.length,
                          itemBuilder: (context, index) =>
                              _MechanicCard(mechanic: state.items[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _MechanicCard extends StatelessWidget {
  const _MechanicCard({required this.mechanic});
  final Mechanic mechanic;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(mechanic.garageName,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('${mechanic.area} · ${mechanic.specialty}'),
            Text(
                mechanic.garageType == 'specialist'
                    ? 'SPECIALIST GARAGE · ${mechanic.specialistApproved ? 'APPROVED' : 'PENDING REVIEW'}'
                    : 'STANDARD GARAGE',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6)),
            Text(
              'UGX ${mechanic.priceMin}–${mechanic.priceMax} · ${mechanic.ratingAvg}★ (${mechanic.ratingCount})'
              '${mechanic.distanceKm != null ? ' · ${mechanic.distanceKm} km' : ''}',
            ),
            if (mechanic.supportedVehicleTypes.isNotEmpty)
              Text(
                  'Vehicles: ${mechanic.supportedVehicleTypes.take(4).join(', ')}'),
            Wrap(
              spacing: 6,
              children: mechanic.services
                  .take(3)
                  .map((s) => Chip(
                      label: Text(s), visualDensity: VisualDensity.compact))
                  .toList(),
            ),
          ],
        ),
        trailing: mechanic.isVerified
            ? const Icon(Icons.verified, color: Color(0xFF0B6E4F))
            : null,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => MechanicDetailScreen(mechanic: mechanic)));
        },
      ),
    );
  }
}

class _MapPane extends StatelessWidget {
  const _MapPane({required this.mechanics, required this.origin});
  final List<Mechanic> mechanics;
  final LatLng origin;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(initialCenter: origin, initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.mekafix.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: origin,
              width: 40,
              height: 40,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
            ...mechanics.map(
              (m) => Marker(
                point: LatLng(m.latitude, m.longitude),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MechanicDetailScreen(mechanic: m)));
                  },
                  child: const Icon(Icons.location_on,
                      color: Color(0xFF0B6E4F), size: 36),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
