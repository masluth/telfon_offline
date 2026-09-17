import 'package:mdns_dart/mdns_dart.dart';

import '../models/devices_models.dart';
import 'device_identity_services.dart';
import 'discovery_services.dart';

class LocalDiscoveryService implements DiscoveryService {
  static const String serviceType = '_intercom._tcp';
  static const int servicePort = 4040;

  final String userName;

  final DeviceIdentityService _identityService =
      DeviceIdentityService();

  MDNSServer? _server;

  bool _isDiscovering = false;

  String? _deviceId;

  LocalDiscoveryService({
    required this.userName,
  });

  @override
  Future<void> startDiscovery() async {
    if (_isDiscovering) {
      return;
    }

    _isDiscovering = true;

    _deviceId = await _identityService.getDeviceId();

    await _startAdvertising();
  }

  Future<void> _startAdvertising() async {
    if (_server != null) {
      return;
    }

    final deviceId = _deviceId;

    if (deviceId == null) {
      return;
    }

    final service = await MDNSService.create(
      instance: userName,
      service: serviceType,
      port: servicePort,
      txt: [
        'app=intercom',
        'name=$userName',
        'device_id=$deviceId',
        'version=1',
      ],
    );

    final zone = MultiServiceZone();

    zone.addService(service);

    final server = MDNSServer(
      MDNSServerConfig(
        zone: zone,
      ),
    );

    await server.start();

    _server = server;
  }

  @override
  Future<List<DeviceModel>> discoverDevices() async {
    if (!_isDiscovering) {
      return [];
    }

    final ownDeviceId = _deviceId;

    if (ownDeviceId == null) {
      return [];
    }

    try {
      final services = await MDNSClient.discover(
        serviceType,
        timeout: const Duration(seconds: 3),
      );

      final devices = <DeviceModel>[];

      for (final service in services) {
        final address = service.primaryAddress?.address;

        if (address == null) {
          continue;
        }

        final infoFields = service.infoFields;

        String? deviceId;
        String? discoveredName;

        for (final field in infoFields) {
          if (field.startsWith('device_id=')) {
            deviceId = field.substring('device_id='.length);
          }

          if (field.startsWith('name=')) {
            discoveredName = field.substring('name='.length);
          }
        }

        if (deviceId == null || deviceId.isEmpty) {
          continue;
        }

        if (deviceId == ownDeviceId) {
          continue;
        }

        devices.add(
          DeviceModel(
            id: deviceId,
            name: discoveredName ?? service.name,
            address: address,
            status: DeviceStatus.available,
          ),
        );
      }

      return devices;
    } catch (error) {
      return [];
    }
  }

  @override
  Future<void> stopDiscovery() async {
    _isDiscovering = false;

    final server = _server;

    if (server != null) {
      await server.stop();
      _server = null;
    }
  }
}