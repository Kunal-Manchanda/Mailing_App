import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

TextStyle myStyle(double size, [Color color, FontWeight fw]){
  return GoogleFonts.montserrat(
    fontSize: size,
    fontWeight: fw,
    color: color,
  );
}

CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
StorageReference profilePics = FirebaseStorage.instance.ref().child('profilePic');
StorageReference attachments = FirebaseStorage.instance.ref().child('attachments');
String exampleImage='https://www.pngkit.com/png/full/72-729613_icons-logos-emojis-user-icon-png-transparent.png';