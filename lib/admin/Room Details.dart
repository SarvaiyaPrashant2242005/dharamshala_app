import 'package:flutter/material.dart';

class RoomDetailScreen extends StatelessWidget {
  final Map<String, dynamic> room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(room['name']),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description: ${room['description']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Capacity: ${room['capacity']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Price: \$${room['price']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Removed the image display as per the updated requirement
          ],
        ),
      ),
    );
  }
}