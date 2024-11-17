import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dharamshala_app/user/booking_form.dart'; // Make sure to import the BookingForm screen

class RoomListScreen extends StatefulWidget {
  final String dharamshalaId;

  const RoomListScreen({Key? key, required this.dharamshalaId}) : super(key: key);

  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;
  List<int> selectedRooms = [];  // Track selected rooms

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
            'image': data?['image'] ?? '',
            'description': data?['description'] ?? 'No description',
            'id': doc.id,  // Store the document ID to track selections
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

  void _onRoomSelected(bool? value, int index) {
    setState(() {
      if (value == true) {
        selectedRooms.add(index);  // Add to selected rooms
      } else {
        selectedRooms.remove(index);  // Remove from selected rooms
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rooms"),
        backgroundColor: Colors.blue,
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
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          return RoomCard(
                            name: rooms[index]['name'],
                            capacity: rooms[index]['capacity'],
                            price: rooms[index]['price'],
                            imageUrl: rooms[index]['image'],
                            description: rooms[index]['description'],
                            isSelected: selectedRooms.contains(index),
                            onSelected: (value) => _onRoomSelected(value, index),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: selectedRooms.isEmpty
                            ? null  // Disable button if no room is selected
                            : () {
                                // Navigate to booking form with selected rooms
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingForm(
                                      selectedRooms: selectedRooms
                                          .map((index) => rooms[index])
                                          .toList(),
                                    ),
                                  ),
                                );
                              },
                        child: const Text("Continue"),
                      ),
                    ),
                  ],
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
  final bool isSelected;
  final Function(bool?) onSelected;

  const RoomCard({
    Key? key,
    required this.name,
    required this.capacity,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Toggle the checkbox when the card is tapped
        onSelected(!isSelected);
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,  // Align text to the left
            children: [
              // Show "No Image" if image URL is empty or missing
              imageUrl.isEmpty || imageUrl == 'https://via.placeholder.com/150'
                  ? Container(
                      width: double.infinity,
                      height: 120,
                      color: Colors.blue,  // Background color for "No Image"
                      alignment: Alignment.center,
                      child: Text(
                        'No Image',
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
                      ),
                    )
                  : Image.network(imageUrl),
              SizedBox(height: 10),
              // Align the room details to the left
              Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text('Capacity: $capacity'),
              SizedBox(height: 5),
              Text('Price: $price'),
              SizedBox(height: 5),
              Text(description),
              SizedBox(height: 10),
              // Checkbox aligned to the left
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,  // Remove padding for left alignment
                title: const Text('Select Room'),
                value: isSelected,
                onChanged: onSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
