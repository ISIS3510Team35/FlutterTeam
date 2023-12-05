import 'package:flutter/material.dart';
import 'package:fud/services/resources/gps_service.dart';

class AppHeaderNoFilter extends StatefulWidget implements PreferredSizeWidget {
  const AppHeaderNoFilter({Key? key}) : super(key: key);

  @override
  State<AppHeaderNoFilter> createState() => _AppHeaderNoFilterState();

  @override
  Size get preferredSize => const Size.fromHeight(500);
}

var gps = GPS();

class _AppHeaderNoFilterState extends State<AppHeaderNoFilter> {
  @override
  void initState() {
    super.initState();
    gps.liveLocation();
  }

  // ignore: non_constant_identifier_names
  double lat_u = 4.6031;
  // ignore: non_constant_identifier_names
  double lon_u = -74.0659;

  bool vegano = false;
  bool vegetariano = false;
  bool filter = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            color: const Color.fromRGBO(255, 247, 235, 1),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 25 / 2.5,
                ),
                height: 80,
                color: const Color.fromRGBO(255, 247, 235, 1),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.filter_list,
                      size: 30,
                      color: Color.fromRGBO(255, 247, 235, 1),
                    ),
                    Image.asset(
                      'assets/Logo.png',
                      height: 40,
                    ),
                    ValueListenableBuilder<double>(
                        valueListenable: GPS.lat,
                        builder: (BuildContext context, double value,
                            Widget? child) {
                          // This builder will only get called when the _counter
                          // is updated.
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              if (gps.getLat() == 0.0 || gps.getLong() == 0.0)
                                const Icon(
                                  Icons.location_disabled,
                                  size: 25,
                                  color: Color.fromRGBO(255, 247, 235, 1),
                                )
                              else if (calculateDistance(gps.getLat(), lat_u,
                                      gps.getLong(), lon_u) <
                                  0.5)
                                Image.asset(
                                  'assets/uniandes.png',
                                  height: 25,
                                )
                              else
                                const Icon(
                                  Icons.location_searching,
                                  size: 25,
                                  color: Color.fromRGBO(255, 247, 235, 1),
                                )
                            ],
                          );
                        })
                  ],
                ),
              ),
            ])));
  }
}
