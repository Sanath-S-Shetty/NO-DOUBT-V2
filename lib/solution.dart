import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SolutionDetailPage extends StatefulWidget {
  final String solutionId;
  final String solutionText;
  final String author;
  final int initialStars;
  final bool initiallyStarred;

  const SolutionDetailPage({
    super.key,
    required this.solutionId,
    required this.solutionText,
    required this.author,
    required this.initialStars,
    required this.initiallyStarred,
  });

  @override
  State<SolutionDetailPage> createState() => _SolutionDetailPageState();
}

class _SolutionDetailPageState extends State<SolutionDetailPage> {
  late int stars;
  late bool isStarred;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    stars = widget.initialStars;
    isStarred = widget.initiallyStarred;
  }

  void toggleStar() {
    setState(() {
      isStarred = !isStarred;
      stars += isStarred ? 1 : -1;
    });

    // TODO: Update Firebase to reflect star change
    // FirebaseFirestore.instance
    //     .collection('solutions')
    //     .doc(widget.solutionId)
    //     .update({'stars': stars});
  }

  void addComment() async {
    final newComment = _commentController.text.trim();
    if (newComment.isNotEmpty) {
      
      final user = FirebaseAuth.instance.currentUser; // Replace with actual logged-in user's name
      try {
        await FirebaseFirestore.instance
            .collection('solutions') // Main solutions collection
            .doc(widget.solutionId) // Document for the specific solution
            .collection('comments') // Subcollection for comments
            .add({
          'user': user?.email ?? 'Anonymous',
          'text': newComment,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _commentController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Solution'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Solution text
                    Text(
                      widget.solutionText,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    // Star row
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isStarred ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: toggleStar,
                        ),
                        Text('$stars Stars', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('— ${widget.author}', style: const TextStyle(color: Colors.grey)),
                    const Divider(color: Colors.grey),

                    const SizedBox(height: 16),
                    const Text(
                      'Comments',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                    const SizedBox(height: 8),

                    // StreamBuilder for fetching comments
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('solutions') // Main solutions collection
                          .doc(widget.solutionId) // Document ID for the solution
                          .collection('comments') // Subcollection for comments
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, commentSnapshot) {
                        if (commentSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!commentSnapshot.hasData || commentSnapshot.data!.docs.isEmpty) {
                          return const Text('No comments yet.', style: TextStyle(color: Colors.white54));
                        }

                        final comments = commentSnapshot.data!.docs;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: comments.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.white),
                                  children: [
                                    TextSpan(
                                      text: '${data['user']}: ',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                                    ),
                                    TextSpan(text: data['text']),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Add comment input at bottom
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
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
                  onPressed: addComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
