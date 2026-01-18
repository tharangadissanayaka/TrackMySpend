import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AppConfig {
  static String get apiBase {
    if (kIsWeb) return 'http://localhost:3000/api';
    // Android emulator can't reach host via localhost; use 10.0.2.2
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (_) {
      // Platform may not be available (e.g., web); fallback below
    }
    return 'http://localhost:3000/api';
  }
}
