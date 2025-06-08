import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:no_doubt/askdoubtpage.dart';
import 'package:no_doubt/option.dart';
import 'package:no_doubt/colors.dart';
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

enum SortOption { stars, newest, oldest }

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<String> userInterests = [];
  SortOption sortOption = SortOption.newest;

  @override
  void initState() {
    super.initState();
    fetchUserInterests();
  }

  Future<void> fetchUserInterests() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('profile').doc(user!.uid).get();
      final data = doc.data();
      if (data != null && data['interests'] != null) {
        setState(() {
          userInterests = List<String>.from(data['interests']);
        });
      }
    }
  }

  int getStarCount(QueryDocumentSnapshot doc) {
    final star = doc['star'];
    if (star is List) return star.length;
    if (star is Map) return star.length;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      
      backgroundColor: color.primary,
      appBar: AppBar(
        backgroundColor: color.text1,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            '',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: const Icon(Icons.person_outline, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userInterests.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('No Doubt', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color.box)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Interests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: color.box)),
                      DropdownButton<SortOption>(
                        value: sortOption,
                        dropdownColor: color.primary,
                        items: const [
                          DropdownMenuItem(value: SortOption.newest, child: Text("Newest", style: TextStyle(color:color.box))),
                          DropdownMenuItem(value: SortOption.oldest, child: Text("Oldest",style: TextStyle(color:color.box))),
                          DropdownMenuItem(value: SortOption.stars, child: Text("Stars",style: TextStyle(color: color.box))),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              sortOption = value;
                            });
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildDoubtList(matching: true)),
                  const SizedBox(height: 16),
                  const Text('General Doubts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: color.box)),
                  const SizedBox(height: 8),
                  Expanded(child: _buildDoubtList(matching: false)),
                ],
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: color.text1,
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AskDoubtPage()));
          }
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Option()));
          }
          if (index == 1) {
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

  Widget _buildDoubtList({required bool matching}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Doubt').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

        final filteredDocs = docs.where((doc) {
          final tags = List<String>.from(doc['tags'] ?? []);
          final overlap = tags.toSet().intersection(userInterests.toSet());
          return matching ? overlap.isNotEmpty : overlap.isEmpty;
        }).toList();

        if (sortOption == SortOption.stars) {
          filteredDocs.sort((a, b) => getStarCount(b).compareTo(getStarCount(a)));
        } else if (sortOption == SortOption.newest) {
          filteredDocs.sort((a, b) => b['time'].compareTo(a['time']));
        } else if (sortOption == SortOption.oldest) {
          filteredDocs.sort((a, b) => a['time'].compareTo(b['time']));
        }

        if (filteredDocs.isEmpty) {
          return const Text('No doubts found.', style: TextStyle(color: Colors.grey));
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doubt = filteredDocs[index];
            final starField = doubt['star'];
            List<String> starList = [];
            if (starField is List) {
              starList = List<String>.from(starField);
            } else if (starField is Map) {
              starList = List<String>.from(starField.keys);
            }

            return DoubtCard(
              title: doubt['qtitle'],
              description: doubt['description'],
              author: doubt['posted_by'],
              labels: List<String>.from(doubt['tags'] ?? []),
              stars: starList.length,
              questionId: doubt.id,
              isStarred: user != null && starList.contains(user!.uid),
              onStarToggle: () async {
                final docRef = FirebaseFirestore.instance.collection('Doubt').doc(doubt.id);
                final newStars = Set<String>.from(starList);

                if (user != null) {
                  if (newStars.contains(user!.uid)) {
                    newStars.remove(user!.uid);
                  } else {
                    newStars.add(user!.uid);
                  }

                  await docRef.update({'star': newStars.toList()});
                }
              },
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
  final bool isStarred;
  final VoidCallback onStarToggle;
  final List<String> labels;

  const DoubtCard({
    super.key,
    required this.title,
    required this.description,
    required this.author,
    required this.stars,
    required this.questionId,
    required this.isStarred,
    required this.onStarToggle,
    required this.labels,
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
          color: Color(0xffFFFDD0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: labels.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(author, style: TextStyle(color: Colors.grey[700])),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onStarToggle,
                      child: Icon(
                        isStarred ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
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
