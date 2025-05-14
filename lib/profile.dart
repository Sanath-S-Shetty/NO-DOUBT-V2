import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'option.dart';
import 'colors.dart';

// ----------------- PROFILE PAGE -----------------
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('profile').doc(uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: color.text1,
      ),
      backgroundColor: Colors.black,
     body: StreamBuilder<DocumentSnapshot>(
        stream: userDoc.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final username = data['username'] ?? 'No Name';
          final interests = List<String>.from(data['interests'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username,
                    style: const TextStyle(
                        color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('Interests',
                    style: TextStyle(
                        color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children:
                      interests.map((i) => Chip(label: Text(i), backgroundColor: Colors.amber)).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => const Option()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                  child: const Text('Back to Options', style: TextStyle(color: Colors.white)),
                ),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (_) => const LoginPage()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: color.text1),
                    child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ----------------- EDIT PROFILE PAGE -----------------
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _usernameController = TextEditingController();
  List<String> interests = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('profile').doc(uid).get();
    final data = doc.data()!;
    _usernameController.text = data['username'] ?? '';
    interests = List<String>.from(data['interests'] ?? []);
    setState(() {});
  }

  void _removeInterest(String interest) {
    setState(() => interests.remove(interest));
  }

  void _addInterest() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Important: allows keyboard-safe area resizing
    backgroundColor: Colors.grey[900],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final customController = TextEditingController();
      final List<String> presets = ['LAO', 'SE', 'TFCS', 'ADA', 'CRP', 'OS'];

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Interest', style: TextStyle(color: Colors.amber, fontSize: 18)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: presets.map((preset) {
                  return ActionChip(
                    label: Text(preset),
                    backgroundColor: Colors.amber,
                    onPressed: () {
                      if (!interests.contains(preset)) {
                        setState(() => interests.add(preset));
                      }
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const Divider(color: Colors.white24, height: 30),
              TextField(
                controller: customController,
                maxLength: 15,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Custom Interest',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder:
                      UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                onPressed: () {
                  final custom = customController.text.trim();
                  if (custom.isNotEmpty && !interests.contains(custom)) {
                    setState(() => interests.add(custom));
                  }
                  Navigator.pop(context);
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Future<void> _saveChanges() async {
    final updatedUsername = _usernameController.text.trim();
    await FirebaseFirestore.instance.collection('profile').doc(uid).update({
      'username': updatedUsername,
      'interests': interests,
    });
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.amber;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), backgroundColor: color.text1),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('Username', style: TextStyle(color: textColor, fontSize: 18)),
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Interests', style: TextStyle(color: textColor, fontSize: 18)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...interests.map((interest) => Chip(
                      label: Text(interest),
                      backgroundColor: Colors.amber,
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeInterest(interest),
                    )),
                GestureDetector(
                  onTap: _addInterest,
                  child: Chip(
                    label: const Text('+ Add'),
                    backgroundColor: Colors.purple,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(backgroundColor: color.text1),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
  
     ),
);
}
}
