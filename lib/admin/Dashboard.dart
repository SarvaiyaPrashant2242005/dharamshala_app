import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dharamshala_app/admin/Add%20room.dart';
import 'package:dharamshala_app/admin/Room%20list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dharamshala_app/login/login_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final String userRole;
  final Map<String, dynamic> userData;

  const DashboardScreen({
    super.key,
    required this.userRole,
    required this.userData,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<String> _userName;

  @override
  void initState() {
    super.initState();
    _userName = _getUserName();
  }

  Future<String> _getUserName() async {
    try {
      // Get the current logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return "No logged-in user"; // Handle if user is not logged in
      }

      // Debug: Print the UID to confirm we're working with the correct user
      print("Logged-in User UID: ${user.uid}");

      // Fetch user document from the 'owner' collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('owner') // Fetch data from 'owner' collection
          .doc(user.uid) // Using the UID of the current user
          .get();

      // Debug: Check if the document exists
      if (!userDoc.exists) {
        print("User document not found for UID: ${user.uid}");
        return "User document not found"; // If the document does not exist
      }

      // Debug: Print the fetched data to inspect its contents
      print("Fetched Document Data: ${userDoc.data()}");

      // Cast the data to Map<String, dynamic>
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Check if 'username' exists in the document
      if (userData.containsKey('username')) {
        return userData['username']; // Return the user name if it exists
      } else {
        return "Username field not found in document"; // Handle if username is missing
      }
    } catch (e) {
      // Handle any errors during data fetching
      print("Error fetching user data: $e");
      return "Error fetching user data"; // If an error occurs while fetching
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _userName,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No user data found"));
        }

        String userName = snapshot.data!;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/hotel_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, userName),
                  const SizedBox(height: 40),
                  Text(
                    "Welcome, $userName!",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMenuCircle(
                              icon: Icons.hotel,
                              color: Colors.purple,
                              label: 'Add Room',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AddRoomScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildMenuCircle(
                              icon: Icons.list_alt,
                              color: Colors.deepPurple,
                              label: 'Room List',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const RoomsListScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildMenuCircle(
                              icon: Icons.edit_document,
                              color: Colors.blue,
                              label: 'Edit Room',
                              onTap: () {
                                // Handle Edit Room tap
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        _buildMenuCircle(
                          icon: Icons.meeting_room,
                          color: Colors.orange,
                          label: 'Booking Room',
                          onTap: () {
                            // Handle Booking Room tap
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildLogoutButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 23,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName, // Display username dynamically
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle text overflow
                  ),
                  const Text(
                    '01XXXXXXXXX', // Replace with dynamic phone if needed
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle text overflow
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // Handle edit profile action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCircle({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set the label text color to white
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ElevatedButton(
        onPressed: () {
          FirebaseAuth.instance.signOut(); // Log out the user
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginSignUpScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
