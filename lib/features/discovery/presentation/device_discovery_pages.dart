import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/models/devices_models.dart';
import '../data/services/device_identity_services.dart';
import '../data/services/discovery_services.dart';
import '../data/services/local_connection_services.dart';
import '../data/services/local_discovery_services.dart';
import '../data/services/web_discovery_services.dart';

class DeviceDiscoveryPage extends StatefulWidget {
  final String userName;

  const DeviceDiscoveryPage({
    super.key,
    required this.userName,
  });

  @override
  State<DeviceDiscoveryPage> createState() =>
      _DeviceDiscoveryPageState();
}

class _DeviceDiscoveryPageState
    extends State<DeviceDiscoveryPage> {
  late final DiscoveryService _discoveryService;

  LocalConnectionService? _connectionService;

  bool _isScanning = false;
  bool _isConnecting = false;

  String? _connectedDeviceId;

  List<DeviceModel> _devices = [];

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _discoveryService = WebDiscoveryService();
    } else {
      _discoveryService = LocalDiscoveryService(
        userName: widget.userName,
      );

      _startConnectionServer();
    }
  }

  Future<void> _startConnectionServer() async {
    try {
      final identityService = DeviceIdentityService();

      final deviceId =
          await identityService.getDeviceId();

      final connectionService =
          LocalConnectionService(
        userName: widget.userName,
        deviceId: deviceId,
      );

      await connectionService.startServer();

      _connectionService = connectionService;
    } catch (error) {
      debugPrint(
        'Gagal menjalankan connection server: $error',
      );
    }
  }

  @override
  void dispose() {
    _discoveryService.stopDiscovery();
    _connectionService?.dispose();

    super.dispose();
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    try {
      await _discoveryService.startDiscovery();

      final devices =
          await _discoveryService.discoverDevices();

      if (!mounted) {
        return;
      }

      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mencari pengguna: $error',
          ),
        ),
      );
    }
  }

  Future<void> _stopScanning() async {
    await _discoveryService.stopDiscovery();

    if (!mounted) {
      return;
    }

    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _connectToDevice(
    DeviceModel device,
  ) async {
    final connectionService = _connectionService;

    if (connectionService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Connection server belum siap.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      final socket =
          await connectionService.connectToDevice(
        device.address,
      );

      if (!mounted) {
        await socket.close();
        return;
      }

      setState(() {
        _isConnecting = false;
        _connectedDeviceId = device.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terhubung dengan ${device.name}',
          ),
        ),
      );

      socket.listen(
        (data) {
          debugPrint(
            'Data diterima: ${String.fromCharCodes(data)}',
          );
        },
        onError: (error) {
          debugPrint(
            'Socket error: $error',
          );
        },
        onDone: () {
          debugPrint(
            'Koneksi dengan ${device.name} ditutup',
          );
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isConnecting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal terhubung ke ${device.name}: $error',
          ),
        ),
      );
    }
  }

  String _statusText(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.available:
        return 'Tersedia';

      case DeviceStatus.connecting:
        return 'Menghubungkan...';

      case DeviceStatus.connected:
        return 'Terhubung';

      case DeviceStatus.disconnected:
        return 'Terputus';
    }
  }

  Color _statusColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.available:
        return Colors.green;

      case DeviceStatus.connecting:
        return Colors.orange;

      case DeviceStatus.connected:
        return Colors.green;

      case DeviceStatus.disconnected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Pengguna'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                const Icon(
                  Icons.people_outline,
                  size: 72,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Pengguna di Jaringan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  kIsWeb
                      ? 'Mode Web: discovery lokal belum aktif.'
                      : 'Cari pengguna lain yang menjalankan '
                        'Intercom di jaringan lokal.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isScanning
                            ? _stopScanning
                            : _scanDevices,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      _isScanning
                          ? 'Berhenti Mencari'
                          : 'Cari Pengguna',
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (_devices.isEmpty &&
                    !_isScanning)
                  Expanded(
                    child: Center(
                      child: Text(
                        kIsWeb
                            ? 'Belum ada pengguna ditemukan.\n'
                              'Gunakan Android untuk testing '
                              'jaringan lokal.'
                            : 'Belum ada pengguna ditemukan.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                if (_isScanning)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Sedang mencari pengguna...',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                if (_devices.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
                      itemCount: _devices.length,
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(height: 8),
                      itemBuilder:
                          (context, index) {
                        final device =
                            _devices[index];

                        final isConnected =
                            _connectedDeviceId ==
                                device.id;

                        return Card(
                          child: ListTile(
                            leading:
                                const CircleAvatar(
                              child: Icon(
                                Icons.person,
                              ),
                            ),
                            title:
                                Text(device.name),
                            subtitle: Text(
                              '${device.address}\n'
                              '${isConnected ? 'Terhubung' : _statusText(device.status)}',
                            ),
                            isThreeLine: true,
                            trailing: isConnected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.circle,
                                    size: 12,
                                  ),
                            onTap:
                                _isConnecting
                                    ? null
                                    : () =>
                                        _connectToDevice(
                                          device,
                                        ),
                          ),
                        );
                      },
                    ),
                  ),

                if (_isConnecting)
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 16,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Menghubungkan...',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}