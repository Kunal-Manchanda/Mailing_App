import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailing_app/utils/variables.dart';
import '../utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewMailScreen extends StatefulWidget {

  final String id;
  final String sender;
  final Timestamp time;
  final String attachment;
  final String mail;
  final String subject;
  final String profilePic;
  final String username;

  ViewMailScreen({this.id, this.sender, this.time, this.attachment, this.mail, this.subject, this.profilePic, this.username});

  @override
  _ViewMailScreenState createState() => _ViewMailScreenState();
}

class _ViewMailScreenState extends State<ViewMailScreen> {

  @override
  void initState() {
    super.initState();
    markAsRead();
  }

  deleteMail(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            content: Text("Do you really want to delete the mail", style: myStyle(20, kPrimaryColor)),
            actions: [
              FlatButton(
                color: Colors.red,
                onPressed: () => deleteDocument(),
                child: Text(
                  "Yes",
                  style: myStyle(20, Colors.white),
                ),
              ),
              FlatButton(
                color: Colors.lightBlue,
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "No",
                  style: myStyle(20, Colors.white),
                ),
              ),
            ],
          );
        }
    );
  }

  deleteDocument() async{
    //pops out the dialog
    Navigator.pop(context);

    var firebaseUser = await FirebaseAuth.instance.currentUser;

    userCollection.doc(firebaseUser.email).collection('inbox').doc(widget.id).delete();

    //pops out the current mail page
    Navigator.pop(context);
  }

  markAsRead() async{
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    userCollection.doc(firebaseUser.email).collection('inbox').doc(widget.id).update({'hasRead': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, size: 32, color: Colors.white),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Icon(Icons.reply, size: 32, color: Colors.white),
            ),
          ),
          InkWell(
            onTap: () => deleteMail(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              child: Icon(Icons.delete, size: 32, color: Colors.red[500]),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subject, style: myStyle(35),),
            SizedBox(height: 20.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(widget.profilePic),
                    ),
                    SizedBox(width: 10.0),
                    Text(widget.username, style: myStyle(20)),
                  ],
                ),
                InkWell(
                  onTap: () {},
                  child: Icon(Icons.reply, size: 32, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 30.0,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.mail, style: myStyle(20, Colors.black, FontWeight.w400),),
            ),
            SizedBox(height: 40.0),
            Text("Attachments", style: myStyle(20, kPrimaryColor),),
            SizedBox(height: 20,),
            widget.attachment == "No attachment" ? Container() : Image(
                width: 200,
                height: 200,
                // fit: BoxFit.cover,
                image: NetworkImage(widget.attachment),
            ),
          ],
        ),
      ),
    );
  }
}
