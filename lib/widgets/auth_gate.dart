import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:propertypal/screens/dashboard.dart';
import 'package:propertypal/screens/login_screens.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if (!snapshot.hasData){
          return Login();
        }
        return Dashboard();
      }
    );
  }
}
