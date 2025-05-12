import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:no_doubt/askdoubtpage.dart';
import 'package:no_doubt/option.dart';
import 'package:no_doubt/profile.dart';
import 'package:no_doubt/answer.dart';

class homePage extends StatelessWidget {
  const homePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const Option()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('No Doubt', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('All Doubts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(child: _buildDoubtList()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Option()));
          }
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const homePage()));
          }
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AskDoubtPage()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.question_answer), label: 'Solve Doubt'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Ask Doubt'),
        ],
      ),
    );
  }

  Widget _buildDoubtList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Doubt').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Text('No doubts found.', style: TextStyle(color: Colors.grey));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doubt = docs[index];
            return DoubtCard(
              title: doubt['qtitle'],
              description: doubt['description'],
              author: doubt['posted_by'],
             stars: (doubt['star'] is List) 
    ? (doubt['star'] as List).length 
    : (doubt['star'] is Map) 
        ? (doubt['star'] as Map).keys.length  // Or .values.length, depending on what you want to count
        : 0,  // Default to 0 if neither a List nor a Map


              questionId: doubt.id,
            );
          },
        );
      },
    );
  }
}

class DoubtCard extends StatelessWidget {
  final String title;
  final String description;
  final String author;
  final int stars;
  final String questionId;

  const DoubtCard({
    super.key,
    required this.title,
    required this.description,
    required this.author,
    required this.stars,
    required this.questionId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnswerPage(questionId: questionId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
      ),
    );
  }
}
