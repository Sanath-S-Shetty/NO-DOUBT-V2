// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:no_doubt/firebase_options.dart';
// import 'package:no_doubt/login.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'package:no_doubt/option.dart';

// // import 'package:no_doubt/home.dart';



// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // Required for async in main()
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   ); // 

//   runApp(const MyApp());
// }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp( 
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       // home: const LoginPage(),
//       home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context,snapshot){

//         if(snapshot.connectionState == ConnectionState.waiting){
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         if(snapshot.data !=null){
//           return const Option();
//         }
//         return const LoginPage();
//       }
//     ));
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
 import 'package:flutter/material.dart';
 import 'package:no_doubt/firebase_options.dart';
import 'package:no_doubt/login.dart';
import 'package:firebase_core/firebase_core.dart';
 import 'package:no_doubt/option.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'No-doubt',
      theme: ThemeData(
        colorScheme:ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthWrapper(),  // Using the AuthWrapper for auth state handling
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const Option(),  // Add HomeScreen route if needed
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens for authentication state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const Option();  // Redirect to HomeScreen if logged in
          } else {
            return const LoginPage();  // Show LoginScreen if user is not logged in
          }
        } else {
          return const Center(child: CircularProgressIndicator());  // Loading screen while checking auth status
        }
      },
    );
  }
}