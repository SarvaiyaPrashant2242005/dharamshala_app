import 'package:dharamshala_app/user/booking_summary.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: BookingForm(selectedRooms: [])));

class BookingForm extends StatefulWidget {
  final List<Map<String, dynamic>> selectedRooms;

  const BookingForm({super.key, required this.selectedRooms});

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guests = 1;
  int _rooms = 1;

  bool get _isContinueEnabled =>
      _checkInController.text.isNotEmpty &&
      _checkOutController.text.isNotEmpty &&
      _checkOutDate != null &&
      _checkInDate != null &&
      _checkOutDate!.isAfter(_checkInDate!); // Check-out must be after Check-in

  void _validateDates(BuildContext context) {
    if (_checkOutDate != null &&
        _checkInDate != null &&
        !_checkOutDate!.isAfter(_checkInDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Check-out date must be after Check-in date."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Form'),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome to Haridwar!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _checkInController,
              decoration: const InputDecoration(
                labelText: 'Check-in',
                hintText: 'DD/MM/YY',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () {
                _selectDate(context, _checkInController, isCheckIn: true);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _checkOutController,
              decoration: const InputDecoration(
                labelText: 'Check-out',
                hintText: 'DD/MM/YY',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () {
                _selectDate(context, _checkOutController, isCheckIn: false);
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Guests'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (_guests > 1) _guests--;
                        });
                      },
                    ),
                    Text('$_guests'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _guests++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rooms'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (_rooms > 1) _rooms--;
                        });
                      },
                    ),
                    Text('$_rooms'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _rooms++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isContinueEnabled
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingSummary(
                            selectedRooms: widget.selectedRooms,
                            guests: _guests,
                            rooms: _rooms,
                            checkIn: _checkInController.text,
                            checkOut: _checkOutController.text,
                          ),
                        ),
                      );
                    }
                  : null, // Disable if conditions are not met
              style: ElevatedButton.styleFrom(
                backgroundColor: _isContinueEnabled ? Colors.blue : Colors.grey,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller,
      {required bool isCheckIn}) async {
    DateTime? initialDate = isCheckIn
        ? DateTime.now()
        : (_checkInDate ?? DateTime.now()).add(const Duration(days: 1));
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isCheckIn ? DateTime.now() : (_checkInDate ?? DateTime.now()),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        controller.text =
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
        if (isCheckIn) {
          _checkInDate = selectedDate;
        } else {
          _checkOutDate = selectedDate;
          _validateDates(context); // Validate the selected dates
        }
      });
    }
  }
}