import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mekafix/models.dart';
import 'package:mekafix/screens/mechanic_detail_screen.dart';
import 'package:mekafix/screens/request_screen.dart';
import 'package:mekafix/state/mechanic_state.dart';
import 'package:mekafix/state/session.dart';
import 'package:mekafix/theme.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final service = TextEditingController();
  bool mapView = false;
  String selectedCategory = 'All';

  final categories = const ['All', 'Engine', 'Tyres', 'Battery', 'Electrical'];

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }

  void _selectCategory(String category, MechanicState state) {
    setState(() => selectedCategory = category);
    final query = category == 'All' ? '' : category;
    service.text = query;
    state.search(service: query);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final state = context.watch<MechanicState>();
    final isMechanic = session.user?.isMechanic == true;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                isMechanic
                    ? 'Explore nearby'
                    : 'Hello, ${session.user?.fullName.split(' ').first ?? 'there'}',
                style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5)),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    size: 13, color: MekaTheme.seed),
                const SizedBox(width: 3),
                Text('Your current area · Kampala',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              tooltip: mapView ? 'Show list' : 'Show map',
              onPressed: () => setState(() => mapView = !mapView),
              icon:
                  Icon(mapView ? Icons.view_list_rounded : Icons.map_outlined),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => state.search(service: service.text.trim()),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                children: [
                  if (!isMechanic)
                    _RoadsideHero(onRequest: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const RequestScreen(kind: 'roadside')));
                    }),
                  if (isMechanic) const _ExploreHero(),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            isMechanic
                                ? 'Find service areas'
                                : 'Find trusted mechanics',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 18)),
                      ),
                      Text('${state.items.length} nearby',
                          style: const TextStyle(
                              fontSize: 11,
                              color: MekaTheme.muted,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: service,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) => state.search(service: value.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search engine, brakes, battery...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            state.search(service: service.text.trim()),
                        icon: const Icon(Icons.arrow_forward_rounded,
                            color: MekaTheme.seed),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final selected = selectedCategory == category;
                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          onSelected: (_) => _selectCategory(category, state),
                          showCheckmark: false,
                          selectedColor: MekaTheme.seed,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : MekaTheme.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                          side: BorderSide(
                              color: selected
                                  ? MekaTheme.seed
                                  : const Color(0xFFE7ECE8)),
                        );
                      },
                    ),
                  ),
                  if (state.fromCache) ...[
                    const SizedBox(height: 12),
                    const _InfoBanner(
                        icon: Icons.cloud_off_rounded,
                        message:
                            'Showing saved mechanics. Connect to refresh live availability.'),
                  ],
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    _InfoBanner(
                        icon: Icons.info_outline_rounded,
                        message: state.error!,
                        action: TextButton(
                            onPressed: () =>
                                state.search(service: service.text.trim()),
                            child: const Text('Retry'))),
                  ],
                  const SizedBox(height: 17),
                  if (state.loading)
                    const Padding(
                        padding: EdgeInsets.all(38),
                        child: Center(child: CircularProgressIndicator()))
                  else if (mapView)
                    SizedBox(
                      height: 390,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: _MapPane(
                            mechanics: state.items,
                            origin:
                                LatLng(session.latitude, session.longitude)),
                      ),
                    )
                  else if (state.items.isEmpty)
                    const _EmptyMechanics()
                  else
                    ...state.items.map((mechanic) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MechanicCard(mechanic: mechanic),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadsideHero extends StatelessWidget {
  const _RoadsideHero({required this.onRequest});
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MekaTheme.deepGreen,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 22),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('ON-DEMAND HELP',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Vehicle trouble?\nWe have your back.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6)),
          const SizedBox(height: 8),
          Text('Request nearby assistance and connect with a mechanic.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                  height: 1.5)),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRequest,
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: MekaTheme.deepGreen,
                  minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.bolt_rounded, size: 19),
              label: const Text('Request roadside help',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreHero extends StatelessWidget {
  const _ExploreHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: const Color(0xFFEAF3ED),
          borderRadius: BorderRadius.circular(22)),
      child: const Row(
        children: [
          Icon(Icons.travel_explore_rounded, size: 32, color: MekaTheme.seed),
          SizedBox(width: 13),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Your service network',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: MekaTheme.deepGreen)),
                SizedBox(height: 4),
                Text('Explore nearby mechanics and service coverage.',
                    style: TextStyle(
                        fontSize: 11, color: MekaTheme.muted, height: 1.4)),
              ])),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MechanicDetailScreen(mechanic: mechanic))),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEAF3ED),
                        borderRadius: BorderRadius.circular(15)),
                    child: const Icon(Icons.home_repair_service_rounded,
                        color: MekaTheme.seed, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mechanic.garageName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: MekaTheme.ink)),
                        const SizedBox(height: 4),
                        Text('${mechanic.area} · ${mechanic.specialty}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: MekaTheme.muted)),
                      ],
                    ),
                  ),
                  if (mechanic.isVerified)
                    const Tooltip(
                        message: 'Verified mechanic',
                        child: Icon(Icons.verified_rounded,
                            color: MekaTheme.seed, size: 20)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      size: 16, color: Color(0xFFF2A65A)),
                  const SizedBox(width: 4),
                  Text(mechanic.ratingAvg.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 12)),
                  Text(' (${mechanic.ratingCount})',
                      style: const TextStyle(
                          color: MekaTheme.muted, fontSize: 11)),
                  const SizedBox(width: 12),
                  const Icon(Icons.near_me_outlined,
                      size: 14, color: MekaTheme.muted),
                  const SizedBox(width: 3),
                  Text(
                      mechanic.distanceKm == null
                          ? 'Distance unavailable'
                          : '${mechanic.distanceKm!.toStringAsFixed(1)} km away',
                      style: const TextStyle(
                          color: MekaTheme.muted, fontSize: 11)),
                  const Spacer(),
                  Text('UGX ${mechanic.priceMin}+',
                      style: const TextStyle(
                          color: MekaTheme.deepGreen,
                          fontWeight: FontWeight.w900,
                          fontSize: 12)),
                ],
              ),
              if (mechanic.services.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: mechanic.services
                        .take(3)
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 6),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF2F5F2),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: MekaTheme.deepGreen,
                                      fontWeight: FontWeight.w700)),
                            ))
                        .toList()),
              ],
              const SizedBox(height: 13),
              const Row(
                children: [
                  Text('View mechanic',
                      style: TextStyle(
                          color: MekaTheme.seed,
                          fontWeight: FontWeight.w900,
                          fontSize: 11)),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward_rounded,
                      size: 14, color: MekaTheme.seed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.message, this.action});
  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
          color: const Color(0xFFFFF5E8),
          borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, size: 17, color: const Color(0xFF9A5B13)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message,
                style:
                    const TextStyle(fontSize: 11, color: Color(0xFF80521F)))),
        if (action != null) action!
      ]),
    );
  }
}

class _EmptyMechanics extends StatelessWidget {
  const _EmptyMechanics();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 38, color: MekaTheme.muted),
          SizedBox(height: 12),
          Text('No mechanics found',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          SizedBox(height: 5),
          Text('Try another service or refresh to search again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: MekaTheme.muted, fontSize: 12)),
        ],
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
            userAgentPackageName: 'com.mekafix.app'),
        MarkerLayer(
          markers: [
            Marker(
                point: origin,
                width: 40,
                height: 40,
                child: const Icon(Icons.my_location_rounded,
                    color: Colors.blue, size: 29)),
            ...mechanics
                .where((m) => m.latitude != 0 && m.longitude != 0)
                .map((m) => Marker(
                      point: LatLng(m.latitude, m.longitude),
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    MechanicDetailScreen(mechanic: m))),
                        child: const Icon(Icons.location_on_rounded,
                            color: MekaTheme.seed, size: 36),
                      ),
                    )),
          ],
        ),
      ],
    );
  }
}
