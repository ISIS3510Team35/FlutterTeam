import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fud/services/blocs/plate_bloc.dart';
import 'package:fud/services/blocs/restaurant_bloc.dart';
import 'package:fud/services/models/plate_model.dart';
import 'package:fud/services/models/restaurant_model.dart';
import 'package:fud/services/resources/google_maps.dart';
import 'package:fud/services/blocs/user_bloc.dart';

class PlateOfferPage extends StatefulWidget {
  static const routeName = '/PlateOffer';

  final num plateId;

  const PlateOfferPage({
    Key? key,
    required this.plateId,
  }) : super(key: key);

  @override
  State<PlateOfferPage> createState() => _PlateOfferPageState();
}

class _PlateOfferPageState extends State<PlateOfferPage> {
  late PlateBloc plateBloc;
  late RestaurantBloc restaurantBloc;
  late DateTime entryTime;
  final UserBloc _userBloc = UserBloc();

  @override
  void initState() {
    super.initState();
    entryTime = DateTime.now();
    plateBloc = PlateBloc();
    restaurantBloc = RestaurantBloc();
    plateBloc.fetchPlate(widget.plateId);
  }

  @override
  void dispose() async {
    // Calcular la duración al salir de la vista
    Duration duration = DateTime.now().difference(entryTime);

    // Enviar la duración a Firebase o realizar cualquier acción necesaria
    _userBloc.timeView(duration.inMilliseconds, 'Product Screen');

    plateBloc.dispose();
    restaurantBloc.dispose();
    //_userBloc.dispose();

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
        title: const Text("Detail"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: StreamBuilder<Plate>(
        stream: plateBloc.idPlate,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Plate plate = snapshot.data!;
            restaurantBloc.fetchRestaurantDetails(plate.restaurant);
            restaurantBloc.addInteraction(plate.restaurant);

            return StreamBuilder<Restaurant>(
              stream: restaurantBloc.restaurantDetails,
              builder: (context, restaurantSnapshot) {
                if (restaurantSnapshot.hasData) {
                  Restaurant restaurant = restaurantSnapshot.data!;
                  return ListView(
                    children: [
                      ImageWithCaptionSection(imageUrl: plate.photo),
                      OneCardSection(plate: plate, restaurant: restaurant),
                      //const OthersSection(),
                    ],
                  );
                } else if (restaurantSnapshot.hasError) {
                  return const Text(
                      "Error al cargar los datos del restaurante");
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          } else if (snapshot.hasError) {
            return const Text("Error al cargar los datos del plato");
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class ImageWithCaptionSection extends StatelessWidget {
  final String imageUrl;

  const ImageWithCaptionSection({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Opacity(
            opacity: 0.9,
            child: CachedNetworkImage(
              key: UniqueKey(),
              imageUrl: imageUrl,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
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
  final Plate plate;
  final Restaurant restaurant;

  const OneCardSection({
    Key? key,
    required this.plate,
    required this.restaurant,
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
                plate.name,
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
                plate.rating.toString(),
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
            restaurant.name,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 0),
          Text(
            '${plate.price} K',
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
                    plate.description,
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
          ),
          ButtonRow(
            latitude: restaurant.location.latitude,
            longitude: restaurant.location.longitude,
            idPlate: plate.id,
          ),
        ],
      ),
    );
  }
}

class ButtonRow extends StatefulWidget {
  final double latitude;
  final double longitude;
  final num idPlate;

  const ButtonRow({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.idPlate,
  }) : super(key: key);

  @override
  State<ButtonRow> createState() => _ButtonRow();
}

class _ButtonRow extends State<ButtonRow> {
  late PlateBloc plateBloc;
  String favourite = 'Añadir a favoritos';
  bool fav = false;

  @override
  void initState() {
    super.initState();
    plateBloc = PlateBloc();
    plateBloc.fetchIsFavorite(widget.idPlate);
  }

  @override
  void dispose() {
    //plateBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: plateBloc.isFav,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          fav = snapshot.data!;
          favourite = fav ? 'Eliminar favorito' : 'Añadir a favoritos';
        } else if (snapshot.hasError) {
          favourite = 'No hay conexión';
        } else {
          favourite = 'Cargando';
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 135,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  plateBloc.fetchAddRemoveFavorite(widget.idPlate);
                },
                label: Text(
                  favourite,
                  style: const TextStyle(color: Colors.white),
                ),
                icon: fav
                    ? const Icon(
                        Icons.favorite,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
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
                  MapUtils().openMap(widget.latitude, widget.longitude);
                },
                label: const Text(
                  '¿Cómo llegar?',
                  style: TextStyle(color: Colors.white),
                ),
                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
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
      },
    );
  }
}
