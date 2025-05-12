import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:no_doubt/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController customInterestController = TextEditingController();
  
  List<String> selectedInterests = [];
  List<String> predefinedInterests = ['Math', 'Science', 'Coding', 'Art', 'Music'];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    customInterestController.dispose();
    super.dispose();
  }

  Future<void> createUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    if (selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one interest")),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Get the user ID (UID)
      String uid = userCredential.user!.uid;

      // Save profile details to Firestore
      await FirebaseFirestore.instance.collection('profile').doc(uid).set({
        'userid': uid, // Storing the auto-generated UID
        'username': nameController.text.trim(),
        'interests': selectedInterests,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Image.asset('assets/nodoubt_logo.png', height: 100),
              SizedBox(height: 20),
              Text(
                'Create an account',
                style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              buildTextField(Icons.person, 'Name', nameController),
              SizedBox(height: 10),
              buildTextField(Icons.email, 'Email', emailController),
              SizedBox(height: 10),
              buildTextField(Icons.lock, 'Password', passwordController, obscureText: true),
              SizedBox(height: 10),
              buildTextField(Icons.lock, 'Confirm Password', confirmPasswordController, obscureText: true),
              SizedBox(height: 20),

              // Interests selection
              Text(
                'Select your interests',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 10),
              Column(
                children: predefinedInterests.map((interest) {
                  return CheckboxListTile(
                    title: Text(interest, style: TextStyle(color: Colors.white)),
                    value: selectedInterests.contains(interest),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value!) {
                          selectedInterests.add(interest);
                        } else {
                          selectedInterests.remove(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 10),

              // Custom interest input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customInterestController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter custom interest',
                        hintStyle: TextStyle(color: Colors.purpleAccent),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.amber),
                    onPressed: () {
                      String customInterest = customInterestController.text.trim();
                      if (customInterest.isNotEmpty && !selectedInterests.contains(customInterest)) {
                        setState(() {
                          selectedInterests.add(customInterest);
                        });
                        customInterestController.clear();
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                onPressed: createUser,
                child: Text(
                  'SIGN UP',
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "Already have an account? ", style: TextStyle(color: Colors.white)),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: Text(
                          "Log In",
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(IconData icon, String hint, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.purpleAccent),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.purpleAccent),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
        ),
      ),
    );
  }
}
