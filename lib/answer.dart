import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:no_doubt/solution.dart';
import 'package:no_doubt/colors.dart';

class AnswerPage extends StatefulWidget {
  final String questionId;

  const AnswerPage({super.key, required this.questionId});

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  bool showSolutions = true;
  String selectedFilter = 'Stars';

  final List<String> filters = ['Stars', 'Newest', 'Oldest'];
  final TextEditingController _solutionController = TextEditingController();
  final TextEditingController _discussionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Details'),
        backgroundColor: color.text1,
      ),
      body: Column(
        children: [
          _buildQuestionHeader(),
          _buildToggleButtons(),
          Expanded(child: showSolutions ? _buildSolutionsView() : _buildDiscussionsView()),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Doubt').doc(widget.questionId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        var data = snapshot.data!.data() as Map<String, dynamic>;
        return Container(
          color: Colors.black87,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['qtitle'] ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
              const SizedBox(height: 8),
              Text(data['description'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      color: color.text1,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => setState(() => showSolutions = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: !showSolutions ? Colors.amber : Colors.white24,
            ),
            child: const Text('Discussions'),
          ),
          ElevatedButton(
            onPressed: () => setState(() => showSolutions = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: showSolutions ? Colors.amber : Colors.white24,
            ),
            child: const Text('Solutions'),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionsView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Sort by: ', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedFilter,
                dropdownColor: Colors.deepPurple,
                items: filters.map((value) {
                  return DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(color: Colors.amber)));
                }).toList(),
                onChanged: (value) => setState(() => selectedFilter = value!),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Doubt')
                .doc(widget.questionId)
                .collection('solutions')
                .orderBy(
                  selectedFilter == 'Stars'
                      ? 'stars'
                      : 'timestamp',
                  descending: selectedFilter != 'Oldest',
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SolutionDetailPage(
                            solutionId: docs[index].id,
                            solutionText: data['fullText'],
                            author: data['author'],
                            initialStars: data['stars'],
                            initiallyStarred: false,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.grey[900],
                      child: ListTile(
                        title: Text(data['title'] ?? '', style: const TextStyle(color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              data['stars']?.toString() ?? '0',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildDiscussionsView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Doubt')
          .doc(widget.questionId)
          .collection('discussions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return Card(
              color: Colors.grey[850],
              child: ListTile(
                title: Text('${data['author']}: ${data['text']}', style: const TextStyle(color: Colors.white)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[900],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: showSolutions ? _solutionController : _discussionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: showSolutions ? 'Add a solution...' : 'Add to discussion...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _postContent,
            style: ElevatedButton.styleFrom(backgroundColor: color.text1),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  Future<void> _postContent() async {
    final user = FirebaseAuth.instance.currentUser;
    final controller = showSolutions ? _solutionController : _discussionController;
    final text = controller.text.trim();
    if (text.isEmpty || user == null) return;

    final now = FieldValue.serverTimestamp();

    try {
      if (showSolutions) {
        await FirebaseFirestore.instance
            .collection('Doubt')
            .doc(widget.questionId)
            .collection('solutions')
            .add({
          'title': 'New Solution: ${text.substring(0, text.length > 30 ? 30 : text.length)}...',
          'fullText': text,
          'author': user.email ?? 'Anonymous',
          'stars': 0,
          'timestamp': now,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('Doubt')
            .doc(widget.questionId)
            .collection('discussions')
            .add({
          'text': text,
          'author': user.email ?? 'Anonymous',
          'timestamp': now,
        });
      }
      controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
