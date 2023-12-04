import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  // ignore: library_private_types_in_public_api
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

  void _showConnectivityToast() async {
    ConnectivityResult result = await checkConnectivity();

    if (result == ConnectivityResult.none) {
      _showToast(
        'No internet connection: Showing possible old information.',
        0xFFFFD2D2, // Red color
      );
    } else {
      _showToast(
        'Connected to the internet: Showing the latest information.',
        0xFFC2FFC2, // Green color
      );
    }
  }

// Function to show toast notifications
  void _showToast(String message, int backgroundColorHex) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      fontSize: 16.0,
      backgroundColor: Color(backgroundColorHex),
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    _showConnectivityToast();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.bottomLeft,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      //cacheExtent: 10,
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
                    radius: 36,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.itemData?.getPhoto ?? '',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.itemData!.name.length > 15
                        ? '${widget.itemData!.name.substring(0, 15)}...'
                        : widget.itemData!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
                          fontSize: 11,
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
