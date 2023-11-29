import 'package:flutter/material.dart';
import 'package:fud/services/blocs/plate_bloc.dart';
import 'package:fud/services/ui/detail/plateOffer.dart';
import 'package:fud/services/ui/detail/resutls.dart';
import 'package:fud/services/ui/home/home_page.dart';
import 'package:fud/services/ui/login/login.dart';

class AppRouter {
  String initialRoute = LoginPage.routeName;
  late final PlateBloc _plateBloc;

  AppRouter() : _plateBloc = PlateBloc();

  static Map<String, WidgetBuilder> routes(BuildContext context) {
    return {
      LoginPage.routeName: (context) =>
          LoginPage(plateBloc: AppRouter()._plateBloc),
      HomePage.routeName: (context) =>
          HomePage(plateBloc: AppRouter()._plateBloc),
      PlateOfferPage.routeName: (context) => const PlateOfferPage(plateId: 1),
      ResultsPage.routeName: (context) => const ResultsPage(
            maxPrice: 100.0,
            isVegano: false,
            isVegetariano: false,
          ),
    };
  }
}
