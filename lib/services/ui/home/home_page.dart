import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fud/services/blocs/plate_bloc.dart';
import 'package:fud/services/blocs/restaurant_bloc.dart';
import 'package:fud/services/ui/detail/appHeader.dart';
import 'package:fud/services/ui/home/category_section.dart';
import 'package:fud/services/ui/home/discount_section.dart';
import 'package:fud/services/ui/home/favority_section.dart';
import 'package:fud/services/ui/home/most_interacted_rest.dart';
import 'package:fud/services/ui/home/recomendation_section.dart';
import 'package:fud/services/ui/home/top3_section.dart';
import 'package:fud/services/blocs/user_bloc.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PlateBloc plateBloc = PlateBloc();
  late DateTime entryTime;
  final UserBloc _userBloc = UserBloc();
  
  final RestaurantBloc _restaurantBloc = RestaurantBloc();

  @override
  void initState() {
    super.initState();
    entryTime = DateTime.now();
    plateBloc.fetchOfferPlates();
  }

  @override
  void dispose() {
    // Calcular la duración al salir de la vista
    Duration duration = DateTime.now().difference(entryTime);
    plateBloc.dispose();
    // Enviar la duración a Firebase o realizar cualquier acción necesaria
    _userBloc.timeView(duration.inMilliseconds, 'Home Screen');
    _userBloc.dispose();
    super.dispose();
  }

  // Function to check the current connectivity status
  Future<ConnectivityResult> checkConnectivity() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    return result;
  }

  void _showConnectivityToast() async {
    ConnectivityResult result = await checkConnectivity();

    if (result == ConnectivityResult.none) {
      _showToast(
        'Sin conexión an Internet: mostrando datos antiguos.',
        0xFFFFD2D2, // Red color
      );
    } else {
      _showToast(
        'Conectado a Internet: Mostrando la información más reciente.',
        0xFFC2FFC2, // Green color
      );
    }
  }

// Function to show toast notifications
  void _showToast(String message, int backgroundColorHex) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      fontSize: 16.0,
      backgroundColor: Color(backgroundColorHex),
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    _showConnectivityToast();
    return Scaffold(
      appBar: const AppHeader(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 7),
        children: [
          const CategorySection(),
          const SizedBox(height: 7),
          Top3(plateBloc: plateBloc),
          const SizedBox(height: 7),
          DiscountSection(plateBloc: plateBloc),
          const SizedBox(height: 7),
          FavouritesSection(plateBloc: plateBloc),
          const SizedBox(height: 7),
          Recommendations(plateBloc: plateBloc),
          const SizedBox(height: 7),
          MostInteractedSection(restaurantBloc: _restaurantBloc, plateBloc: plateBloc,),
          const SizedBox(height: 20), // Adjust the height as needed
        ],
      ),
    );
  }
}
