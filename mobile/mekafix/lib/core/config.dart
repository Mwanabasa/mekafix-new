import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Android emulator reaches the host machine at 10.0.2.2.
  /// Physical devices should use your LAN IP, e.g. http://192.168.0.12:8000
  static String get baseUrl {
    const configuredUrl = String.fromEnvironment('API_BASE');
    if (configuredUrl.isNotEmpty) return configuredUrl;
    return kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';
  }
}
