import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dharamshala_app/user/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../admin/Dashboard.dart';

class LoginSignUpScreen extends StatefulWidget {
  const LoginSignUpScreen({Key? key}) : super(key: key);

  @override
  _LoginSignUpScreenState createState() => _LoginSignUpScreenState();
}

class _LoginSignUpScreenState extends State<LoginSignUpScreen> {
  bool showLoginScreen = true;
  final _formKey = GlobalKey<FormState>();

  // Controllers for all fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dharamshalaNameController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? selectedRole;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    mobileController.dispose();
    dharamshalaNameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void toggleScreen() {
    setState(() {
      showLoginScreen = !showLoginScreen;
      selectedRole = null;
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      usernameController.clear();
      mobileController.clear();
      dharamshalaNameController.clear();
      addressController.clear();
    });
  }

  Widget buildOwnerFields() {
    return Column(
      children: [
        TextFormField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: 'Name',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter username' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: mobileController,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter mobile number' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: dharamshalaNameController,
          decoration: InputDecoration(
            labelText: 'Dharamshala Name',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.business_outlined),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter dharamshala name' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: 'Address',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter address' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          obscureText: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter password';
            if (value!.length < 6)
              return 'Password must be at least 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          obscureText: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please confirm password';
            if (value != passwordController.text)
              return 'Passwords do not match';
            return null;
          },
        ),
      ],
    );
  }

  Widget buildUserFields() {
    return Column(
      children: [
        TextFormField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter username' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: mobileController,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter mobile number' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          obscureText: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter password';
            if (value!.length < 6)
              return 'Password must be at least 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            filled: true,
            fillColor: Color.fromARGB(231, 203, 202, 202),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          obscureText: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please confirm password';
            if (value != passwordController.text)
              return 'Passwords do not match';
            return null;
          },
        ),
      ],
    );
  }

 Future<void> _handleSubmit() async {
  if (!_formKey.currentState!.validate()) return;

  if (!showLoginScreen &&
      passwordController.text != confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Passwords do not match')),
    );
    return;
  }

  try {
    if (showLoginScreen) {
      // Login Logic
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;

      DocumentSnapshot<Map<String, dynamic>>? userDoc;

      // Check in 'owner' collection first
      userDoc = await FirebaseFirestore.instance
          .collection('owner')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        // Check in 'users' collection
        userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
      }

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final String role = userData['role'];

        // Navigate to the appropriate dashboard based on role
        if (context.mounted) {
          if (role == 'Owner') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  userRole: role,
                  userData: userData,
                ),
              ),
            );
          } else if (role == 'User') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => UserDashboard(
                ),
              ),
            );
          }
        }
      } else {
        // User not found in either collection
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found.')),
          );
        }
      }
    } else {
      // Registration Logic
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;

      final Map<String, dynamic> userData = {
        'email': emailController.text.trim(),
        'username': usernameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'role': selectedRole,
      };

      if (selectedRole == 'Owner') {
        userData['dharamshalaName'] = dharamshalaNameController.text.trim();
        userData['address'] = addressController.text.trim();

        // Save to 'owner' collection
        await FirebaseFirestore.instance.collection('owner').doc(userId).set(userData);
      } else if (selectedRole == 'User') {
        // Save to 'users' collection
        await FirebaseFirestore.instance.collection('users').doc(userId).set(userData);
      } else {
        throw Exception('Invalid role selected.');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        toggleScreen(); // Switch back to login screen
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                Text(
                  showLoginScreen ? 'Welcome Back' : 'Create Account',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                if (!showLoginScreen) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(231, 203, 202, 202),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'I am a',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      hint: const Text('Select your role'),
                      value: selectedRole,
                      items: ['User', 'Owner']
                          .map((role) =>
                              DropdownMenuItem(value: role, child: Text(role)))
                          .toList(),
                      onChanged: (value) => setState(() {
                        selectedRole = value;
                      }),
                      validator: (value) =>
                          value == null ? 'Please select a role' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedRole != null) ...[
                    if (selectedRole == 'Owner')
                      buildOwnerFields()
                    else
                      buildUserFields(),
                  ],
                ] else ...[
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      filled: true,
                      fillColor: Color.fromARGB(231, 203, 202, 202),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Please enter email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value!)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Color.fromARGB(231, 203, 202, 202),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Please enter password';
                      if (value!.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      showLoginScreen ? 'Login' : 'Sign Up',
                      style: const TextStyle(fontSize: 16,
                      color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showLoginScreen
                          ? "Don't have an account? "
                          : 'Already have an account? ',
                    ),
                    TextButton(
                      onPressed: toggleScreen,
                      child: Text(
                        showLoginScreen ? 'Sign Up' : 'Login',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, 
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
