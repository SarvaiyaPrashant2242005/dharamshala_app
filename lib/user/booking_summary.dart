import 'package:dharamshala_app/user/payment.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    // Calculate the total price
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
                      subtitle: Text('Price: ${room['price']}'),
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
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomPaymentPage(
          amount: totalPrice,
          bookingDetails: 'Booking from $checkIn to $checkOut for $guests guests',
        ),
      ),
    ).then((result) {
      if (result == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking Confirmed!')),
        );
        // Handle post-payment actions here, like updating Firestore or navigating back
      }
    });
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
