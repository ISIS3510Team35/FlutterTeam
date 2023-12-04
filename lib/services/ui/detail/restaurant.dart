import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fud/services/models/plate_model.dart';
import 'package:fud/services/blocs/restaurant_bloc.dart';
import 'package:fud/services/blocs/plate_bloc.dart';
import 'package:fud/services/models/restaurant_model.dart';
import 'package:fud/services/resources/google_maps.dart';
import 'package:fud/services/blocs/user_bloc.dart';
import 'package:fud/services/ui/detail/plateOffer.dart';

class RestaurantPage extends StatefulWidget {
  static const routeName = '/restaurant';

  const RestaurantPage({Key? key, required this.restaurantId})
      : super(key: key);

  final num restaurantId;

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final _restaurantBloc = RestaurantBloc();
  final _plateBloc = PlateBloc();
  late DateTime entryTime;
  final UserBloc _userBloc = UserBloc();

  @override
  void initState() {
    super.initState();
    entryTime = DateTime.now();
    _restaurantBloc.fetchRestaurantDetails(widget.restaurantId);
    _plateBloc.fetchCategoryOrRestaurantPlates('', widget.restaurantId);
  }

  @override
  void dispose() {
    _restaurantBloc.dispose();
    _plateBloc.dispose();
    // Calcular la duración al salir de la vista
    Duration duration = DateTime.now().difference(entryTime);

    // Enviar la duración a Firebase o realizar cualquier acción necesaria
    _userBloc.timeView(duration.inMilliseconds, 'Restaurant Screen');
    _userBloc.dispose();
    super.dispose();
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
        'Sin conexión an Internet: mostrando datos antiguos.',
        0xFFFFD2D2, // Red color
      );
    } else {
      _showToast(
        'Conectado a Internet: Mostrando la información más reciente.',
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
        title: const Text(""),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          RestaurantImageWithCaptionSection(restaurantBloc: _restaurantBloc),
          RestaurantRecommendationsSection(
            plateBloc: _plateBloc,
          ),
        ],
      ),
    );
  }
}

class RestaurantImageWithCaptionSection extends StatelessWidget {
  final RestaurantBloc restaurantBloc;

  const RestaurantImageWithCaptionSection(
      {Key? key, required this.restaurantBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: restaurantBloc.restaurantDetails,
      builder: (context, AsyncSnapshot<Restaurant> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error al cargar los datos del restaurante.'),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text('No hay datos de restaurante disponibles.'),
          );
        } else {
          final restaurant = snapshot.data!;
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(5),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Opacity(
                      opacity: 0.9,
                      child: Image.network(
                        restaurant.photo,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: 346,
                      color: const Color.fromARGB(255, 131, 130, 130)
                          .withOpacity(0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                restaurant.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: SizedBox(
                        width: 120,
                        height: 68,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            MapUtils().openMap(restaurant.location.latitude,
                                restaurant.location.longitude);
                          },
                          label: const Text(
                            '¿Cómo llegar?',
                            style: TextStyle(color: Colors.white),
                          ),
                          icon: const Icon(
                            Icons.map_rounded,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(245, 90, 81, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class RestaurantRecommendationsSection extends StatelessWidget {
  final PlateBloc plateBloc;

  const RestaurantRecommendationsSection({
    Key? key,
    required this.plateBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.bottomLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Platos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Manrope',
              ),
              textAlign: TextAlign.left,
            ),
            StreamBuilder(
              stream: plateBloc.categoryPlates,
              builder: (context, AsyncSnapshot<PlateList> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error al cargar los datos del plato'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty()) {
                  return const Center(
                    child: Text('No hay datos de platos disponibles'),
                  );
                } else {
                  final items = snapshot.data?.plates;
                  return GridView.builder(
                    //cacheExtent: 10,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items?.length,
                    itemBuilder: (context, index) {
                      final itemData = items?[index];
                      return ItemWidget(
                        itemData: itemData,
                        restaurantBloc: RestaurantBloc(),
                      );
                    },
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
    required this.restaurantBloc,
  }) : super(key: key);

  final Plate? itemData;
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
    //widget.restaurantBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlateOfferPage(plateId: widget.itemData!.id),
          ),
        );
      },
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
                      radius: 38,
                      backgroundImage: CachedNetworkImageProvider(
                        widget.itemData?.getPhoto ?? '',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.itemData?.name ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Manrope',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${widget.itemData?.price} K',
                      style: const TextStyle(
                        fontSize: 11,
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
      ),
    );
  }
}
