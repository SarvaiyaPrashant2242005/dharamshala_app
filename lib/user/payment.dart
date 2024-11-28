import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Booking_confirm.dart'; // Ensure this is the correct file for the Congratulations screen

class CustomPaymentPage extends StatelessWidget {
  final double amount; // Amount to be paid
  final Map<String, dynamic> bookingDetails; // Booking details including selected rooms

  const CustomPaymentPage({
    Key? key,
    required this.amount,
    required this.bookingDetails,
  }) : super(key: key);

  Future<Map<String, dynamic>> _getUserDetails() async {
    try {
      // Fetch the current user ID from Firebase Authentication
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('User is not authenticated');
      }

      // Fetch the user details from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return {
          'userId': userId,
          'userName': userDoc['username'] ?? 'Unknown',
          'userEmail': userDoc['email'] ?? 'Unknown',
          'userPhone': userDoc['mobile'] ?? 'Unknown',
        };
      } else {
        throw Exception('User document does not exist');
      }
    } catch (e) {
      throw Exception('Failed to fetch user details: $e');
    }
  }

  Future<void> _processPayment(BuildContext context) async {
    try {
      // Ensure selectedRooms exists and is a List
      if (bookingDetails['selectedRooms'] == null ||
          bookingDetails['selectedRooms'] is! List ||
          (bookingDetails['selectedRooms'] as List).isEmpty) {
        throw Exception('No rooms selected for booking');
      }

      // Fetch user details dynamically
      final userDetails = await _getUserDetails();

      // Fetch room IDs dynamically from the roomdetails collection
      final List<String> roomIds = [];
      for (String selectedRoomId in bookingDetails['selectedRooms']) {
        final roomDoc = await FirebaseFirestore.instance.collection('roomdetails').doc(selectedRoomId).get();
        if (roomDoc.exists) {
          roomIds.add(roomDoc.id); // Collect the Firebase auto-generated room ID
        } else {
          throw Exception('Room document with ID $selectedRoomId does not exist');
        }
      }

      // Save booking details to Firestore
      await FirebaseFirestore.instance.collection('bookingconfirmation').add({
        'checkInDate': bookingDetails['checkInDate'] ?? '',
        'checkOutDate': bookingDetails['checkOutDate'] ?? '',
        'roomIds': roomIds, // List of selected room IDs
        'userId': userDetails['userId'], // Fetched dynamically
        'userName': userDetails['userName'], // Fetched dynamically
        'userEmail': userDetails['userEmail'], // Fetched dynamically
        'userPhone': userDetails['userPhone'], // Fetched dynamically
        'amountPaid': amount, // Payment amount
        'paymentDate': Timestamp.now(), // Current Timestamp
      });

      // Navigate to the Congratulations page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CongratulationsScreen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cart subtotal: ₹${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Options:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset(
                  'assets/images/Google.png', // Replace with Google Pay icon
                  height: 40,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '**** **** **** 4555',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'MM',
                      hintText: 'MM',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'YY',
                      hintText: 'YY',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'CVC',
                      hintText: 'CVC',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => _processPayment(context), // Handle payment logic
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Pay Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
