import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fud/appHeader.dart';
import 'package:fud/restaurant.dart';
import 'package:fud/services/firebase_services.dart';
import 'package:fud/services/google_maps.dart';

class ResultsPage extends StatefulWidget {
  static const routeName = '/results';

  final double max_price;
  final bool vegano;
  final bool vegetariano;
  const ResultsPage({Key? key, 
  required this.max_price,
  required this.vegano,
  required this.vegetariano}) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late Future<Map<String, List>> filterFuture;

  @override
  void initState() {
    super.initState();
    filterFuture = getFilter(widget.max_price, widget.vegetariano, widget.vegano);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: FutureBuilder<Map<String, List>>(
        future: filterFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final filterResult =
                snapshot.data ?? {}; // Use {} for default value

            return ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Ordenar por ",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text(
                        "Cercania ",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                ),
                buildPaddingAndRestaurantWidgets(filterResult),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildPaddingAndRestaurantWidgets(Map<String, List> filterResult) {
    List<Widget> widgets = [];

    for (var data in filterResult.entries) {
      String restaurantName = data.value[0]['restaurant_name']
          .toString(); // Get the restaurant name

      GeoPoint addressPoint = data.value[0]['restaurant_location'];
      double latitude = addressPoint.latitude;
      double longitude = addressPoint.longitude;

      String address = data.value[0]['distancia'].toStringAsFixed(4) +
          ' Km'; // Get the restaurant name

      String photo = data.value[0]['restaurant_photo'].toString();

      widgets.addAll([
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 25,
          ),
          child: Divider(),
        ),
        RestaurantResume(
            restaurantName: restaurantName,
            address: address,
            photo: photo,
            data: data.value,
            latitude: latitude,
            longitude: longitude),
      ]);
    }

    return Column(children: widgets);
  }
}

class RestaurantResume extends StatelessWidget {
  final String restaurantName;
  final String address;
  final String photo;
  final List data;
  final double latitude;
  final double longitude;

  const RestaurantResume({
    Key? key,
    required this.restaurantName,
    required this.address,
    required this.photo,
    required this.data,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar a la vista deseada aquí, por ejemplo:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const RestaurantPage(), // Reemplaza 'TuOtraVista' con el nombre de tu vista
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 25 / 2.5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 60,
                  child: ClipOval(
                      child: Image.network(
                    photo,
                    height: 140,
                    fit: BoxFit.cover,
                  )),
                ),
                Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        restaurantName,
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        address,
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ])
              ],
            ),
            OthersSection(data: data),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromRGBO(245, 90, 81, 1)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      )),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Añadir a favoritos",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                        )
                      ],
                    )),
                TextButton(
                    onPressed: () {
                      MapUtils.openMap(latitude, longitude);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromRGBO(245, 90, 81, 1)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      )),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Como llegar",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                        )
                      ],
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class OthersSection extends StatelessWidget {
  final List<dynamic> data; // Change data to List<Map<String, dynamic>>

  const OthersSection({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              itemBuilder: (context, index) => OtherWidget(
                asset: data[index]['photo'],
                name: data[index]['name'],
                price: data[index]['price'],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtherWidget extends StatelessWidget {
  const OtherWidget({
    Key? key,
    required this.asset,
    required this.name,
    required this.price,
  }) : super(key: key);

  final String asset;
  final String name;
  final num price;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(75.0),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: Container(
          width: 120,
          color: Colors.white,
          //padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  asset, // Use the user-defined asset parameter
                  height: 80,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 5),
                Text(
                  name, // Use the user-defined hamburger name parameter
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Manrope',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  '$price K', // Use the user-defined price parameter
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Manrope',
                      color: Color.fromRGBO(255, 146, 45, 1)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
