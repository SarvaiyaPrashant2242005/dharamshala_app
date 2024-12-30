import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'Booking_confirm.dart';

class RazorpayScreen extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;
  final double amount;

  const RazorpayScreen({
    Key? key,
    required this.bookingDetails,
    required this.amount,
  }) : super(key: key);

  @override
  State<RazorpayScreen> createState() => _RazorpayScreenState();
}

class _RazorpayScreenState extends State<RazorpayScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _startPayment();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      throw Exception('User is not authenticated');
    }

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
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final userDetails = await _getUserDetails();

      final List<String> roomIds = [];
      for (String selectedRoomId in widget.bookingDetails['selectedRooms']) {
        final roomDoc = await FirebaseFirestore.instance.collection('roomdetails').doc(selectedRoomId).get();
        if (roomDoc.exists) {
          roomIds.add(roomDoc.id);
        } else {
          throw Exception('Room document with ID $selectedRoomId does not exist');
        }
      }

      await FirebaseFirestore.instance.collection('bookingconfirmation').add({
        'checkInDate': widget.bookingDetails['checkInDate'] ?? '',
        'checkOutDate': widget.bookingDetails['checkOutDate'] ?? '',
        'roomIds': roomIds,
        'userId': userDetails['userId'],
        'userName': userDetails['userName'],
        'userEmail': userDetails['userEmail'],
        'userPhone': userDetails['userPhone'],
        'amountPaid': widget.amount,
        'paymentDate': Timestamp.now(),
        'paymentId': response.paymentId, // Razorpay payment ID
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful! Booking confirmed.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CongratulationsScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment processing error: $e')),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment failed. Please try again.')),
    );
    Navigator.pop(context);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet Selected: ${response.walletName}");
  }

  void _startPayment() {
    final options = {
      'key': 'rzp_test_YHUA5vrjXpLp2y',
      'amount': (widget.amount * 100).toInt(),
      'name': 'Dharamshala Management',
      'description': 'Room Booking Payment',
      'prefill': {
        'contact': widget.bookingDetails['userPhone'],
        'email': widget.bookingDetails['userEmail'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error starting payment. Please try again later.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
