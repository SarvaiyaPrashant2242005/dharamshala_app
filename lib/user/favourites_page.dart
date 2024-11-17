import 'package:dharamshala_app/user/dashboard.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatelessWidget {
  final List<Map<String, dynamic>> favouriteDharamshalas;

  FavouritesPage({required this.favouriteDharamshalas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourites'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Disable default back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the dashboard screen when back arrow is clicked
            Navigator.pop(context);
          },
        ),
      ),
      body: favouriteDharamshalas.isEmpty
          ? Center(child: Text("No favourites yet"))
          : ListView.builder(
              itemCount: favouriteDharamshalas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(favouriteDharamshalas[index]['name']),
                  subtitle: Text(favouriteDharamshalas[index]['address']),
                  leading: Image.network(favouriteDharamshalas[index]['imageUrl']),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Heart icon should be selected
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // If the Home button is tapped, navigate back to the UserDashboard
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => UserDashboard()), // Navigate to UserDashboard
              (Route<dynamic> route) => false, // Remove all routes so that the dashboard is the only screen
            );
          }
        },
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
