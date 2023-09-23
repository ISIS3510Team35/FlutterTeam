import 'package:flutter/material.dart';
import 'package:fud/home.dart';
import 'package:fud/login.dart';
import 'package:fud/plateOffer.dart';
import 'package:fud/restaurant.dart';

class AppRouter {
  String initialRoute = LoginPage.routeName;

  static Map<String, Widget Function(BuildContext)> routes = {
    LoginPage.routeName: (BuildContext context) => const LoginPage(),
    HomePage.routeName: (BuildContext context) => const HomePage(),
    RestaurantPage.routeName: (BuildContext context) => const RestaurantPage(),
    PlateOfferPage.routeName: (BuildContext context) => const PlateOfferPage(),
  };
}
