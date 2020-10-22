import 'package:flutter/material.dart';
import 'file:///D:/AndroidProjects/mailing_app/lib/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mailing_app/screens/navigation_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Mailing App",
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: NavigationScreen(),
    );
  }
}


