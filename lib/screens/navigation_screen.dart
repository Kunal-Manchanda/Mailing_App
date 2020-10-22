import 'package:flutter/material.dart';
import 'package:mailing_app/components/rounded_button.dart';
import 'package:mailing_app/screens/sign_up_screen.dart';
import '../utils/constants.dart';
import 'mails_screen.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool isSigned = false;

  @override
  void initState() {
    super.initState();
    auth.FirebaseAuth.instance
        .authStateChanges()
        .listen((auth.User user) {
      if (user != null) {
        setState(() {
          isSigned = true;
          print(user.uid);
        });
      } else {
        setState(() {
          isSigned = false;
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    print(isSigned);
    return Scaffold(
      body: isSigned ? MailsScreen() : WelcomeScreen(),
    );
  }
}


class WelcomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                "assets/main_top.png",
                width: MediaQuery.of(context).size.width * 0.3,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Image.asset(
                "assets/main_bottom.png",
                width: MediaQuery.of(context).size.width * 0.2,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "WELCOME TO VOOGLE",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Image.asset(
                    "assets/chat.png",
                    height: MediaQuery.of(context).size.height * 0.45,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  RoundedButton(
                    text: "LOGIN",
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginScreen();
                          },
                        ),
                      );
                    },
                  ),
                  RoundedButton(
                    text: "SIGN UP",
                    color: kPrimaryLightColor,
                    textColor: Colors.black,
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SignUpScreen();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
