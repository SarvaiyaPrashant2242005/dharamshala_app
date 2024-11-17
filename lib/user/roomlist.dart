import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoomListScreen extends StatefulWidget {
  final String dharamshalaId;

  RoomListScreen({required this.dharamshalaId});

  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      // Fetch rooms for the specific dharamshala by filtering the 'dharamshala_id'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('roomdetails')
          .where('dharamshala_id', isEqualTo: widget.dharamshalaId)
          .get();

      // Check if no rooms are found
      if (querySnapshot.docs.isEmpty) {
        print("No rooms found for this Dharamshala.");
      }

      // Map the rooms to a list
      List<Map<String, dynamic>> fetchedRooms = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return {
          'name': data?['name'] ?? 'Unknown Room',
          'capacity': data?['capacity'] ?? 0,
          'price': data?['price'] ?? 'Not Available',
          'imageUrl': data?['imageUrl'] ?? 'https://via.placeholder.com/150',
        };
      }).toList();

      // Update the state with fetched rooms
      setState(() {
        rooms = fetchedRooms;
      });
    } catch (e) {
      print("Error fetching rooms: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching room data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rooms"),
      ),
      body: rooms.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                return RoomCard(
                  name: rooms[index]['name'],
                  capacity: rooms[index]['capacity'],
                  price: rooms[index]['price'],
                  imageUrl: rooms[index]['imageUrl'],
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

  RoomCard({
    required this.name,
    required this.capacity,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Capacity: $capacity persons", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 4),
                Text("Price: $price", style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
