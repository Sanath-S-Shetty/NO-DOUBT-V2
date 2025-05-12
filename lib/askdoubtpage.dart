import 'package:flutter/material.dart';
import 'package:no_doubt/option.dart';
import 'package:no_doubt/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class askDoubtPage extends StatelessWidget {
  const askDoubtPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AskDoubtPage(),
    );
  }
}

class AskDoubtPage extends StatefulWidget {
  const AskDoubtPage({super.key});

  @override
  State<AskDoubtPage> createState() => _AskDoubtPageState();
}

class _AskDoubtPageState extends State<AskDoubtPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  Future<void> _submitDoubt() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final tagsRaw = _tagsController.text.trim();

    if (title.isEmpty || description.isEmpty || tagsRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields including at least one tag are required.')),
      );
      return;
    }

    final tags = tagsRaw
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one valid tag.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Doubt').add({
        'qtitle': title,
        'description': description,
        'tags': tags,
        'time': FieldValue.serverTimestamp(),
        'posted_by': user.uid,
        'star': {}, // Initialize empty map for starring
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doubt submitted: $title')),
      );

      _titleController.clear();
      _descriptionController.clear();
      _tagsController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit doubt: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask a Doubt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitDoubt,
              child: const Text('Submit Doubt'),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) return;
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Option()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const homePage()));
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
