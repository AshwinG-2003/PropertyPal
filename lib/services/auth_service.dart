import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:propertypal/screens/dashboard.dart';
import 'package:propertypal/screens/login_screens.dart';
import 'db.dart';

class AuthService {
  var db = Db();

  Future<void> createUser(Map<String, dynamic> data, BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      await db.addUser(data, context);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Sign up Failed"),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  Future<void> login(Map<String, dynamic> data, BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Login Error"),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    var userID = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection('users').doc(userID);
    CollectionReference collectionReference =
    FirebaseFirestore.instance.collection('users').doc(userID).collection('properties');

    User user = FirebaseAuth.instance.currentUser!;
    try {
      await user.delete();
      await documentReference.delete();
      await collectionReference.parent!.delete();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Login()));
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Account Deletion Failed"),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      } catch (e) {
        rethrow;
      }
    }
  }
}

