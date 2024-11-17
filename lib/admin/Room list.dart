import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import to get current user

class RoomsListScreen extends StatefulWidget {
  const RoomsListScreen({super.key});

  @override
  _RoomsListScreenState createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  // To store room data fetched from Firestore
  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    super.initState();
    // Fetch room data when the screen is loaded
    _fetchRooms();
  }

  // Function to fetch rooms from Firestore
  Future<void> _fetchRooms() async {
    try {
      // Get the current logged-in user's ID (dharamshala_id)
      String? ownerId = FirebaseAuth.instance.currentUser?.uid; // This will be your dharamshala_id

      if (ownerId == null) {
        // Handle the case when user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in!')),
        );
        return;
      }

      // Fetch the rooms filtered by dharamshala_id (ownerId)
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('roomdetails')
          .where('dharamshala_id', isEqualTo: ownerId) // Filter by dharamshala_id
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("No rooms found for this Dharamshala.");
      }

      // Mapping the documents to a list of room data
      List<Map<String, dynamic>> fetchedRooms = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        
        return {
          'name': data?['name'] ?? 'Unknown',  // Default to 'Unknown' if field is missing
          'capacity': data?['capacity'] ?? 0,  // Default to 0 if field is missing
          'price': data?['price'] ?? 0.0,      // Default to 0 if field is missing
          'description': data?['description'] ?? 'No description',  // Default to 'No description' if missing
        };
      }).toList();

      // Update the state with the fetched rooms
      setState(() {
        rooms = fetchedRooms;
      });
    } catch (e) {
      // Handle errors if any
      print("Error fetching rooms: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms List'),
        backgroundColor: Colors.purple,
      ),
      body: rooms.isEmpty
          ? const Center(child: CircularProgressIndicator())  // Show loading indicator if no data yet
          : ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return ListTile(
                  title: Text(room['name']),
                  subtitle: Text('Capacity: ${room['capacity']} | Price: \$${room['price']}'),
                  onTap: () {
                    // You can add navigation to room details page if needed
                    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoomDetailScreen(room: room)));
                  },
                );
              },
            ),
    );
  }
}
