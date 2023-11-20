import 'package:flutter/material.dart';
import 'package:fud/services/ui/resutls.dart';
import 'package:fud/services/gps_service.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({Key? key}) : super(key: key);

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(500);
}

var gps = GPS();

class _AppHeaderState extends State<AppHeader> {
  @override
  void initState() {
    super.initState();
    gps.liveLocation();
  }

  double lat_u = 4.6031;
  double lon_u = -74.0659;
  double _price = 100.0;

  bool vegano = false;
  bool vegetariano = false;
  bool filter = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Color.fromRGBO(255, 247, 235, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 25 / 2.5,
              ),
              height: 80,
              color: Color.fromRGBO(255, 247, 235, 1),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 30,
                  ),
                  Image.asset(
                    'assets/Logo.png',
                    height: 40,
                  ),
                  ValueListenableBuilder<double>(
                      valueListenable: GPS.lat,
                      builder:
                          (BuildContext context, double value, Widget? child) {
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
                                //color: Color.fromRGBO(183, 28, 28, 1),
                              )
                            else if (calculateDistance(
                                    gps.getLat(), lat_u, gps.getLong(), lon_u) <
                                0.5)
                              const Icon(
                                Icons.my_location,
                                size: 25,
                                color: Colors.green,
                              )
                            else
                              const Icon(
                                Icons.location_searching,
                                size: 25,
                              )
                          ],
                        );
                      })
                ],
              ),
            ),
            Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 25 / 2.5,
                ),
                height: 80,
                color: Color.fromRGBO(255, 247, 235, 1),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: TextField(
                        autocorrect: true,
                        decoration: InputDecoration(
                          hintText: 'Busca tu almuerzo de hoy',
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(7.0)),
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7.0))),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    IconButton.filled(
                        onPressed: () {
                          setState(() {
                            filter = !filter;
                          });
                        },
                        icon: const Icon(
                          Icons.tune,
                        ),
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.0)),
                          ),
                        )),
                  ],
                )),
            if (filter == true)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                height: 300,
                color: Color.fromRGBO(253, 249, 242, 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Filtrar por precio",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.bold,
                              )),
                          _price != 100
                              ? Text(
                                  'max ${double.parse(_price.toStringAsFixed(1))} K',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.bold,
                                  ))
                              : const Text('sin filtro',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.bold,
                                  ))
                        ]),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text('10 K',
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Manrope",
                                fontStyle: FontStyle.italic)),
                        Flexible(
                            child: Slider(
                                max: 100.0,
                                min: 10.0,
                                value: _price,
                                thumbColor: Color.fromRGBO(253, 218, 168, 1),
                                activeColor: Color.fromRGBO(255, 188, 91, 1),
                                onChanged: (double newValue) {
                                  setState(() {
                                    _price = newValue;
                                  });
                                })),
                        const Text("100K",
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Manrope",
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                    const Text("Filtrar por tipo de comida",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.bold,
                        )),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Switch(
                          value: vegano,
                          onChanged: (value) {
                            setState(() {
                              vegano = value;
                            });
                          },
                          thumbColor: MaterialStateProperty.all<Color>(
                              Color.fromRGBO(255, 188, 91, 1)),
                          activeColor: Color.fromRGBO(253, 218, 168, 1),
                          trackOutlineColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          inactiveTrackColor:
                              Color.fromRGBO(253, 218, 168, 0.4),
                        ),
                        const Text("Vegana",
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Manrope",
                                fontStyle: FontStyle.italic)),
                        Switch(
                          value: vegetariano,
                          onChanged: (value) {
                            setState(() {
                              vegetariano = value;
                            });
                          },
                          thumbColor: MaterialStateProperty.all<Color>(
                              Color.fromRGBO(255, 188, 91, 1)),
                          activeColor: Color.fromRGBO(253, 218, 168, 1),
                          trackOutlineColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          inactiveTrackColor:
                              Color.fromRGBO(253, 218, 168, 0.4),
                        ),
                        const Text("Vegetariana",
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Manrope",
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                    /*const Text("Filtrar por tiempo de espera máximo",
                        style: TextStyle(fontSize: 18, fontFamily: "Manrope")),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                            child: Slider(
                                max: 100.0,
                                min: 0.0,
                                value: _time,
                                thumbColor: Color.fromRGBO(253, 218, 168, 1),
                                activeColor: Color.fromRGBO(255, 188, 91, 1),
                                onChanged: (double newValue) {
                                  setState(() {
                                    _time = newValue;
                                  });
                                })),
                        const Text("60 min",
                            style:
                                TextStyle(fontSize: 18, fontFamily: "Manrope")),
                      ],
                    ),*/
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultsPage(
                                max_price: _price,
                                vegano: vegano,
                                vegetariano: vegetariano,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(255, 146, 45,
                              1), // Cambia el color de fondo a naranja
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          minimumSize:
                              const Size(190, 50), // Cambia el tamaño del botón
                        ),
                        child: const Text(
                          'Aplicar Filtros',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Manrope",
                              color:
                                  Colors.white), // Cambia el tamaño del texto
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
