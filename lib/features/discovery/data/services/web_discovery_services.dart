import '../models/devices_models.dart';
import 'discovery_services.dart';

class WebDiscoveryService implements DiscoveryService {
  bool _isDiscovering = false;

  @override
  Future<void> startDiscovery() async {
    _isDiscovering = true;
  }

  @override
  Future<List<DeviceModel>> discoverDevices() async {
    if (!_isDiscovering) {
      return [];
    }

    await Future.delayed(
      const Duration(seconds: 1),
    );

    return const [];
  }

  @override
  Future<void> stopDiscovery() async {
    _isDiscovering = false;
  }
}