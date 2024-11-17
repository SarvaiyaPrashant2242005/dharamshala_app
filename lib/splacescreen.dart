import 'package:dharamshala_app/login/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Icon(
                Icons.temple_hindu,
                size: 100,
                color: Colors.blueGrey,
              ),
              SizedBox(height: 20),
              // App Name
              Text(
                'Dharamshala Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade700,
                ),
              ),
              SizedBox(height: 10),
              // Tagline
              Text(
                'Simplify your stay',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey.shade500,
                ),
              ),
              SizedBox(height: 30), // Space for the button
              // Get Started Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to LoginSignUpScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginSignUpScreen()),
                  );
                },
                child: Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                  ),
                  elevation: 5, // Shadow effect
                  shadowColor: Colors.black, // Shadow color
                  textStyle: TextStyle(color: Colors.white), // Text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
