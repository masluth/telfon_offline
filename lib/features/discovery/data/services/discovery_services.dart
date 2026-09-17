import '../models/devices_models.dart';

abstract class DiscoveryService {
  Future<List<DeviceModel>> discoverDevices();

  Future<void> startDiscovery();

  Future<void> stopDiscovery();
}