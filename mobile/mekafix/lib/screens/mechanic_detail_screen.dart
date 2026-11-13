import 'package:flutter/material.dart';
import 'package:mekafix/models.dart';
import 'package:mekafix/screens/request_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MechanicDetailScreen extends StatelessWidget {
  const MechanicDetailScreen({super.key, required this.mechanic});
  final Mechanic mechanic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(mechanic.garageName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              if (mechanic.isVerified)
                const Icon(Icons.verified, color: Color(0xFF0B6E4F)),
              const SizedBox(width: 8),
              Text('${mechanic.ratingAvg}★ · ${mechanic.ratingCount} reviews'),
            ],
          ),
          const SizedBox(height: 8),
          Text(mechanic.bio),
          const SizedBox(height: 8),
          Text(mechanic.address),
          Text('Estimate: UGX ${mechanic.priceMin} – ${mechanic.priceMax}'),
          if (mechanic.distanceKm != null)
            Text('About ${mechanic.distanceKm} km away'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: mechanic.services
                .map((service) => Chip(label: Text(service)))
                .toList(),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => launchUrl(Uri.parse('tel:${mechanic.phone}')),
            icon: const Icon(Icons.call),
            label: const Text('Tap to call'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RequestScreen(kind: 'roadside', mechanic: mechanic),
                ),
              );
            },
            child: const Text('Request roadside assistance'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RequestScreen(kind: 'booking', mechanic: mechanic),
                ),
              );
            },
            child: const Text('Book an appointment'),
          ),
        ],
      ),
    );
  }
}
