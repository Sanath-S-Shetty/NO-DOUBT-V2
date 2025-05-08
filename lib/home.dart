import 'package:flutter/material.dart';
import 'package:no_doubt/askdoubtpage.dart';
import 'package:no_doubt/option.dart';
import 'package:no_doubt/login.dart';
import 'package:firebase_auth/firebase_auth.dart';



class homePage extends StatelessWidget {
  const homePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'HQ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),

            child: GestureDetector(
      onTap: () {
       
        FirebaseAuth.instance.signOut();
         Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
      child: const Icon(Icons.person_outline, color: Colors.black),
    ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No Doubt',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            DoubtCard(
              title: 'What is a recursion?',
              description:
                  'Can someone explain the concept of recursion to me?',
              author: '2.4 plistrar',
              stars: 15,
            ),
            const SizedBox(height: 16),
            DoubtCard(
              title: 'Tips for time management?',
              description:
                  "I'm struggling to manage my time effectively, any advice?",
              author: '22 stars',
              stars: 8,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const askDoubtPage()),
            );
          }
           if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const option()),
            );
          }
           if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const homePage()),
            );
          }

        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.question_answer), label: 'Solve Doubts'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Ask Doubt'),
        ],
      ),
    );
  }
}

class DoubtCard extends StatelessWidget {
  final String title;
  final String description;
  final String author;
  final int stars;

  const DoubtCard({
    super.key,
    required this.title,
    required this.description,
    required this.author,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(author, style: TextStyle(color: Colors.grey[700])),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text('$stars'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
