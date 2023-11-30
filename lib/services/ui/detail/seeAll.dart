import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fud/services/blocs/plate_bloc.dart';
import 'package:fud/services/blocs/restaurant_bloc.dart';
import 'package:fud/services/models/plate_model.dart';
import 'package:fud/services/models/restaurant_model.dart';
import 'package:fud/services/ui/detail/plateOffer.dart';

class AllPlates extends StatefulWidget {
  static const routeName = '/seeAll';

  const AllPlates({
    Key? key,
    required this.category,
    required this.restaurantId,
  }) : super(key: key);

  final String category;
  final num restaurantId;

  @override
  _AllPlatesState createState() => _AllPlatesState();
}

class _AllPlatesState extends State<AllPlates> {
  late PlateBloc plateBloc;
  late RestaurantBloc restaurantBloc;
  late ConnectivityResult connectivityResult =
      ConnectivityResult.none; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    plateBloc = PlateBloc();
    restaurantBloc = RestaurantBloc();
    checkConnectivity().then((result) {
      setState(() {
        connectivityResult = result;
      });
    });
    plateBloc.fetchCategoryOrRestaurantPlates(
        widget.category, widget.restaurantId);
  }

  // Function to check the current connectivity status
  Future<ConnectivityResult> checkConnectivity() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.bottomLeft,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show message when there's no internet connection
            if (connectivityResult == ConnectivityResult.none)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No internet: Cache information',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            StreamBuilder(
              stream: plateBloc.categoryPlates,
              builder: (context, AsyncSnapshot<PlateList> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty()) {
                  return const Center(child: Text('No data available'));
                } else {
                  final items = snapshot.data?.plates;
                  return Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: items?.length,
                      itemBuilder: (context, index) {
                        final itemData = items?[index];
                        return ItemWidget(
                          itemData: itemData,
                          onPressed: () {
                            plateBloc.fetchAnalyticFavorite(false, true);
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
        margin: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: 150,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.itemData?.getPhoto ?? '',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.itemData!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Manrope',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${restaurantData?.name} | ${widget.itemData?.price} K',
                    style: const TextStyle(
                      fontSize: 12,
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
                          fontSize: 12,
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
    );
  }
}
