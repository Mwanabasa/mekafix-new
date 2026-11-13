import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mekafix/core/api.dart';
import 'package:mekafix/core/offline.dart';
import 'package:mekafix/models.dart';
import 'package:mekafix/state/session.dart';

class JobsState extends ChangeNotifier {
  SessionState? session;
  List<JobRequest> jobs = [];
  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> notifications = [];
  bool loading = false;
  bool _hasBoundSession = false;
  int? _boundUserId;
  int _sessionGeneration = 0;

  void bind(SessionState next) {
    final userId = next.user?.id;
    if (_hasBoundSession && _boundUserId != userId) {
      _sessionGeneration++;
      jobs = [];
      vehicles = [];
      notifications = [];
      loading = false;
    }
    _hasBoundSession = true;
    _boundUserId = userId;
    session = next;
  }

  Future<void> refresh() async {
    final currentSession = session;
    final user = currentSession?.user;
    if (currentSession == null || !currentSession.isLoggedIn || user == null) {
      return;
    }
    final generation = _sessionGeneration;
    loading = true;
    notifyListeners();
    try {
      await _flushQueue();
      if (generation != _sessionGeneration) return;
      final jobsRes = await ApiClient.instance.dio.get('/jobs/requests/');
      if (generation != _sessionGeneration) return;
      jobs = (jobsRes.data as List)
          .map((row) => JobRequest(row as Map<String, dynamic>))
          .toList();
      final vehiclesRes = await ApiClient.instance.dio.get('/jobs/vehicles/');
      if (generation != _sessionGeneration) return;
      vehicles = List<Map<String, dynamic>>.from(vehiclesRes.data);
      final notes = await ApiClient.instance.dio.get('/notifications/');
      if (generation != _sessionGeneration) return;
      notifications = List<Map<String, dynamic>>.from(notes.data);
    } catch (_) {
      // Keep previous in-memory state when the network drops.
    } finally {
      if (generation == _sessionGeneration) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _flushQueue() async {
    if (kIsWeb) return;
    final pending = await OfflineStore.instance.pending();
    for (final item in pending) {
      try {
        final payload =
            jsonDecode(item['payload'] as String) as Map<String, dynamic>;
        if (item['kind'] == 'rate') {
          await ApiClient.instance.dio
              .post('/jobs/requests/${payload['id']}/rate/', data: payload);
        }
        await OfflineStore.instance.removePending(item['id'] as int);
      } catch (_) {
        break;
      }
    }
  }

  Future<JobRequest?> createJob(Map<String, dynamic> data) async {
    final response =
        await ApiClient.instance.dio.post('/jobs/requests/', data: data);
    await refresh();
    return JobRequest(response.data as Map<String, dynamic>);
  }

  Future<void> accept(int id) async {
    await ApiClient.instance.dio.post('/jobs/requests/$id/accept/');
    await refresh();
  }

  Future<void> reject(int id) async {
    await ApiClient.instance.dio.post('/jobs/requests/$id/reject/');
    await refresh();
  }

  Future<void> findAnotherMechanic(int id) async {
    await ApiClient.instance.dio.post('/jobs/requests/$id/reassign/');
    await refresh();
  }

  Future<void> updateStatus(int id, String status) async {
    await ApiClient.instance.dio
        .post('/jobs/requests/$id/status/', data: {'status': status});
    await refresh();
  }

  Future<void> rate(int id, int stars, String comment) async {
    try {
      await ApiClient.instance.dio.post('/jobs/requests/$id/rate/', data: {
        'stars': stars,
        'comment': comment,
      });
    } catch (_) {
      await OfflineStore.instance
          .enqueue('rate', {'id': id, 'stars': stars, 'comment': comment});
    }
    await refresh();
  }

  Future<void> pay(int id, int amount, String momoPhone) async {
    await ApiClient.instance.dio.post('/jobs/requests/$id/pay/', data: {
      'amount': amount,
      'momo_phone': momoPhone,
      'method': 'momo',
    });
    await refresh();
  }

  Future<void> addVehicle(Map<String, dynamic> data) async {
    await ApiClient.instance.dio.post('/jobs/vehicles/', data: data);
    await refresh();
  }
}
