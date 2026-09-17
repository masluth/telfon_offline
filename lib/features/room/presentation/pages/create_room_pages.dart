import 'package:flutter/material.dart';
import 'room_pages.dart';
import '../../data/models/room_models.dart';

class CreateRoomPage extends StatefulWidget {
  final String userName;

  const CreateRoomPage({
    super.key,
    required this.userName,
  });

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController _roomNameController =
      TextEditingController();

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  void _createRoom() {
    final roomName = _roomNameController.text.trim();

    if (roomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nama room terlebih dahulu'),
        ),
      );
      return;
    }

    final room = RoomModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: roomName,
      hostName: widget.userName,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RoomPage(
          room: room,
          userName: widget.userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Room'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  size: 72,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Buat Room Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Buat room untuk mulai terhubung '
                  'dengan perangkat lain.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                const Text(
                  'Nama Room',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _roomNameController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Touring Bogor',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _createRoom,
                    child: const Text(
                      'Buat Room',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
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