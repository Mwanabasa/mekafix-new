import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mekafix/core/api.dart';
import 'package:mekafix/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionState extends ChangeNotifier {
  AppUser? user;
  String? token;
  bool ready = false;
  String? error;
  double latitude = 0.3291;
  double longitude = 32.5686;

  bool get isLoggedIn => token != null && user != null;

  Future<void> bootstrap() async {
    token = await ApiClient.readToken();
    await ApiClient.instance.attachToken(token);
    if (token != null) {
      try {
        final response = await ApiClient.instance.dio.get('/auth/me/');
        user = AppUser.fromJson(response.data);
      } catch (_) {
        await logout();
      }
    }
    ready = true;
    notifyListeners();
    unawaited(
      refreshLocation().timeout(
        const Duration(seconds: 5),
        onTimeout: () {},
      ),
    );
  }

  Future<void> refreshLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      latitude = position.latitude;
      longitude = position.longitude;
      if (isLoggedIn) {
        await ApiClient.instance.dio.post('/auth/device/', data: {
          'latitude': latitude,
          'longitude': longitude,
        });
      }
      notifyListeners();
    } catch (_) {
      // Keep the default coordinates when location is unavailable.
    }
  }

  Future<void> _storeAuth(Map<String, dynamic> payload) async {
    token = payload['access'] as String;
    user = AppUser.fromJson(payload['user'] as Map<String, dynamic>);
    await ApiClient.persistToken(token!);
    await ApiClient.instance.attachToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', user!.role);
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    error = null;
    try {
      final response = await ApiClient.instance.dio.post('/auth/login/', data: {
        'phone': phone,
        'password': password,
      });
      await _storeAuth(response.data);
      return true;
    } catch (_) {
      error = 'Could not sign in. Check phone and password.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String phone,
    required String fullName,
    required String password,
    required String role,
    String garageName = '',
  }) async {
    error = null;
    try {
      final response =
          await ApiClient.instance.dio.post('/auth/register/', data: {
        'phone': phone,
        'full_name': fullName,
        'password': password,
        'role': role,
        'garage_name': garageName,
        'latitude': latitude,
        'longitude': longitude,
      });
      await _storeAuth(response.data);
      return true;
    } catch (_) {
      error = 'Registration failed. That phone may already be in use.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    user = null;
    token = null;
    await ApiClient.clear();
    await ApiClient.instance.attachToken(null);
    notifyListeners();
  }
}
