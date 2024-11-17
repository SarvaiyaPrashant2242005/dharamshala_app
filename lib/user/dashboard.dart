import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dharamshala_app/user/roomlist.dart'; // Make sure to import RoomListScreen
import 'package:dharamshala_app/user/favourites_page.dart'; // Import the FavouritesPage screen

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<Map<String, dynamic>> dharamshalas = [];
  List<Map<String, dynamic>> favouriteDharamshalas = []; // List to hold the favourite dharamshalas

  int _selectedIndex = 0; // Track bottom nav index

  @override
  void initState() {
    super.initState();
    _fetchDharamshalas();
  }

  // Fetch dharamshalas from the 'owner' collection
  Future<void> _fetchDharamshalas() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('owner')  // Fetch from the 'owner' collection
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("No dharamshalas found.");
      }

      List<Map<String, dynamic>> fetchedDharamshalas = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'dharamshalaId': doc.id,  // Store the document ID as dharamshalaId
          'name': data['dharamshalaName'] ?? 'Unnamed Dharamshala', // Correct field name for Dharamshala name
          'address': data['address'] ?? 'Unknown Location', // Dharamshala address
          'imageUrl': data['imageUrl'] ?? 'https://via.placeholder.com/150', // Placeholder if image is missing
        };
      }).toList();

      setState(() {
        dharamshalas = fetchedDharamshalas;
      });
    } catch (e) {
      print("Error fetching dharamshalas: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 1) {
      // Navigate to the FavouritesPage when the heart icon is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FavouritesPage(favouriteDharamshalas: favouriteDharamshalas)),
      );
    }
  }

  void _toggleFavourite(Map<String, dynamic> dharamshala) {
    setState(() {
      if (favouriteDharamshalas.contains(dharamshala)) {
        favouriteDharamshalas.remove(dharamshala); // Remove if already in favourites
      } else {
        favouriteDharamshalas.add(dharamshala); // Add to favourites
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Icon(Icons.location_on, color: Colors.blue),
        title: Text(
          "Haridwar, Uttarakhand",
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search Dharamshala By Name",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.filter_alt),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Recommended Dharamshalas",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              // Display the fetched Dharamshalas
              ListView.builder(
                shrinkWrap: true,
                itemCount: dharamshalas.length,
                itemBuilder: (context, index) {
                  return DharamshalaCard(
                    name: dharamshalas[index]['name'],
                    address: dharamshalas[index]['address'],
                    imageUrl: dharamshalas[index]['imageUrl'],
                    dharamshalaId: dharamshalas[index]['dharamshalaId'],
                    isLiked: favouriteDharamshalas.contains(dharamshalas[index]),
                    onLike: () => _toggleFavourite(dharamshalas[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "My bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class DharamshalaCard extends StatelessWidget {
  final String name;
  final String address;
  final String imageUrl;
  final String dharamshalaId;
  final bool isLiked;
  final VoidCallback onLike;

  DharamshalaCard({
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.dharamshalaId,
    required this.isLiked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Room List Screen when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomListScreen(dharamshalaId: dharamshalaId),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heart icon at the top left corner
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: onLike,
                ),
              ),
              // Display image if available, otherwise show "No Image"
              imageUrl == 'https://via.placeholder.com/150'
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
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
              SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                address,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}