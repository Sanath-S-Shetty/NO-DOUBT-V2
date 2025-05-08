import 'package:flutter/material.dart';
import 'package:no_doubt/option.dart';
import 'package:no_doubt/home.dart';



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
              onPressed: () {
                // Handle submission logic here
                final title = _titleController.text;
                final description = _descriptionController.text;
                final tags = _tagsController.text;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Doubt submitted: $title')),
                );
              },
              child: const Text('Submit Doubt'),
            )
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
