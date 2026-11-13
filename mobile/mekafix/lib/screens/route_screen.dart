import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen(
      {super.key,
      required this.origin,
      required this.destination,
      required this.originLabel,
      required this.destinationLabel});
  final LatLng origin;
  final LatLng destination;
  final String originLabel;
  final String destinationLabel;
  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  List<LatLng> route = [];
  double? distanceKm;
  double? durationMin;
  bool loading = true;
  bool routeAvailable = true;
  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    try {
      final a = widget.origin;
      final b = widget.destination;
      final url =
          'https://router.project-osrm.org/route/v1/driving/${a.longitude},${a.latitude};${b.longitude},${b.latitude}';
      final r = await Dio().get(url,
          queryParameters: {'overview': 'full', 'geometries': 'geojson'});
      final item = (r.data['routes'] as List).first as Map<String, dynamic>;
      final coords = item['geometry']['coordinates'] as List;
      route = coords
          .map(
              (p) => LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble()))
          .toList();
      distanceKm = (item['distance'] as num).toDouble() / 1000;
      durationMin = (item['duration'] as num).toDouble() / 60;
    } catch (_) {
      routeAvailable = false;
      route = [widget.origin, widget.destination];
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bounds = LatLngBounds.fromPoints([widget.origin, widget.destination]);
    return Scaffold(
        appBar: AppBar(title: const Text('Road directions')),
        body: Column(children: [
          Expanded(
              child: FlutterMap(
                  options: MapOptions(
                      initialCameraFit: CameraFit.bounds(
                          bounds: bounds, padding: const EdgeInsets.all(48))),
                  children: [
                TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.mekafix.app'),
                if (route.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(
                        points: route,
                        strokeWidth: 5,
                        color: const Color(0xFF087F5B))
                  ]),
                MarkerLayer(markers: [
                  Marker(
                      point: widget.origin,
                      width: 42,
                      height: 42,
                      child: const Icon(Icons.my_location,
                          color: Colors.blue, size: 32)),
                  Marker(
                      point: widget.destination,
                      width: 42,
                      height: 42,
                      child: const Icon(Icons.location_on,
                          color: Color(0xFF087F5B), size: 38))
                ])
              ])),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: Colors.white,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.originLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Icon(Icons.arrow_downward, size: 18)),
                    Text(widget.destinationLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    if (loading)
                      const LinearProgressIndicator()
                    else
                      Text(routeAvailable
                          ? '${distanceKm?.toStringAsFixed(1)} km · ${durationMin?.round()} min estimated driving time'
                          : 'Route preview unavailable. Open external maps for live directions.'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                        onPressed: () => launchUrl(
                            Uri.parse(
                                'https://www.google.com/maps/dir/?api=1&origin=${widget.origin.latitude},${widget.origin.longitude}&destination=${widget.destination.latitude},${widget.destination.longitude}&travelmode=driving'),
                            mode: LaunchMode.externalApplication),
                        icon: const Icon(Icons.navigation),
                        label: const Text('Start navigation'))
                  ]))
        ]));
  }
}
