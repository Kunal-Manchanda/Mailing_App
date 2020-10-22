import 'file:///D:/AndroidProjects/mailing_app/lib/utils/variables.dart';

class CurrentUser{
  storeUser({email, username, password, profilePic}){
    userCollection.doc(email).set({
      'email': email,
      'username': username,
      'password': password,
      'profilePic': profilePic
    });
  }
}