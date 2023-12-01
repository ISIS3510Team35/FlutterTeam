import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fud/services/blocs/plate_bloc.dart';
import 'package:fud/services/blocs/restaurant_bloc.dart';
import 'package:fud/services/models/plate_model.dart';
import 'package:fud/services/models/restaurant_model.dart';
import 'package:fud/services/ui/detail/plateOffer.dart';

class FavouritesSection extends StatefulWidget {
  const FavouritesSection({Key? key, required this.plateBloc})
      : super(key: key);

  final PlateBloc plateBloc;

  @override
  // ignore: library_private_types_in_public_api
  _FavouritesSectionState createState() => _FavouritesSectionState();
}

class _FavouritesSectionState extends State<FavouritesSection> {
  @override
  void initState() {
    super.initState();
    widget.plateBloc.fetchFavoritePlates();
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
            '    Favoritos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Manrope',
            ),
            textAlign: TextAlign.left,
          ),
          StreamBuilder(
            stream: widget.plateBloc.favPlates,
            builder: (context, AsyncSnapshot<PlateList> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading data'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty()) {
                return const Center(
                  child: Text('No hay platos en favoritos :('),
                );
              } else {
                final items = snapshot.data?.plates;
                return SizedBox(
                  height: 332,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items?.length,
                    itemBuilder: (context, index) {
                      final itemData = items?[index];
                      return ItemWidget(
                        itemData: itemData,
                        onPressed: () {
                          widget.plateBloc.fetchAnalyticFavorite(false, true);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlateOfferPage(plateId: itemData!.id),
                            ),
                          );
                        },
                        restaurantBloc: RestaurantBloc(),
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
  const ItemWidget({
    Key? key,
    required this.itemData,
    required this.onPressed,
    required this.restaurantBloc,
  }) : super(key: key);

  final Plate? itemData;
  final VoidCallback onPressed;
  final RestaurantBloc restaurantBloc;

  @override
  // ignore: library_private_types_in_public_api
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  Restaurant? restaurantData;

  @override
  void initState() {
    super.initState();
    widget.restaurantBloc.restaurantDetails.listen((restaurant) {
      setState(() {
        restaurantData = restaurant;
      });
    });

    if (widget.itemData != null && widget.itemData?.restaurant != null) {
      widget.restaurantBloc.fetchRestaurantDetails(widget.itemData!.restaurant);
    }
  }

  @override
  void dispose() {
    widget.restaurantBloc.dispose();
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.itemData?.getPhoto ?? '',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (widget.itemData?.name)!.length > 15 ? '${(widget.itemData?.name??'').substring(0, 15)}...' : (widget.itemData?.name ??'') ,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Manrope',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      restaurantData?.name ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Manrope',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${widget.itemData?.price} K',
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
                          widget.itemData?.rating.toString() ?? '',
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
