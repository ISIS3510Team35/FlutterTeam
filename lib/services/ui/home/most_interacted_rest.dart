import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fud/services/blocs/plate_bloc.dart';
import 'package:fud/services/blocs/restaurant_bloc.dart';
import 'package:fud/services/models/plate_model.dart';
import 'package:fud/services/models/restaurant_model.dart';
import 'package:fud/services/ui/detail/restaurant.dart';

class MostInteractedSection extends StatefulWidget {
  const MostInteractedSection(
      {Key? key, required this.restaurantBloc, required this.plateBloc})
      : super(key: key);

  final RestaurantBloc restaurantBloc;
  final PlateBloc plateBloc;

  @override
  // ignore: library_private_types_in_public_api
  _MostInteractedSectionSectionState createState() =>
      _MostInteractedSectionSectionState();
}

class _MostInteractedSectionSectionState extends State<MostInteractedSection> {
  @override
  void initState() {
    super.initState();
    widget.restaurantBloc.fetchRestaurantMostInteracted();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '    Restaurantes para ti',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.left,
          ),
          StreamBuilder(
            stream: widget.restaurantBloc.offerMostInt,
            builder: (context, AsyncSnapshot<RestaurantList> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading data'),
                );
              } else if (!snapshot.hasData) {
                return const Center(
                  child: Text('No hay platos en favoritos :('),
                );
              } else {
                final items = snapshot.data?.restaurants;
                return SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items?.length,
                    itemBuilder: (context, index) {
                      final itemData = items?[index];
                      //return Text(itemData!.getName);
                      return ItemWidget(
                        itemData: itemData,
                        onPressed: () {
                          widget.plateBloc.fetchAnalyticFavorite(false, true);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RestaurantPage(restaurantId: itemData!.id),
                            ),
                          );
                        },
                        restaurantBloc: RestaurantBloc(),
                        plateBloc: PlateBloc(),
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

class ItemWidget extends StatefulWidget {
  const ItemWidget(
      {Key? key,
      required this.itemData,
      required this.onPressed,
      required this.restaurantBloc,
      required this.plateBloc})
      : super(key: key);

  final Restaurant? itemData;
  final VoidCallback onPressed;
  final RestaurantBloc restaurantBloc;
  final PlateBloc plateBloc;

  @override
  // ignore: library_private_types_in_public_api
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  PlateList? platesList;

  @override
  void initState() {
    super.initState();
    widget.plateBloc.minmaxPlates.listen((plates) {
      setState(() {
        platesList = plates;
      });
    });
    if (widget.itemData != null) {
      widget.plateBloc.fetchMinMaxPrice(widget.itemData!.id);
    }
  }

  @override
  void dispose() {
    widget.plateBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        margin: const EdgeInsets.all(12.0),
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      key: UniqueKey(),
                      imageUrl: widget.itemData!.getPhoto,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (widget.itemData?.name)!.length > 15
                          ? '${(widget.itemData?.name ?? '').substring(0, 15)}...'
                          : (widget.itemData?.name ?? ''),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Manrope',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${platesList?.plates[0].getPrice} K - ${platesList?.plates[1].getPrice} K',
                      style: const TextStyle(
                        fontSize: 20,
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
      ),
    );
  }
}
