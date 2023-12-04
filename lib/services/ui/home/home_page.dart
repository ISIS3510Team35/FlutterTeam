import 'package:flutter/material.dart';
import 'package:fud/services/blocs/plate_bloc.dart';
import 'package:fud/services/ui/detail/appHeader.dart';
import 'package:fud/services/ui/home/category_section.dart';
import 'package:fud/services/ui/home/discount_section.dart';
import 'package:fud/services/ui/home/favority_section.dart';
import 'package:fud/services/ui/home/recomendation_section.dart';
import 'package:fud/services/ui/home/top3_section.dart';
import 'package:fud/services/blocs/user_bloc.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key, required this.plateBloc}) : super(key: key);

  final PlateBloc plateBloc;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime entryTime;
  final UserBloc _userBloc = UserBloc();

  @override
  void initState() {
    super.initState();
    entryTime = DateTime.now();
    widget.plateBloc.fetchOfferPlates();
  }

  @override
  void dispose() {
    // Calcular la duración al salir de la vista
    Duration duration = DateTime.now().difference(entryTime);

    // Enviar la duración a Firebase o realizar cualquier acción necesaria
    _userBloc.timeView(duration.inMilliseconds, 'Home Screen');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 7),
        children: [
          const CategorySection(),
          const SizedBox(height: 7),
          Top3(plateBloc: widget.plateBloc),
          const SizedBox(height: 7),
          DiscountSection(plateBloc: widget.plateBloc),
          const SizedBox(height: 7),
          FavouritesSection(plateBloc: widget.plateBloc),
          const SizedBox(height: 7),
          Recommendations(plateBloc: widget.plateBloc),
          const SizedBox(height: 20), // Adjust the height as needed
        ],
      ),
    );
  }
}
