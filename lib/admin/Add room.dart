// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class AddRoomScreen extends StatefulWidget {
//   const AddRoomScreen({super.key});

//   @override
//   State<AddRoomScreen> createState() => _AddRoomScreenState();
// }

// class _AddRoomScreenState extends State<AddRoomScreen> {
//   final TextEditingController _roomNameController = TextEditingController();
//   final TextEditingController _roomCapacityController = TextEditingController();
//   final TextEditingController _roomPriceController = TextEditingController();
//   final TextEditingController _roomDescriptionController =
//       TextEditingController();
//   File? _roomImage;

//   @override
//   void dispose() {
//     _roomNameController.dispose();
//     _roomCapacityController.dispose();
//     _roomPriceController.dispose();
//     _roomDescriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _addRoomToFirestore() async {
//     if (_roomNameController.text.isEmpty ||
//         _roomCapacityController.text.isEmpty ||
//         _roomPriceController.text.isEmpty ||
//         _roomDescriptionController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields!')),
//       );
//       return;
//     }

//     // Creating a new room object
//     final newRoom = {
//       'name': _roomNameController.text,
//       'capacity': int.parse(_roomCapacityController.text),
//       'price': double.parse(_roomPriceController.text),
//       'description': _roomDescriptionController.text,
//       'image': _roomImage?.path, // Add image if necessary
//     };

//     try {
//       // Add the new room to Firestore
//       await FirebaseFirestore.instance.collection('roomdetails').add(newRoom);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Room added successfully!')),
//       );

//       // Go back to previous screen
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Room'),
//         backgroundColor: Colors.purple,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Room Name
//               TextField(
//                 controller: _roomNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Room Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Room Capacity
//               TextField(
//                 controller: _roomCapacityController,
//                 decoration: InputDecoration(
//                   labelText: 'Room Capacity',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 16),

//               // Room Price
//               TextField(
//                 controller: _roomPriceController,
//                 decoration: InputDecoration(
//                   labelText: 'Room Price',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 16),

//               // Room Description
//               TextField(
//                 controller: _roomDescriptionController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'Room Description',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Add Room Button
//               ElevatedButton(
//                 onPressed: _addRoomToFirestore,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.purple,
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                 ),
//                 child: const Text(
//                   'Add Room',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For storing image in Firebase Storage

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override 
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomCapacityController = TextEditingController();
  final TextEditingController _roomPriceController = TextEditingController();
  final TextEditingController _roomDescriptionController = TextEditingController();
  File? _roomImage;

  @override
  void dispose() {
    _roomNameController.dispose();
    _roomCapacityController.dispose();
    _roomPriceController.dispose();
    _roomDescriptionController.dispose();
    super.dispose();
  }

  // Function to upload image to Firebase Storage
  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('room_images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageReference.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _addRoomToFirestore() async {
    if (_roomNameController.text.isEmpty ||
        _roomCapacityController.text.isEmpty ||
        _roomPriceController.text.isEmpty ||
        _roomDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    // Parse capacity and price values
    int? capacity = int.tryParse(_roomCapacityController.text);
    double? price = double.tryParse(_roomPriceController.text);

    if (capacity == null || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid capacity or price!')),
      );
      return;
    }

    String? imageUrl;
    if (_roomImage != null) {
      // If there's an image, upload it to Firebase Storage
      imageUrl = await _uploadImageToFirebase(_roomImage!);
    }

    // Creating a new room object
    final newRoom = {
      'name': _roomNameController.text,
      'capacity': capacity,
      'price': price,
      'description': _roomDescriptionController.text,
      'image': imageUrl, // Add image URL if available
    };

    try {
      // Add the new room to Firestore
      await FirebaseFirestore.instance.collection('roomdetails').add(newRoom);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room added successfully!')),
      );

      // Go back to previous screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Room'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Name
              TextField(
                controller: _roomNameController,
                decoration: InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Room Capacity
              TextField(
                controller: _roomCapacityController,
                decoration: InputDecoration(
                  labelText: 'Room Capacity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Room Price
              TextField(
                controller: _roomPriceController,
                decoration: InputDecoration(
                  labelText: 'Room Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Room Description
              TextField(
                controller: _roomDescriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Room Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Add Room Button
              ElevatedButton(
                onPressed: _addRoomToFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Add Room',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

