import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailing_app/utils/variables.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ComposeMailScreen extends StatefulWidget {
  @override
  _ComposeMailScreenState createState() => _ComposeMailScreenState();
}

class _ComposeMailScreenState extends State<ComposeMailScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var imagePath;
  String userEmail;
  bool showSpinner= false;
  TextEditingController receiver = TextEditingController();
  TextEditingController subject = TextEditingController();
  TextEditingController mail = TextEditingController();


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

  String imageId = Uuid().v4();

  uploadImage() async{
    //store image
    StorageUploadTask storage = attachments.child(imageId).putFile(imagePath);

    //complete image
    StorageTaskSnapshot storageTaskSnapshot = await storage.onComplete;

    //download pic
    String downloadPic = await storageTaskSnapshot.ref.getDownloadURL();

    return downloadPic;
  }

  sendMail() async{

    DocumentSnapshot userDocument = await userCollection.doc(receiver.text).get();
    if(userDocument.exists){
      setState(() {
        showSpinner=true;
      });
      try{
        var firebaseUser = await FirebaseAuth.instance.currentUser;

        DocumentSnapshot userDocument = await userCollection.doc(firebaseUser.email).get();

        String attachment = imagePath == null ? 'No attachment' : await uploadImage();

        final id = userCollection.doc(receiver.text).collection('inbox').doc().id;

        userCollection.doc(receiver.text).collection('inbox').doc(id)
            .set({
          'sender': firebaseUser.email,
          'receiver': receiver.text,
          'subject': subject.text,
          'mail': mail.text,
          'hasRead': false,
          'stared': false,
          'attachment': attachment,
          'id': id,
          'time': DateTime.now(),
          'username': userDocument.data()['username'],
          'profilePic': userDocument.data()['profilePic']
        });
        Navigator.pop(context);

        setState(() {
          showSpinner=false;
        });

      }catch(e){
        print(e);
      }
    }else{
      SnackBar snackbar = SnackBar(content: Text("The recipient does not exits"));
      scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  getUserData() async{
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = firebaseUser.email;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }


  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if(receiver.text.isEmpty){
              SnackBar snackbar = SnackBar(content: Text("The recipient field cannot be empty"));
              scaffoldKey.currentState.showSnackBar(snackbar);
            }else if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(receiver.text)){
              SnackBar snackbar = SnackBar(content: Text("Invalid format"));
              scaffoldKey.currentState.showSnackBar(snackbar);
            }else if(mail.text.isEmpty){
              SnackBar snackbar = SnackBar(content: Text("The mail field cannot be empty"));
              scaffoldKey.currentState.showSnackBar(snackbar);
            }else{
              sendMail();
            }
            },
          backgroundColor: kPrimaryColor,
          child: Icon(Icons.send, color: kPrimaryLightColor,),
        ),
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          actions: [
            InkWell(
              onTap: () => pickImageDialog(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.attach_file,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            )
          ],
          title: Text(
            "Compose Mail",
            style: myStyle(20, Colors.white, FontWeight.w600),
          ),
          centerTitle: true,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: TextFormField(
                      enabled: false,
                      style: myStyle(20),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black),
                        hoverColor: Colors.red,
                        hintText: "From $userEmail",
                        labelStyle: myStyle(20),
                      ),
                    ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                child: TextFormField(
                  controller: receiver,
                  style: myStyle(20),
                  decoration: InputDecoration(
                    hintText: "To   (username@vmail.com)",
                    labelStyle: myStyle(20),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                child: TextFormField(
                  controller: subject,
                  style: myStyle(20),
                  decoration: InputDecoration(
                    hintText: "Subject",
                    labelStyle: myStyle(20),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: TextFormField(
                    controller: mail,
                    style: myStyle(20),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Mail",
                      border: InputBorder.none,
                      labelStyle: myStyle(20),
                    ),
                  ),
                ),
              ),
              imagePath == null
                  ? Container()
                  : MediaQuery.of(context).viewInsets.bottom > 0
                  ? Container() : Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Your attachment",
                      style: myStyle(20),
                    ),
                    Container(
                      child: Image(
                          width: 200,
                          height: 150,
                          image: FileImage(imagePath)
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
