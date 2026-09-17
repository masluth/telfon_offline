import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentityService {
  static const String _deviceIdKey = 'device_id';

  Future<String> getDeviceId() async {
    final preferences = SharedPreferencesAsync();

    final existingId = await preferences.getString(_deviceIdKey);

    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    final newId = _generateDeviceId();

    await preferences.setString(
      _deviceIdKey,
      newId,
    );

    return newId;
  }

  String _generateDeviceId() {
    final random = Random();

    final timestamp =
        DateTime.now().millisecondsSinceEpoch.toRadixString(16);

    final randomPart = List.generate(
      8,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();

    return 'intercom-$timestamp-$randomPart';
  }
}