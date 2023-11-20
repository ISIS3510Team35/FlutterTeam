import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fud/services/ui/appHeader.dart';
import 'package:fud/services/ui/plateOffer.dart';
import 'package:fud/services/resources/firebase_services.dart';

RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: ListView(
        children: [
          CategorySection(),
          SizedBox(height: 7),
          LunchSection(),
          SizedBox(height: 7),
          DiscountSection(),
          SizedBox(height: 7),
          FavouritesSection()
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------------------ Best 3

class LunchSection extends StatelessWidget {
  const LunchSection({Key? key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '    Top 3',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.left,
          ),
          FutureBuilder(
            future: getBest(rootIsolateToken),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading data'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No data available'),
                );
              } else {
                final items = snapshot.data?.length;
                return SizedBox(
                  height: 332,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items,
                    itemBuilder: (context, index) {
                      final itemData = snapshot.data?[index];
                      return ItemWidget(
                        index: index,
                        itemName: itemData['name'],
                        itemDescription: itemData['restaurant_name'],
                        itemPrice: itemData['price'],
                        itemPhoto: itemData['image'],
                        itemRating: itemData['rating'],
                        itemIdRes: itemData['restaurantId'],
                        itemId: itemData['id'],
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class FavouritesSection extends StatelessWidget {
  FavouritesSection({Key? key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '    Favoritos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.left,
          ),
          FutureBuilder(
            future: Favourites(rootIsolateToken),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading data'),
                );
              } else if (!snapshot.hasData ||
                  snapshot.data!.isEmpty ||
                  snapshot.data == []) {
                return const Center(
                  child: Text('No hay platos en favoritos :('),
                );
              } else {
                final items = snapshot.data?.length;
                return SizedBox(
                  height: 332,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items,
                    itemBuilder: (context, index) {
                      final itemData = snapshot.data?[index];
                      return ItemWidget(
                        index: index,
                        itemName: itemData['name'],
                        itemDescription: itemData['restaurant_name'],
                        itemPrice: itemData['price'],
                        itemPhoto: itemData['image'],
                        itemRating: itemData['rating'],
                        itemIdRes: itemData['restaurantId'],
                        itemId: itemData['id'],
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    Key? key,
    required this.index,
    required this.itemName,
    required this.itemDescription,
    required this.itemPrice,
    required this.itemPhoto,
    required this.itemRating,
    required this.itemId,
    required this.itemIdRes,
  }) : super(key: key);

  final int index;
  final String itemName;
  final String itemDescription;
  final num itemPrice;
  final String itemPhoto;
  final num itemRating;
  final num itemId;
  final num itemIdRes;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        createFavPromoAnalyticsDocument(false, true, rootIsolateToken);
        // Navigate to the desired view here, for example:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PlateOfferPage(idPlate: itemId, idRestaurant: itemIdRes),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(12.0), // Espacio entre las tarjetas
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: 200,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: CachedNetworkImageProvider(itemPhoto),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      itemName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Manrope',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      itemDescription,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Manrope',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$itemPrice K',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Manrope',
                        color: Color.fromRGBO(255, 146, 45, 1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color.fromRGBO(255, 146, 45, 1),
                        ),
                        Text(
                          itemRating.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------------ Categorias

class CategorySection extends StatelessWidget {
  const CategorySection({Key? key});

  @override
  Widget build(BuildContext context) {
    const items = 3;
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '    Categorias',
            style: TextStyle(
              fontSize: 20,
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
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Card(
        elevation: 4,
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
                    const Text(
                      'Almuerzo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Manrope',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Image.asset(
                      'assets/$index.png',
                      height: 95,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------------ Almuerzos para ti

class DiscountSection extends StatelessWidget {
  const DiscountSection({Key? key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '    Ofertas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.left,
          ),
          FutureBuilder(
            future: getOffer(rootIsolateToken),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading data'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No data available'),
                );
              } else {
                final items = snapshot.data?.length;
                return SizedBox(
                  height: 321,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items,
                    itemBuilder: (context, index) {
                      final itemData = snapshot.data?[index];
                      return ItemWidgetOffers(
                        index: index,
                        itemName: itemData['name'],
                        itemIdRes: itemData['restaurantId'],
                        itemDescription: itemData['restaurant_name'],
                        itemPrice: itemData['price'],
                        itemPriceOffer: itemData['offerPrice'],
                        itemPhoto: itemData['image'],
                        itemId: itemData['id'],
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class ItemWidgetOffers extends StatelessWidget {
  const ItemWidgetOffers({
    Key? key,
    required this.index,
    required this.itemName,
    required this.itemDescription,
    required this.itemPrice,
    required this.itemPriceOffer,
    required this.itemPhoto,
    required this.itemId,
    required this.itemIdRes,
  }) : super(key: key);

  final int index;
  final String itemName;
  final String itemDescription;
  final num itemPrice;
  final num itemPriceOffer;
  final String itemPhoto;
  final num itemId;
  final num itemIdRes;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        createFavPromoAnalyticsDocument(false, true, rootIsolateToken);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlateOfferPage(
                idPlate: itemId,
                idRestaurant:
                    itemIdRes), // Reemplaza 'TuOtraVista' con el nombre de tu vista
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(12.0), // Espacio entre las tarjetas
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: 200,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: CachedNetworkImageProvider(itemPhoto),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Manrope',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    itemDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontFamily: 'Manrope',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: '$itemPrice K  ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Manrope',
                            color: Color.fromRGBO(255, 146, 45, 1),
                            decoration:
                                TextDecoration.lineThrough, // Add strikethrough
                          ),
                        ),
                        TextSpan(
                          text: '  $itemPriceOffer K ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Manrope',
                            color: Color.fromARGB(255, 201, 69,
                                69), // Change the color for the new price
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}