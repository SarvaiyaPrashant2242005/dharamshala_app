import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [Permission.storage].request();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _roomImage = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('room_images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageReference.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
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
      imageUrl = await _uploadImageToFirebase(_roomImage!);
    }

    String? ownerId = FirebaseAuth.instance.currentUser?.uid;

    if (ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    final newRoom = {
      'name': _roomNameController.text,
      'capacity': capacity,
      'price': price,
      'description': _roomDescriptionController.text,
      'image': imageUrl,
      'dharamshala_id': ownerId,
    };

    try {
      await FirebaseFirestore.instance.collection('roomdetails').add(newRoom);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room added successfully!')),
      );
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
        backgroundColor: Color.fromRGBO(33, 150, 243, 1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(33, 150, 243, 1),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Select Image',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_roomImage != null)
                Center(
                  child: Image.file(
                    _roomImage!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addRoomToFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(33, 150, 243, 1),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Add Room',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
