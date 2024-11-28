import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dharamshala_app/user/payment.dart'; // Ensure this path is correct

class BookingSummary extends StatelessWidget {
  final List<Map<String, dynamic>> selectedRooms;
  final int guests;
  final int rooms;
  final String checkIn;
  final String checkOut;

  const BookingSummary({
    Key? key,
    required this.selectedRooms,
    required this.guests,
    required this.rooms,
    required this.checkIn,
    required this.checkOut,
  }) : super(key: key);

  Future<Map<String, dynamic>> _getUserDetails() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('User is not authenticated');

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) throw Exception("User document does not exist");

      return {
        'userId': userId,
        'userName': userDoc['username'] ?? 'Unknown',
        'userEmail': userDoc['email'] ?? 'Unknown',
        'userPhone': userDoc['mobile'] ?? 'Unknown',
      };
    } catch (e) {
      throw Exception('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = selectedRooms.fold(
      0.0,
      (sum, room) => sum + double.parse(room['price']),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Check-in: $checkIn', style: const TextStyle(fontSize: 16)),
            Text('Check-out: $checkOut', style: const TextStyle(fontSize: 16)),
            Text('Total Guests: $guests', style: const TextStyle(fontSize: 16)),
            Text('Total Rooms: $rooms', style: const TextStyle(fontSize: 16)),
            const Divider(height: 20),
            const Text(
              'Selected Rooms:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: selectedRooms.length,
                itemBuilder: (context, index) {
                  final room = selectedRooms[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(room['name']),
                      subtitle: Text('Price: ₹${room['price']}'),
                      trailing: Text('Capacity: ${room['capacity']}'),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 20),
            Text(
              'Total Price: ₹${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedRooms.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No rooms selected!')),
                    );
                    return;
                  }

                  try {
                    final userDetails = await _getUserDetails();

                    // Navigate to the payment page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomPaymentPage(
                          amount: totalPrice,
                          bookingDetails: {
                            'checkInDate': checkIn,
                            'checkOutDate': checkOut,
                            'selectedRooms': selectedRooms.map((room) => room['id']).toList(),
                            ...userDetails, // Add user details
                          },
                        ),
                      ),
                    ).then((result) {
                      if (result == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking Confirmed!')),
                        );
                      }
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to process payment: $e')),
                    );
                  }
                },
                child: const Text('Pay Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
