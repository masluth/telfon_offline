class SignalingMessage {
  final String type;
  final String? userName;
  final String? deviceId;

  const SignalingMessage({
    required this.type,
    this.userName,
    this.deviceId,
  });

  factory SignalingMessage.fromLine(String line) {
    final parts = line.split('|');

    final type = parts.isNotEmpty ? parts[0] : '';

    String? userName;
    String? deviceId;

    for (final part in parts.skip(1)) {
      if (part.startsWith('name=')) {
        userName = part.substring(5);
      }

      if (part.startsWith('device_id=')) {
        deviceId = part.substring(10);
      }
    }

    return SignalingMessage(
      type: type,
      userName: userName,
      deviceId: deviceId,
    );
  }

  String toLine() {
    final fields = <String>[type];

    if (userName != null) {
      fields.add('name=$userName');
    }

    if (deviceId != null) {
      fields.add('device_id=$deviceId');
    }

    return '${fields.join('|')}\n';
  }
}