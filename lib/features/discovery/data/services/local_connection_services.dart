import 'dart:convert';
import 'dart:io';

import '../models/signalling_message.dart';

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
      SignalingMessage(
        type: 'HELLO',
        userName: userName,
        deviceId: deviceId,
      ).toLine(),
    );

    await socket.flush();

    print('Terhubung ke $address:$port');

    _listenToSocket(socket);

    return socket;
  }

  void _handleIncomingConnection(Socket socket) {
    print(
      'Koneksi masuk dari ${socket.remoteAddress.address}',
    );

    _listenToSocket(socket);
  }

  void _listenToSocket(Socket socket) {
    socket
        .map((data) => utf8.decode(data))
        .transform(const LineSplitter())
        .listen(
      (line) {
        final message = SignalingMessage.fromLine(line);

        _handleMessage(
          socket,
          message,
        );
      },
      onError: (error) {
        print('Error koneksi: $error');
      },
      onDone: () {
        print(
          'Koneksi dari ${socket.remoteAddress.address} ditutup',
        );
      },
    );
  }

  void _handleMessage(
    Socket socket,
    SignalingMessage message,
  ) {
    print(
      'Pesan diterima: ${message.type}',
    );

    switch (message.type) {
      case 'HELLO':
        _handleHello(socket, message);
        break;

      case 'CONNECTED':
        print(
          'Handshake berhasil dengan '
          '${message.userName ?? 'perangkat'}',
        );

        _sendMessage(
          socket,
          const SignalingMessage(
            type: 'PING',
          ),
        );
        break;

      case 'PING':
        print('PING diterima');

        _sendMessage(
          socket,
          const SignalingMessage(
            type: 'PONG',
          ),
        );
        break;

      case 'PONG':
        print('PONG diterima');

        break;

      default:
        print(
          'Pesan tidak dikenal: ${message.type}',
        );
    }
  }

  void _handleHello(
    Socket socket,
    SignalingMessage message,
  ) {
    print(
      'HELLO dari ${message.userName ?? 'perangkat'} '
      '(${message.deviceId ?? 'unknown'})',
    );

    _sendMessage(
      socket,
      SignalingMessage(
        type: 'CONNECTED',
        userName: userName,
        deviceId: deviceId,
      ),
    );
  }

  void _sendMessage(
    Socket socket,
    SignalingMessage message,
  ) {
    socket.write(
      message.toLine(),
    );

    socket.flush();
  }

  Future<void> dispose() async {
    await _server?.close();
    _server = null;
  }
}