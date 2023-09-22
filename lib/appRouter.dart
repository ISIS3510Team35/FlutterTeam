import 'package:flutter/material.dart';
import 'package:fud/inicioSesion.dart';

class AppRouter {
  String initialRoute = HomePage.routeName;

  static Map<String, Widget Function(BuildContext)> routes = {
    HomePage.routeName: (BuildContext context) => const HomePage(),
  };
}
