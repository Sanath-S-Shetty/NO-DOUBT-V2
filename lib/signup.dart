import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:no_doubt/login.dart';

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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> createuser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
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
        child: SingleChildScrollView( // Prevents overflow on small screens
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                ),
                onPressed: () async {
                  await createuser();
                },
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
