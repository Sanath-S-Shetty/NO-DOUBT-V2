import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:no_doubt/colors.dart';

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
  final _commentController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    stars = widget.initialStars;
    isStarred = widget.initiallyStarred;
    fetchStarState();
  }

  Future<void> fetchStarState() async {
    final doc = await FirebaseFirestore.instance
        .collection('solutions')
        .doc(widget.solutionId)
        .get();

    final starList = doc.data()?['stars'];
    if (starList is List) {
      setState(() {
        stars = starList.length;
        isStarred = starList.contains(user?.uid);
      });
    }
  }

  Future<void> toggleStar() async {
    final docRef = FirebaseFirestore.instance
        .collection('solutions')
        .doc(widget.solutionId);
    final uid = user?.uid;
    if (uid == null) return;

    try {
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({'stars': [uid]}, SetOptions(merge: true));
        setState(() {
          stars = 1;
          isStarred = true;
        });
        return;
      }

      final data = doc.data();
      final starList = data?['stars'];

      if (starList is List) {
        if (starList.contains(uid)) {
          await docRef.update({'stars': FieldValue.arrayRemove([uid])});
          setState(() {
            stars -= 1;
            isStarred = false;
          });
        } else {
          await docRef.update({'stars': FieldValue.arrayUnion([uid])});
          setState(() {
            stars += 1;
            isStarred = true;
          });
        }
      } else {
        await docRef.set({'stars': [uid]}, SetOptions(merge: true));
        setState(() {
          stars = 1;
          isStarred = true;
        });
      }
    } catch (e) {
      print('Error toggling star: $e');
    }
  }

  Future<void> addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || user == null) return;

    final profileQuery = await FirebaseFirestore.instance
        .collection('profile')
        .where('userid', isEqualTo: user!.uid)
        .get();

    final username = profileQuery.docs.isNotEmpty
        ? profileQuery.docs.first['username']
        : 'Anonymous';

    await FirebaseFirestore.instance
        .collection('solutions')
        .doc(widget.solutionId)
        .collection('comments')
        .add({
      'user': username,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Solution'),
        backgroundColor: color.text1,
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
                    Text(widget.solutionText,
                        style: const TextStyle(fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isStarred ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: toggleStar,
                        ),
                        Text('$stars Stars',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('— ${widget.author}',
                        style: const TextStyle(color: Colors.grey)),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Comments',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('solutions')
                          .doc(widget.solutionId)
                          .collection('comments')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No comments yet.',
                              style: TextStyle(color: Colors.white54));
                        }

                        final comments = snapshot.data!.docs;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: comments.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final username = data['user'] ?? 'Anonymous';
                            final text = data['text'] ?? '';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.white),
                                  children: [
                                    TextSpan(
                                      text: '$username: ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber),
                                    ),
                                    TextSpan(text: text),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.text1,
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
