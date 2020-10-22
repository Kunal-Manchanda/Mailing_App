import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailing_app/components/already_have_an_account_check.dart';
import 'package:mailing_app/components/rounded_button.dart';
import 'package:mailing_app/components/rounded_input_field.dart';
import 'package:mailing_app/components/rounded_password_field.dart';
import 'file:///D:/AndroidProjects/mailing_app/lib/utils/constants.dart';
import 'file:///D:/AndroidProjects/mailing_app/lib/utils/variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailing_app/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  File imagePath;
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  bool showSpinner= false;


  pickImage(ImageSource imageSource) async{
    final image = await ImagePicker().getImage(
        source: imageSource,
      maxHeight: 670,
      maxWidth: 800
    );
    setState(() {
      imagePath = File(image.path);
    });
    Navigator.pop(context);
  }

  pickImageDialog(){
    return showDialog(
        context: context,
      builder: (context){
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                onPressed: () => pickImage(ImageSource.gallery),
                child: Text("From Galley", style: myStyle(20, kPrimaryColor),),
              ),
              SimpleDialogOption(
                onPressed: () => pickImage(ImageSource.camera),
                child: Text("From Camera", style: myStyle(20, kPrimaryColor),),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: myStyle(20, kPrimaryColor),),
              ),
            ],
          );
      }
    );
  }

  registerUser() async{
    setState(() {
      showSpinner=true;
    });
    try{
      String downloadPic = imagePath == null ?
      'https://www.pngkit.com/png/full/72-729613_icons-logos-emojis-user-icon-png-transparent.png'
      : await uploadImage();
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usernameController.text + "@vmail.com",
          password: passwordController.text).then((signedUser) {
            CurrentUser().storeUser(
                email: usernameController.text + "@vmail.com",
              username: usernameController.text,
              password: passwordController.text,
              profilePic: downloadPic
            );
      });
      Navigator.pop(context);
      setState(() {
        showSpinner=false;
      });
    }catch(e){
      if (e.code == 'weak-password') {
        SnackBar snackbar = SnackBar(content: Text("The password provided is too weak."));
        scaffoldKey.currentState.showSnackBar(snackbar);
        setState(() {
          showSpinner=false;
        });
      } else if (e.code == 'email-already-in-use') {
        SnackBar snackbar = SnackBar(content: Text("The account already exists for this username."));
        scaffoldKey.currentState.showSnackBar(snackbar);
        setState(() {
          showSpinner=false;
        });
      }
    }
  }

  uploadImage() async{
    //store image
    StorageUploadTask storage = profilePics.child(usernameController.text).putFile(imagePath);

    //complete image
    StorageTaskSnapshot storageTaskSnapshot = await storage.onComplete;

    //download pic
    String downloadPic = await storageTaskSnapshot.ref.getDownloadURL();

    return downloadPic;
  }

    @override
    Widget build(BuildContext context) {
      Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          height: size.height,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  "assets/signup_top.png",
                  width: size.width * 0.35,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Image.asset(
                  "assets/main_bottom.png",
                  width: size.width * 0.25,
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "SIGNUP",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Image.asset(
                      "assets/signup.png",
                      height: size.height * 0.35,
                    ),
                    RoundedInputField(
                      controller: usernameController,
                      hintText: "Your Username",
                      onChanged: (value) {},
                    ),
                    RoundedPasswordField(
                      controller: passwordController,
                      hintText: "Password",
                      onChanged: (value) {},
                    ),
                    RoundedPasswordField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      onChanged: (value) {},
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () => pickImageDialog(),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Center(
                              child: imagePath == null ? Icon(Icons.add, color: Colors.white,) : CircleAvatar(backgroundColor: Colors.white, radius: 60 ,backgroundImage: FileImage(imagePath)),
                            ),
                          ),
                        ),
                        InkWell(
                            onTap: () => pickImageDialog(),
                            child: Text("Choose Profile Image", style: TextStyle(color: kPrimaryColor, fontSize: 18))
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.03),
                    RoundedButton(
                      text: "SIGNUP",
                      press: () {
                        if(usernameController.text.isEmpty){
                          SnackBar snackbar = SnackBar(content: Text("The username cannot be null"));
                          scaffoldKey.currentState.showSnackBar(snackbar);
                        }else if(passwordController.text != confirmPasswordController.text){
                          SnackBar snackbar = SnackBar(content: Text("Both passwords should match"));
                          scaffoldKey.currentState.showSnackBar(snackbar);
                        }else if(passwordController.text.isEmpty || confirmPasswordController.text.isEmpty){
                          SnackBar snackbar = SnackBar(content: Text("The password cannot be null"));
                          scaffoldKey.currentState.showSnackBar(snackbar);
                        }else if(passwordController.text.length<6){
                          SnackBar snackbar = SnackBar(content: Text("The password should atleast be of 6 characters"));
                          scaffoldKey.currentState.showSnackBar(snackbar);
                        }else{
                          registerUser();
                        }
                    },
                    ),
                    SizedBox(height: size.height * 0.03),
                    AlreadyHaveAnAccountCheck(
                      login: false,
                      press: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LoginScreen();
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
      ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     key: scaffoldKey,
  //     body: SingleChildScrollView(
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
  //                 Text("Create Account", style: myStyle(18, Colors.black)),
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
  //                 Container(
  //                   width: MediaQuery.of(context).size.width,
  //                   margin: EdgeInsets.only(left: 20, right: 20),
  //                   child: TextField(
  //                     decoration: InputDecoration(
  //                       filled: true,
  //                       hintText: "Confirm Password",
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(15.0),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(height: 10),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     InkWell(
  //                       onTap: () => pickImageDialog(),
  //                       child: Container(
  //                         width: 64,
  //                         height: 64,
  //                         decoration: BoxDecoration(
  //                           color: Colors.lightBlue[400],
  //                           borderRadius: BorderRadius.circular(20.0),
  //                         ),
  //                         child: Center(
  //                           child: imagePath == null ? Icon(Icons.add, color: Colors.white) : Image(image: FileImage(imagePath)),
  //                         ),
  //                       ),
  //                     ),
  //                     InkWell(
  //                       onTap: () => pickImageDialog(),
  //                         child: Text("Choose Profile Image", style: myStyle(20))
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 15.0),
  //                 RaisedButton(
  //                   onPressed: () => registerUser(),
  //                   color: Colors.lightBlue[200],
  //                   child: Text("Register", style: myStyle(20),),
  //                 )
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
