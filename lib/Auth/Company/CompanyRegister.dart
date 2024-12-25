import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../LoginPage.dart';

class CompanyRegister extends StatefulWidget {
  @override
  _CompanyRegisterState createState() => _CompanyRegisterState();
}

class _CompanyRegisterState extends State<CompanyRegister> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _companyNameController = TextEditingController();
  final _medicalSectorController = TextEditingController();
  final _medicinesProducedController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _nextPage() {
    if (_currentIndex < 3) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _registerCompany() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        _companyNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid email address.")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password must be at least 6 characters long.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print("Attempting to write to Firestore...");
      await FirebaseFirestore.instance
          .collection('Company')
          .add({
        'Name': _companyNameController.text.trim(),
        'Sector': _medicalSectorController.text.trim(),
        'MedicinesProduced': _medicinesProducedController.text.trim(),
        'Phone': _phoneController.text.trim(),
        'Email': email,
      });
      print("Data successfully written to Firestore.");
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Error writing to Firestore: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });


      // Step 1: Initiate Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user cancels the sign-in process
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        throw Exception("Google Sign-In canceled by user.");
      }

      // Step 2: Obtain Google authentication details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
    try{
      // Step 4: Store company details into Firestore
      print("Attempting to write to Firestore...");
      await FirebaseFirestore.instance.collection('Company').add({
        'Name': _companyNameController.text.trim(),
        'Sector': _medicalSectorController.text.trim(),
        'MedicinesProduced': _medicinesProducedController.text.trim(),
        'Phone': _phoneController.text.trim(),
        'Email': googleUser.email,
      });

      print("Data successfully written to Firestore.");

      // Step 5: Navigate to the LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 3: Authenticate the user with Firebase using the credentials
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _buildBackground(),
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  children: [
                    _buildCard(
                      title: "Company Name",
                      child: TextField(
                        controller: _companyNameController,
                        decoration:
                            InputDecoration(hintText: "Enter company name"),
                      ),
                    ),
                    _buildCard(
                      title: "Medical Sector",
                      child: DropdownButtonFormField<String>(
                        items: ["Pharmaceutical", "Biotech", "Ayurvedic"]
                            .map((sector) {
                          return DropdownMenuItem(
                              value: sector, child: Text(sector));
                        }).toList(),
                        onChanged: (value) {
                          _medicalSectorController.text = value ?? "";
                        },
                        decoration: InputDecoration(hintText: "Select sector"),
                      ),
                    ),
                    _buildCard(
                      title: "Medicines Produced",
                      child: DropdownButtonFormField<String>(
                        items: ["Painkillers", "Antibiotics", "Vitamins"]
                            .map((med) {
                          return DropdownMenuItem(value: med, child: Text(med));
                        }).toList(),
                        onChanged: (value) {
                          _medicinesProducedController.text = value ?? "";
                        },
                        decoration:
                            InputDecoration(hintText: "Select medicines"),
                      ),
                    ),
                    _buildCard(
                      title: "Register",
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(hintText: "Email"),
                          ),
                          TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(hintText: "Phone"),
                          ),
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: "Password",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.facebook), onPressed: () {}),
                              IconButton(
                                  icon: Icon(Icons.g_mobiledata),
                                  onPressed: _signInWithGoogle),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _registerCompany,
                            child: Text("Register"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildAlreadyHaveAccount(),
            ],
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent.shade700,
            Colors.blueAccent.shade200,
            Colors.blueAccent.shade100,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 180, 20, 180),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                child,
                SizedBox(height: 10),
                if (_currentIndex < 3)
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text("Next"),
                  ),
                if (_currentIndex > 0)
                  TextButton(
                    onPressed: _prevPage,
                    child: Text("Back"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyHaveAccount() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Already have an account?",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                "Login",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
