import 'package:flutter/material.dart';
import 'package:no_doubt/solution.dart'; // Make sure this import is correct

class AnswerPage extends StatefulWidget {
  final String questionId;

  const AnswerPage({super.key, required this.questionId});

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  bool showSolutions = false;
  String selectedFilter = 'Stars';

  final List<String> filters = ['Stars', 'Newest', 'Oldest'];

  final TextEditingController _solutionController = TextEditingController();
  final TextEditingController _discussionController = TextEditingController();

  List<Map<String, dynamic>> solutions = [];
  List<String> discussions = [];

  @override
  void initState() {
    super.initState();
    // Initialize with dummy data
    solutions = List.generate(5, (index) {
      return {
        'title': 'Solution #$index: Use recursion when the problem breaks into subproblems.',
        'fullText':
        'Solution #$index (Full): Recursion is useful for divide-and-conquer problems. It simplifies code for problems like tree traversal, backtracking, etc. Example: In-order traversal is simpler with recursion.',
        'author': 'User$index',
        'stars': 5 + index,
        'starredByUser': false,
      };
    });

    discussions = List.generate(5, (index) => 'User $index: I think it helps with divide-and-conquer.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Top part - Question display
          Container(
            color: Colors.black87,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Why does recursion work better for some problems?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'I ve seen recursion used in tree traversals and backtracking, but I dont get why its preferred. Can someone explain?',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Toggle buttons
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showSolutions = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !showSolutions ? Colors.amber : Colors.white24,
                  ),
                  child: const Text('Discussions'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showSolutions = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showSolutions ? Colors.amber : Colors.white24,
                  ),
                  child: const Text('Solutions'),
                ),
              ],
            ),
          ),

          // Content section - scrollable
          Expanded(
            child: Container(
              color: Colors.black,
              child: showSolutions ? _buildSolutionsView() : _buildDiscussionsView(),
            ),
          ),

          // Input section
          Container(
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
                  onPressed: () {
                    final text = (showSolutions ? _solutionController : _discussionController).text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        if (showSolutions) {
                          solutions.insert(0, {
                            'title': 'New Solution: ${text.substring(0, text.length > 30 ? 30 : text.length)}...',
                            'fullText': text,
                            'author': 'CurrentUser',
                            'stars': 0,
                            'starredByUser': false,
                          });
                          _solutionController.clear();
                        } else {
                          discussions.insert(0, 'CurrentUser: $text');
                          _discussionController.clear();
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  child: const Text('Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionsView() {
    return Column(
      children: [
        // Filter row
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Sort by: ', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: selectedFilter,
                dropdownColor: Colors.deepPurple,
                items: filters.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: Colors.amber)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                    // TODO: Implement sorting logic
                  });
                },
              ),
            ],
          ),
        ),

        // Solutions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: solutions.length,
            itemBuilder: (context, index) {
              final solution = solutions[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SolutionDetailPage(
                        solutionId: '$index',
                        solutionText: solution['fullText'],
                        author: solution['author'],
                        initialStars: solution['stars'],
                        initiallyStarred: solution['starredByUser'],
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    title: Text(
                      solution['title'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: const Icon(Icons.star, color: Colors.amber),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscussionsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: discussions.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.grey[850],
          child: ListTile(
            title: Text(
              discussions[index],
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
