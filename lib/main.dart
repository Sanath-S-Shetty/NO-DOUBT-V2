import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:no_doubt/firebase_options.dart';
import 'package:no_doubt/login.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:no_doubt/option.dart';

// import 'package:no_doubt/home.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async in main()
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // 

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: const LoginPage(),
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context,snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if(snapshot.data !=null){
          return const option();
        }
        return const LoginPage();
      }
    ));
  }
}

