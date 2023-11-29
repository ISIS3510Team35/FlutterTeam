import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fud/services/blocs/plate_bloc.dart';
import 'package:fud/services/resources/google_maps.dart'; // Import the PlateBloc class

class ResultsPage extends StatefulWidget {
  static const routeName = '/results';

  final double maxPrice;
  final bool isVegano;
  final bool isVegetariano;

  const ResultsPage({
    Key? key,
    required this.maxPrice,
    required this.isVegano,
    required this.isVegetariano,
  }) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late PlateBloc _plateBloc; // Create an instance of PlateBloc

  @override
  void initState() {
    super.initState();
    _plateBloc = PlateBloc();
    _plateBloc.fetchFilterInfo(
        widget.maxPrice, widget.isVegetariano, widget.isVegano);
  }

  @override
  void dispose() {
    _plateBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: StreamBuilder<Map<num, List>>(
        stream: _plateBloc.filterPlates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final filterResult = snapshot.data ?? {};

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

  Widget buildPaddingAndRestaurantWidgets(
      Map<num, List<dynamic>> filterResult) {
    return Column(
      children: filterResult.entries
          .map((data) => [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  child: Divider(),
                ),
                RestaurantResume(data: data.value),
              ])
          .expand((element) => element)
          .toList(),
    );
  }
}

class RestaurantResume extends StatelessWidget {
  final List<dynamic> data;

  const RestaurantResume({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String restaurantName = data[0]['restaurant_name'].toString();
    GeoPoint addressPoint = data[0]['restaurant_location'];
    double latitude = addressPoint.latitude;
    double longitude = addressPoint.longitude;
    String address = "A ${data[0]['distancia'].toStringAsFixed(3)} Km de ti";
    String photo = data[0]['restaurant_photo'].toString();

    return GestureDetector(
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
                    child: Image(
                      image: CachedNetworkImageProvider(photo),
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Row(
                  children: [
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
                  ],
                )
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
                      ),
                    ),
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
                  ),
                ),
                TextButton(
                  onPressed: () {
                    MapUtils().openMap(latitude, longitude);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromRGBO(245, 90, 81, 1)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cómo llegar",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class OthersSection extends StatelessWidget {
  final List<dynamic> data;

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
                asset: data[index]['image'],
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
    return Container(
      margin: const EdgeInsets.all(12.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            width: 120,
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: CachedNetworkImageProvider(asset),
                    height: 92,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Manrope',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$price K',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Manrope',
                      color: Color.fromRGBO(255, 146, 45, 1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}