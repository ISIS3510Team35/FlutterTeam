import 'package:flutter/material.dart';
import 'package:fud/services/blocs/plate_bloc.dart';
import 'package:fud/services/ui/detail/appHeader.dart';
import 'package:fud/services/ui/home/discount_section.dart';
import 'package:fud/services/ui/home/favority_section.dart';
import 'package:fud/services/ui/home/top3_section.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key, required this.plateBloc}) : super(key: key);

  final PlateBloc plateBloc;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.plateBloc.fetchOfferPlates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 7),
        children: [
          // const CategorySection(),
          const SizedBox(height: 7),
          Top3(plateBloc: widget.plateBloc),
          const SizedBox(height: 7),
          DiscountSection(plateBloc: widget.plateBloc),
          const SizedBox(height: 7),
          FavouritesSection(plateBloc: widget.plateBloc),
        ],
      ),
    );
  }
}
