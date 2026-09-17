import 'package:flutter/material.dart';
import '../../data/models/room_models.dart';

class RoomPage extends StatelessWidget {
  final RoomModel room;
  final String userName;

  const RoomPage({
    super.key,
    required this.room,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(room.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.groups,
              size: 72,
            ),

            const SizedBox(height: 20),

            Text(
              room.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Host: ${room.hostName}',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            const Text(
              'Anggota Room',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(userName),
                subtitle: const Text('Host'),
                trailing: const Icon(
                  Icons.circle,
                  size: 12,
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint('Mulai komunikasi');
                },
                icon: const Icon(Icons.mic),
                label: const Text(
                  'Mulai Komunikasi',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Keluar Room'),
            ),
          ],
        ),
      ),
    );
  }
}