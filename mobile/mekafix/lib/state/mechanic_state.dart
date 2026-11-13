import 'package:flutter/foundation.dart';
import 'package:mekafix/core/api.dart';
import 'package:mekafix/core/offline.dart';
import 'package:mekafix/models.dart';
import 'package:mekafix/state/session.dart';

class MechanicState extends ChangeNotifier {
  SessionState? session;
  List<Mechanic> items = [];
  bool loading = false;
  String query = '';
  String? error;
  bool fromCache = false;

  void bind(SessionState next) {
    session = next;
  }

  Future<void> search({String? service}) async {
    if (session == null || !session!.isLoggedIn) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final response = await ApiClient.instance.dio.get(
        '/mechanics/nearby/',
        queryParameters: {
          'lat': session!.latitude,
          'lng': session!.longitude,
          'radius_km': 15,
          if (service != null && service.isNotEmpty) 'service': service,
          'available': 1,
        },
      ).timeout(const Duration(seconds: 15));
      items =
          (response.data as List).map((row) => Mechanic.fromJson(row)).toList();
      fromCache = false;
      if (!kIsWeb) {
        await OfflineStore.instance
            .cacheMechanics(List<Map<String, dynamic>>.from(response.data));
      }
    } catch (_) {
      if (kIsWeb) {
        error = 'Could not load mechanics. Check that the backend is running.';
      } else {
        final cached = await OfflineStore.instance.readMechanics();
        items = cached.map(Mechanic.fromJson).toList();
        fromCache = items.isNotEmpty;
        error = fromCache
            ? 'Showing last saved mechanics (offline).'
            : 'Could not load mechanics.';
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
