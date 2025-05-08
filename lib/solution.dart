import 'package:flutter/material.dart';

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

  // Replace with Firebase logic later
  final List<Map<String, String>> comments = [
    {'user': 'Alice', 'text': 'Very helpful solution!'},
    {'user': 'Bob', 'text': 'Thanks, recursion finally clicked.'},
  ];

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

    // TODO: Update Firebase
  }

  void addComment() {
    final newComment = _commentController.text.trim();
    if (newComment.isNotEmpty) {
      setState(() {
        comments.add({'user': 'CurrentUser', 'text': newComment}); // Replace "CurrentUser" with actual logged-in user's name
        _commentController.clear();
      });

      // TODO: Save to Firebase
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

                    // Comments list
                    ...comments.map((comment) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.white),
                            children: [
                              TextSpan(
                                text: '${comment['user']}: ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                              ),
                              TextSpan(text: comment['text']),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

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
