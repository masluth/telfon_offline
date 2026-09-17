import '../models/devices_models.dart';
import 'discovery_services.dart';

class MockDiscoveryService implements DiscoveryService {
  bool _isDiscovering = false;

  @override
  Future<List<DeviceModel>> discoverDevices() async {
    if (!_isDiscovering) {
      return [];
    }

    await Future.delayed(
      const Duration(seconds: 2),
    );

    return const [
      DeviceModel(
        id: 'device-001',
        name: 'Andi',
        address: '192.168.1.10',
        status: DeviceStatus.connected,
      ),
      DeviceModel(
        id: 'device-002',
        name: 'Budi',
        address: '192.168.1.11',
        status: DeviceStatus.connected,
      ),
    ];
  }

  @override
  Future<void> startDiscovery() async {
    _isDiscovering = true;
  }

  @override
  Future<void> stopDiscovery() async {
    _isDiscovering = false;
  }
}