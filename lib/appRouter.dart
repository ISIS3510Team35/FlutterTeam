import 'package:flutter/material.dart';
import 'package:fud/services/ui/detail/account.dart';
import 'package:fud/services/ui/detail/plateOffer.dart';
import 'package:fud/services/ui/detail/resutls.dart';
import 'package:fud/services/ui/home/home_page.dart';
import 'package:fud/services/ui/login/login.dart';

class AppRouter {
  String initialRoute = LoginPage.routeName;

  static Map<String, WidgetBuilder> routes(BuildContext context) {
    return {
      LoginPage.routeName: (context) =>
          const LoginPage(),
      HomePage.routeName: (context) =>
          const HomePage(),
      PlateOfferPage.routeName: (context) => const PlateOfferPage(plateId: 1),
      ResultsPage.routeName: (context) => const ResultsPage(
            maxPrice: 100.0,
            isVegano: false,
            isVegetariano: false,
          ),
      AccountPage.routeName: (context) => const AccountPage(),
    };
  }
}
