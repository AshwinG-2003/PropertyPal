import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:propertypal/screens/sign_up.dart';
import 'package:propertypal/widgets/auth_gate.dart';

import 'firebase_options.dart';

Future<void> main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PropertyPal',
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
