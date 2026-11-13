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
  bool _hasBoundSession = false;
  int? _boundUserId;
  int _sessionGeneration = 0;

  void bind(SessionState next) {
    final userId = next.user?.id;
    if (_hasBoundSession && _boundUserId != userId) {
      _sessionGeneration++;
      items = [];
      loading = false;
      error = null;
      fromCache = false;
    }
    _hasBoundSession = true;
    _boundUserId = userId;
    session = next;
  }

  Future<void> search({String? service, String? garageType}) async {
    final currentSession = session;
    final user = currentSession?.user;
    if (currentSession == null || !currentSession.isLoggedIn || user == null) {
      return;
    }
    final generation = _sessionGeneration;
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
          if (garageType != null && garageType.isNotEmpty)
            'garage_type': garageType,
          'available': 1,
        },
      ).timeout(const Duration(seconds: 15));
      if (generation != _sessionGeneration) return;
      items =
          (response.data as List).map((row) => Mechanic.fromJson(row)).toList();
      fromCache = false;
      if (!kIsWeb) {
        await OfflineStore.instance
            .cacheMechanics(List<Map<String, dynamic>>.from(response.data));
      }
    } catch (_) {
      if (generation != _sessionGeneration) return;
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
      if (generation == _sessionGeneration) {
        loading = false;
        notifyListeners();
      }
    }
  }
}
