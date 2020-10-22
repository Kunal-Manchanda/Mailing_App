import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailing_app/screens/compose_mail_screen.dart';
import 'package:mailing_app/screens/view_mail_screen.dart';
import 'package:mailing_app/utils/variables.dart';
import '../utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MailsScreen extends StatefulWidget {
  @override
  _MailsScreenState createState() => _MailsScreenState();
}

class _MailsScreenState extends State<MailsScreen> {

  String userMail;
  Stream myStream;
  Stream userProfileStream;

  @override
  void initState() {
    super.initState();
    getUserData();
    getStream();
  }

  getStream() async{
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    setState(() {
      myStream = userCollection
          .doc(firebaseUser.email)
          .collection('inbox')
          .snapshots();

      userProfileStream = userCollection.doc(firebaseUser.email).snapshots();
    });
  }

  getUserData() async{
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    setState(() {
      userMail = firebaseUser.email;
    });
  }

  starMail(String id) async{
    DocumentSnapshot document = await userCollection.doc(userMail).collection('inbox').doc(id).get();

    if(document.data()['stared'] == false){
      userCollection.doc(userMail)
          .collection('inbox')
          .doc(id)
          .update({'stared': true});
    }else{
      userCollection
          .doc(userMail)
          .collection('inbox')
          .doc(id)
          .update({'stared': false});
    }

  }

  searchMail(String str) async{
    setState(() {
      myStream = userCollection
          .doc(userMail)
          .collection('inbox')
          .where('subject', isGreaterThanOrEqualTo: str)
          .snapshots();
    });
  }

  // getProfilePic() async{
  //   var firebaseUser = await FirebaseAuth.instance.currentUser;
  //   DocumentSnapshot userDocument = await userCollection.doc(firebaseUser.email).get();
  //   return userDocument.data()['profilePic'].toString();
  // }

  options(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            elevation: 8.0,
            backgroundColor: kPrimaryLightColor,
            content: Text("Do you really want to logout", style: myStyle(20, kPrimaryColor)),
            actions: [
              FlatButton(
                color: Colors.red,
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Material(
          elevation: 8.0,
          borderRadius: BorderRadius.circular(20.0),
          child: TextFormField(
            onFieldSubmitted: (str) => searchMail(str),
            decoration: InputDecoration(
              hintText: 'Search....',
              border: InputBorder.none,
              icon: Container(
                margin: EdgeInsets.only(left: 5),
                child: Icon(Icons.search),
              ),
              suffixIcon: StreamBuilder(
                stream: userCollection.doc(userMail).snapshots(),
                builder: (context, snapshot) {
                  DocumentSnapshot ds =snapshot.data;
                  if(!snapshot.hasData){
                    return CircularProgressIndicator();
                  }
                  return Container(
                    margin: EdgeInsets.all(5),
                    child: InkWell(
                      onTap: () {},
                      child: InkWell(
                        onTap: () {
                          options();
                        },
                        child: CircleAvatar(backgroundColor: Colors.grey[300] ,
                          backgroundImage: NetworkImage(ds.data()['profilePic']),
                        ),
                      ),
                    ),
                  );
                }
              )
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ComposeMailScreen())),
        child: Icon(
          Icons.add,
          size: 32,
          color: kPrimaryLightColor,
        ),
      ),
      body: StreamBuilder(
        stream: myStream,
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return CircularProgressIndicator();
          }
          return snapshot.data.documents.length == 0 
              ? SingleChildScrollView(
                child: Center(
                  child: Container(
                    child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                        image : AssetImage('assets/empty_inbox_.png'),
                        width: MediaQuery.of(context).size.width * .80,
                        height: MediaQuery.of(context).size.height * .50,
                      ),
                        Text(
                          "Empty Inbox",
                          style: myStyle(30, Colors.black, FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                ),
              )
              :ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index){
                DocumentSnapshot email = snapshot.data.documents[index];
                return InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMailScreen(
                    id: email.data()['id'],
                    sender: email.data()['sender'],
                    time: email.data()['time'],
                    attachment: email.data()['attachment'],
                    mail: email.data()['mail'],
                    subject: email.data()['subject'],
                    profilePic: email.data()['profilePic'],
                    username: email.data()['username'],
                  ))),
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(email.data()['profilePic']),
                              radius: 25,
                            ),
                            SizedBox(width: 15.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  email.data()['username'],
                                  style: email.data()['hasRead'] == false
                                      ? myStyle(20, Colors.black, FontWeight.w700)
                                      : myStyle(20, Colors.black, FontWeight.w400),
                                ),
                                Text(
                                  email.data()['subject'],
                                  style: email.data()['hasRead'] == false
                                      ? myStyle(15, Colors.black, FontWeight.w600)
                                      : myStyle(15, Colors.black, FontWeight.w300),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(width: 5),
                        Column(
                          children: [
                            Text(
                              DateFormat.Hm().format(email.data()['time'].toDate()).toString(),
                              style: myStyle(18, Colors.black, FontWeight.w500),
                            ),
                            SizedBox(height: 5),
                            InkWell(
                              onTap: () => starMail(email.data()['id']),
                              child: email.data()['stared'] == false
                                  ? Icon(Icons.star_border, size: 32)
                                  : Icon(Icons.star, color: Colors.yellow, size: 32),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }
          );
        }
      )
    );
  }
}
