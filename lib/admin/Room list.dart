import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    // Fetch the documents from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('roomdetails').get();

    if (querySnapshot.docs.isEmpty) {
      print("No rooms found in the Firestore database.");
    }

    // Mapping the documents to a list of room data
    List<Map<String, dynamic>> fetchedRooms = querySnapshot.docs.map((doc) {
      // Safely get document data
      final data = doc.data() as Map<String, dynamic>?;
      
      // If data is null, we use empty or default values
      return {
        'name': data?['name'] ?? 'Unknown',  // Default to 'Unknown' if field is missing
        'capacity': data?['capacity'] ?? 0,  // Default to 0 if field is missing
        'price': data?['price'] ?? 0.0,      // Default to 0 if field is missing
        'description': data?['desc'] ?? 'No description',  // Default to 'No description' if missing
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
