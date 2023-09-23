import 'package:flutter/material.dart';
import 'package:fud/home.dart';
import 'package:fud/login.dart';
import 'package:fud/appRouter.dart';
import 'package:fud/plateOffer.dart';
import 'package:fud/restaurant.dart';

void main() {
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
      initialRoute: HomePage.routeName,
      routes: AppRouter.routes,
    );
  }
}
