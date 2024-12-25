import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../LoginPage.dart';

class UserRegister extends StatefulWidget {
  @override
  _UserRegisterState createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Controllers to collect form data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Google Sign-In instance
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  void _nextPage() {
    if (_currentIndex < 5) {
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

  Future<void> _registerUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        _nameController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty ||
        _conditionController.text.trim().isEmpty ||
        _heightController.text.trim().isEmpty ||
        _weightController.text.trim().isEmpty) {
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
      // Step 1: Store user details into Firestore
      print("Attempting to write to Firestore...");
      await FirebaseFirestore.instance.collection('User').add({
        'Name': _nameController.text.trim(),
        'Age': _ageController.text.trim(),
        'Condition': _conditionController.text.trim(),
        'Height': _heightController.text.trim(),
        'Weight': _weightController.text.trim(),
        'Email': email,
      });

      print("Data successfully written to Firestore.");

      // Step 2: Register the user with Firebase Authentication (Email and Password)

      // Step 3: Navigate to the LoginPage after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

    } catch (e) {
      // Handle errors (e.g., email already in use, weak password)
      print("Error: $e");
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
      await FirebaseFirestore.instance.collection('U').add({
        'Name': _nameController.text.trim(),
        'Age': _ageController.text.trim(),
        'Condition': _conditionController.text.trim(),
        'Height': _heightController.text.trim(),
        'Weight': _weightController.text.trim(),
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
      resizeToAvoidBottomInset: false, // Prevents the card from moving when keyboard appears
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.shade700, // Darker blue
              Colors.blueAccent.shade200, // Lighter blue
              Colors.blueAccent.shade100, // Even lighter blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: [
                  _buildCard(
                    title: "User Name",
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(hintText: "Enter your name"),
                    ),
                  ),
                  _buildCard(
                    title: "Age",
                    child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: "Enter your age"),
                    ),
                  ),
                  _buildCard(
                    title: "Condition",
                    child: TextField(
                      controller: _conditionController,
                      decoration: InputDecoration(hintText: "Enter your condition"),
                    ),
                  ),
                  _buildCard(
                    title: "Height",
                    child: TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: "Enter your height (cm)"),
                    ),
                  ),
                  _buildCard(
                    title: "Weight",
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: "Enter your weight (kg)"),
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
                          controller: _passwordController,
                          decoration: InputDecoration(hintText: "Password"),
                          obscureText: true,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(icon: Icon(Icons.facebook), onPressed: () {}),
                            IconButton(icon: Icon(Icons.g_mobiledata), onPressed: _signInWithGoogle),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _registerUser,
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
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 200, 20, 200),
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
                if (_currentIndex < 5)
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text("Next"),
                  ),
                if (_currentIndex > 0 && _currentIndex < 5)
                  TextButton(
                    onPressed: _prevPage,
                    child: Text("Back"),
                  ),
                if (_currentIndex == 5)
                  TextButton(
                    onPressed: _prevPage,
                    child: Text("Back to Personal Info"),
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
