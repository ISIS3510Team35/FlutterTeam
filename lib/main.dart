import 'package:flutter/material.dart';
import 'package:fud/home.dart';
import 'package:fud/login.dart';
import 'package:fud/appRouter.dart';
import 'package:fud/plateOffer.dart';
import 'package:fud/restaurant.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fUd',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 114, 100, 94)),
        useMaterial3: true,
      ),
      initialRoute: LoginPage.routeName,
      routes: AppRouter.routes,
    );
  }
}
