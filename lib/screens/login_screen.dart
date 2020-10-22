import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailing_app/components/already_have_an_account_check.dart';
import 'package:mailing_app/components/rounded_button.dart';
import 'package:mailing_app/components/rounded_input_field.dart';
import 'package:mailing_app/components/rounded_password_field.dart';
import 'package:mailing_app/screens/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  bool showSpinner= false;

  signIn() async{
    setState(() {
      showSpinner=true;
    });
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: usernameController.text + "@vmail.com",
          password: passwordController.text);

      Navigator.pop(context);

      setState(() {
        showSpinner=false;
      });
    }catch (e) {
      if (e.code == 'user-not-found') {
        SnackBar snackbar = SnackBar(content: Text('No user found for that email.'));
        scaffoldKey.currentState.showSnackBar(snackbar);
        setState(() {
          showSpinner=false;
        });
      } else if (e.code == 'wrong-password') {
        SnackBar snackbar = SnackBar(content: Text('Incorrect password'));
        scaffoldKey.currentState.showSnackBar(snackbar);
        setState(() {
          showSpinner=false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          width: double.infinity,
          height: size.height,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  "assets/main_top.png",
                  width: size.width * 0.35,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  "assets/login_bottom.png",
                  width: size.width * 0.4,
                ),
              ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "LOGIN",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Image.asset(
                    "assets/login.png",
                    height: size.height * 0.35,
                  ),
                  SizedBox(height: size.height * 0.03),
                  RoundedInputField(
                    controller: usernameController,
                    hintText: "Your Username",
                    onChanged: (value) {},
                  ),
                  RoundedPasswordField(
                    hintText: "Password",
                    controller: passwordController,
                    onChanged: (value) {},
                  ),
                  RoundedButton(
                    text: "LOGIN",
                    press: () {
                      if(usernameController.text.isEmpty){
                        SnackBar snackbar = SnackBar(content: Text("The username cannot be null"));
                        scaffoldKey.currentState.showSnackBar(snackbar);
                      }else if(passwordController.text.isEmpty){
                        SnackBar snackbar = SnackBar(content: Text("The password cannot be null"));
                        scaffoldKey.currentState.showSnackBar(snackbar);
                      }else{
                        signIn();
                      }
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                  AlreadyHaveAnAccountCheck(
                    press: () {
                      Navigator.pushReplacement(
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
        ),
      )
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Center(
//         child: Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           child: Card(
//             elevation: 10,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text("Voogle", style: myStyle(25, Colors.purpleAccent)),
//                 SizedBox(height: 5.0),
//                 Text("Login", style: myStyle(18, Colors.black)),
//                 SizedBox(height: 10.0),
//                 Text("Continue to Voogle", style: myStyle(18, Colors.black)),
//                 SizedBox(height: 20),
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   margin: EdgeInsets.only(left: 20, right: 20),
//                   child: TextField(
//                     controller: usernameController,
//                     decoration: InputDecoration(
//                       filled: true,
//                       hintText: "UserName",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15.0),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 15.0),
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   margin: EdgeInsets.only(left: 20, right: 20),
//                   child: TextField(
//                     controller: passwordController,
//                     decoration: InputDecoration(
//                       filled: true,
//                       hintText: "Password",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15.0),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 15.0),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     RaisedButton(
//                       onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen())),
//                       color: Colors.lightBlue[200],
//                       child: Text("Create Account", style: myStyle(20),),
//                     ),
//                     RaisedButton(
//                       onPressed: () {
//                         try{
//                           FirebaseAuth.instance.signInWithEmailAndPassword(
//                               email: usernameController.text + "@vmail.com",
//                               password: passwordController.text);
//                         }catch(e){
//                           SnackBar snackbar = SnackBar(content: Text(e.toString()));
//                           Scaffold.of(context).showSnackBar(snackbar);
//                         }
//
//                       },
//                       color: Colors.lightBlue[200],
//                       child: Text("Login", style: myStyle(20),),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

