enum DeviceStatus {
  available,
  connecting,
  connected,
  disconnected,
}

class DeviceModel {
  final String id;
  final String name;
  final String address;
  final DeviceStatus status;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
  });
}