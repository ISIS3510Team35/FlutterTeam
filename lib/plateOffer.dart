import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fud/appHeader.dart';
import 'package:fud/services/factories.dart';
import 'package:fud/services/firebase_services.dart';
import 'package:fud/services/google_maps.dart';

class PlateOfferPage extends StatefulWidget {
  static const routeName = '/PlateOffer';

  final String idPlate;
  final String idRestaurant;

  const PlateOfferPage({
    Key? key,
    required this.idPlate,
    required this.idRestaurant,
  }) : super(key: key);

  @override
  State<PlateOfferPage> createState() => _PlateOfferPageState();
}

class _PlateOfferPageState extends State<PlateOfferPage> {
  late Future<Plate?> plateFuture;
  late Future<Restaurant?> restaurantFuture;

  @override
  void initState() {
    super.initState();
    plateFuture = getPlate(id: widget.idPlate);
    restaurantFuture = getRestaurant(id: widget.idRestaurant);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: FutureBuilder(
        future: Future.wait([plateFuture, restaurantFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final plate = snapshot.data?[0] as Plate?;
            final restaurant = snapshot.data?[1] as Restaurant?;

            return ListView(
              children: [
                if (restaurant != null)
                  ImageWithCaptionSection(imageUrl: restaurant.photo),
                if (restaurant != null && plate != null)
                  OneCardSection(
                      title: plate.name,
                      rating: plate.rating,
                      cafeteriaName: restaurant.name,
                      ratingCount: plate.price,
                      description: plate.description,
                      location: restaurant.location),
                const OthersSection()
              ],
            );
          }
        },
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      color: const Color.fromRGBO(255, 146, 45, 1),
      child: const Text(
        'Header Title',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ImageWithCaptionSection extends StatelessWidget {
  final String imageUrl;
  const ImageWithCaptionSection({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Opacity(
            opacity: 0.9,
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class OneCardSection extends StatelessWidget {
  final String title;
  final double rating;
  final String cafeteriaName;
  final double ratingCount;
  final String description;
  final GeoPoint location;

  const OneCardSection({
    Key? key,
    required this.title,
    required this.rating,
    required this.cafeteriaName,
    required this.ratingCount,
    required this.description,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(width: 50),
              const Icon(
                Icons.star,
                color: Color.fromRGBO(255, 146, 45, 1),
              ),
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Manrope',
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 0),
          Text(
            cafeteriaName,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 0),
          Text(
            '$ratingCount K',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
              color: Color.fromRGBO(255, 146, 45, 1),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 0),
          Card(
            elevation: 4,
            margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ), // Add some space between the card and the buttons
          ButtonRow(
              latitude: location.latitude,
              longitude:
                  location.longitude), // Include the ButtonRow widget here
        ],
      ),
    );
  }
}

class ButtonRow extends StatelessWidget {
  final double latitude;
  final double longitude;

  const ButtonRow({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 135,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {},
            label: const Text(
              'Añadir a favoritos',
              style: TextStyle(color: Colors.white), // White text color
            ),
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.white, // White icon color
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(245, 90, 81, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              MapUtils.openMap(latitude, longitude);
            },
            label: const Text(
              '¿Cómo llegar?',
              style: TextStyle(color: Colors.white), // White text color
            ),
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.white, // White icon color
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(245, 90, 81, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OthersSection extends StatelessWidget {
  const OthersSection({Key? key});

  @override
  Widget build(BuildContext context) {
    const items = 6;
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Otros Platos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items,
              itemBuilder: (context, index) => OtherWidget(index: index),
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
    required this.index,
  }) : super(key: key);

  final int index;

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
                Image.asset(
                  'assets/$index.png',
                  height: 80,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Hamburguesa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Manrope',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  ' ${index + 1 * 10} K',
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
