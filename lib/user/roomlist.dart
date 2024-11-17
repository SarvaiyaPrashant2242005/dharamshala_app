import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoomListScreen extends StatefulWidget {
  final String dharamshalaId;

  const RoomListScreen({Key? key, required this.dharamshalaId}) : super(key: key);

  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  void _fetchRooms() {
    FirebaseFirestore.instance
        .collection('roomdetails')
        .where('dharamshala_id', isEqualTo: widget.dharamshalaId)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        print("No rooms found for Dharamshala ID: ${widget.dharamshalaId}");
      } else {
        List<Map<String, dynamic>> fetchedRooms = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return {
            'name': data?['name'] ?? 'Unknown Room',
            'capacity': data?['capacity'] ?? 0,
            'price': data?['price']?.toString() ?? 'Not Available',
            'image': data?['image'] ?? '', // Handle null images
            'description': data?['description'] ?? 'No description',
          };
        }).toList();

        setState(() {
          rooms = fetchedRooms;
        });
      }
      setState(() {
        isLoading = false;
      });
    }, onError: (e) {
      print("Error fetching rooms: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching room data: $e")),
      );
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rooms"),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
              ? const Center(
                  child: Text(
                    "No rooms available.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return RoomCard(
                      name: rooms[index]['name'],
                      capacity: rooms[index]['capacity'],
                      price: rooms[index]['price'],
                      imageUrl: rooms[index]['image'],
                      description: rooms[index]['description'],
                    );
                  },
                ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String name;
  final int capacity;
  final String price;
  final String imageUrl;
  final String description;

  const RoomCard({
    Key? key,
    required this.name,
    required this.capacity,
    required this.price,
    required this.imageUrl,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 150,
                  color: Colors.grey,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 5),
                Text(
                  "Capacity: $capacity persons",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  "Price: $price",
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
