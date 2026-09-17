import 'dart:convert';
import 'dart:io';

class LocalConnectionService {
  static const int port = 4040;

  final String userName;
  final String deviceId;

  ServerSocket? _server;

  LocalConnectionService({
    required this.userName,
    required this.deviceId,
  });

  Future<void> startServer() async {
    if (_server != null) {
      return;
    }

    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      port,
    );

    _server!.listen(
      _handleIncomingConnection,
    );

    print('TCP server berjalan di port $port');
  }

  Future<Socket> connectToDevice(
    String address,
  ) async {
    print('Menghubungkan ke $address:$port');

    final socket = await Socket.connect(
      address,
      port,
      timeout: const Duration(seconds: 5),
    );

    socket.write(
      'HELLO|$userName|$deviceId\n',
    );

    await socket.flush();

    print('Terhubung ke $address:$port');

    return socket;
  }

  void _handleIncomingConnection(Socket socket) {
    print(
      'Koneksi masuk dari ${socket.remoteAddress.address}',
    );

    socket
        .map((data) => utf8.decode(data))
        .transform(const LineSplitter())
        .listen(
      (message) {
        print(
          'Pesan dari ${socket.remoteAddress.address}: $message',
        );

        if (message.startsWith('HELLO|')) {
          socket.write(
            'CONNECTED|$userName|$deviceId\n',
          );

          socket.flush();
        }
      },
      onError: (error) {
        print(
          'Error koneksi masuk: $error',
        );
      },
      onDone: () {
        print(
          'Koneksi dari ${socket.remoteAddress.address} ditutup',
        );
      },
    );
  }

  Future<void> dispose() async {
    await _server?.close();
    _server = null;
  }
}