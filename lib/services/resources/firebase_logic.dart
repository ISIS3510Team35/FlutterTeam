import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fud/services/models/plate_model.dart';
import 'package:fud/services/models/restaurant_model.dart';
import 'package:fud/services/resources/firebase_options.dart';
import 'package:fud/services/resources/gps_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

final logger = Logger();

/// Service class for interacting with Firestore.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Make the constructor private
  FirestoreService._();

  // Create a static instance of the class
  static final FirestoreService _instance = FirestoreService._();

  // Provide a global point of access to the instance
  factory FirestoreService() {
    return _instance;
  }

  Future<dynamic> runFirebaseIsolateFunction(
      RootIsolateToken? rootIsolateToken) async {
    final logger = Logger();
    if (rootIsolateToken == null) {
      return Future(() => null);
    }
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.d("runFirebaseIsolateFunction");
  }

  // USERS

  /// Checks if a user with the provided [username] and [password] exists.
  Future<bool> doesUserExist(String username, String password,
      RootIsolateToken? rootIsolateToken) async {
    await runFirebaseIsolateFunction(rootIsolateToken);
    if (rootIsolateToken == null) {
      return Future(() => false);
    }

    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await db
        .collection('User')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      SharedPreferences.getInstance()
          .then((v) => v.setInt('user', querySnapshot.docs[0]['id']));

      return true;
    } else {
      return false;
    }
  }

  Future<bool> changeUserInfo(String newUserName, String newNumber) async {
    var sp = await SharedPreferences.getInstance();
    var user = sp.getString('username');
    QuerySnapshot querySnapshotUser = await _db
        .collection('User')
        .where('id', isEqualTo: sp.getInt('user'))
        .get();
    if (user != newUserName) {
      QuerySnapshot querySnapshot = await _db
          .collection('User')
          .where('username', isEqualTo: newUserName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return false;
      } else {
        _db
            .collection('User')
            .doc(querySnapshotUser.docs[0]['documentId'])
            .update({'number': newNumber});
        sp.setString('number', newNumber);

        _db
            .collection('User')
            .doc(querySnapshotUser.docs[0]['documentId'])
            .update({'username': newUserName});
        sp.setString('username', newUserName);

        return true;
      }
    } else {
      sp.setString('number', newNumber);
      _db
          .collection('User')
          .doc(querySnapshotUser.docs[0]['documentId'])
          .update({'number': newNumber});

      return true;
    }
  }

  Future<bool> deleteAccount() async {
    print('------');
    SharedPreferences pref = await SharedPreferences.getInstance();
    int userId = pref.getInt('user')!;
    QuerySnapshot querySnapshotUser =
        await _db.collection('User').where('id', isEqualTo: userId).get();
    print('------');
    QuerySnapshot querySnapshot = await _db
        .collection('Favourites')
        .where('user_id', isEqualTo: userId)
        .get();

    if (querySnapshotUser.docs.isEmpty) {
      return false;
    } else {
      if (querySnapshot.docs.isNotEmpty) {
        for (var fav in querySnapshot.docs) {
          await _db.collection('Favourites').doc(fav.id).delete();
        }
      }
      await _db.collection('User').doc(querySnapshotUser.docs[0].id).delete();
      return true;
    }
  }

  Future<int?> getNextAvailableId() async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('User')
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        int lastId = querySnapshot.docs[0]['id'];
        // Incrementa el último ID para obtener el próximo ID disponible
        int nextId = lastId + 1;
        return nextId;
      } else {
        // Si no hay documentos en la colección, el próximo ID es 1
        return 1;
      }
    } catch (e) {
      // Maneja errores si es necesario
      logger.d('Error al obtener el próximo ID: $e');
      return null;
    }
  }

  String generateDocumentId(String username, String password) {
    // Concatena el username y password para crear un string único
    String dataToHash = '$username$password';
    // Calcula el hash SHA-256
    var bytes = utf8.encode(dataToHash);
    var hash = sha256.convert(bytes);
    // Convierte el hash a una cadena hexadecimal
    return hash.toString();
  }

  Future<bool> postUser(
      String username, String name, String phone, String password) async {
    try {
      // Obtén el próximo ID disponible
      int? nextId = await getNextAvailableId();
      if (nextId == null) {
        // Maneja el caso de error al obtener el próximo ID
        return Future(() => false);
      }
      logger.d(nextId);
      var documentId = generateDocumentId(username, password);
      logger.d(documentId);
      // Validación de datos
      if (username.isNotEmpty &&
          password.isNotEmpty &&
          name.isNotEmpty &&
          phone.isNotEmpty) {
        logger.d("Pasó filtros de isNotEmpty");
        // Creating a Map containing analytics data
        Map<String, dynamic> data = {
          'documentId': documentId,
          'id': nextId,
          'name': name,
          'phone': int.parse(phone),
          'password': password,
          'username': username,
        };
        await _db.collection('User').add(data);
        logger.d("User agregado");
        // Operación exitosa
        return true;
      } else {
        // Datos incompletos, operación fallida
        return false;
      }
    } catch (error) {
      // Manejar errores de Firestore
      if (kDebugMode) {
        print("Error: $error");
      }
      logger.e("Error al agregar usuario a Firestore: $error");
      return false;
    }
  }

  // RESTAURANT

  /// Fetches details of a specific restaurant by its [id].
  Future<Restaurant?> getPRestaurant(num id) async {
    try {
      QuerySnapshot querySnapshot =
          await _db.collection('Restaurant').where('id', isEqualTo: id).get();

      if (querySnapshot.docs.isNotEmpty) {
        final plateData = querySnapshot.docs[0].data() as Map<String, dynamic>;
        final plate = Restaurant.fromJson(plateData);
        return plate;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }

      return null;
    }
  }

  // PLATES

  /// Fetches a list of plates available as offers.
  Future<PlateList> getPlatesOfferFromFirestore() async {
    QuerySnapshot querySnapshot = await _db
        .collection('Product')
        .where('inOffer', isEqualTo: true)
        .orderBy('price', descending: true)
        .get();

    List<Plate> plates = querySnapshot.docs.map((documentSnapshot) {
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        return Plate.fromJson(data);
      } else {
        return Plate.empty();
      }
    }).toList();

    PlateList plateList = PlateList();
    plateList.setPlates(plates);

    return plateList;
  }

  /// Fetches the top 3 plates.
  Future<PlateList> getPlatesTop3FromFirestore() async {
    QuerySnapshot querySnapshot = await _db
        .collection('Product')
        .orderBy('rating', descending: true)
        .orderBy('price', descending: true)
        .limit(3)
        .get();

    List<Plate> plates = querySnapshot.docs.map((documentSnapshot) {
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        return Plate.fromJson(data);
      } else {
        return Plate.empty();
      }
    }).toList();

    PlateList plateList = PlateList();
    plateList.setPlates(plates);

    return plateList;
  }

  /// Fetches details of a specific plate by its [id].
  Future<Plate?> getPlate(num id) async {
    try {
      QuerySnapshot querySnapshot =
          await _db.collection('Product').where('id', isEqualTo: id).get();

      if (querySnapshot.docs.isNotEmpty) {
        final plateData = querySnapshot.docs[0].data() as Map<String, dynamic>;
        final plate = Plate.fromJson(plateData);
        return plate;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }

      return null;
    }
  }

  /// Checks if a plate with the specified [id] is marked as a favorite.
  Future<bool> isFavourite(num plateId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int userId = pref.getInt('user')!;
    QuerySnapshot querySnapshot = await _db
        .collection('Favourites')
        .where('product_id', isEqualTo: plateId)
        .where('user_id', isEqualTo: userId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  /// Adds or removes a plate with the specified [id] to/from favorites.
  Future<bool> addFavourites(num plateId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int userId = pref.getInt('user')!;
    QuerySnapshot querySnapshot = await _db
        .collection('Favourites')
        .where('product_id', isEqualTo: plateId)
        .where('user_id', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await _db.collection('Favourites').doc(querySnapshot.docs[0].id).delete();
      return false;
    } else {
      await _db
          .collection('Favourites')
          .add({'product_id': plateId, 'user_id': userId});
      return true;
    }
  }

  /// Fetches a list of favorite plates for the current user.
  Future<PlateList> listFavorities() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int userId = pref.getInt('user')!;
    List<Plate> favPlates = [];

    QuerySnapshot querySnapshot = await _db
        .collection('Favourites')
        .where('user_id', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      List prodIds = querySnapshot.docs.map((i) => i['product_id']).toList();

      QuerySnapshot collectionProducts =
          await _db.collection('Product').where('id', whereIn: prodIds).get();

      if (collectionProducts.docs.isNotEmpty) {
        for (var element in collectionProducts.docs) {
          var e = element.data() as Map<String, dynamic>;
          favPlates.add(Plate.fromJson(e));
        }
      }
    }

    PlateList plateList = PlateList();
    plateList.setPlates(favPlates);

    return plateList;
  }

  Future<void> createFavPromoAnalyticsDocument(
    bool isPromotion,
    bool isFavorite,
  ) async {
    try {
      // Creating a Map containing analytics data
      Map<String, dynamic> data = {
        'Date': DateTime.now().millisecondsSinceEpoch,
        'Provider': 'FlutterTeam',
        'promotion': isPromotion,
        'favourite': isFavorite,
      };

      // Adding the data to the Firestore collection 'Fav_Promo_Analytics'
      await _db.collection('Fav_Promo_Analytics').add(data);
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  /// Fetches filter information based on maxPrice, vegetariano, and vegano.
  Future<Map<num, List>> getFilter(
    double maxPrice,
    bool vegetariano,
    bool vegano,
  ) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    List test = [];
    List cont = [''];
    if (vegetariano) {
      cont.add('Vegetariano');
    }
    if (vegano) {
      cont.add('Vegano');
    }
    if (!vegano && !vegetariano) {
      cont.add('Normal');
      cont.add('Vegano');
      cont.add('Vegetariano');
    }

    SharedPreferences pref = await SharedPreferences.getInstance();
    int userId = pref.getInt('user')!;

    await db.collection('Filter_Analytics').add({
      'Price': maxPrice != 100.0,
      'Vegano': vegano,
      'Vegetariano': vegetariano,
      'idUser': userId,
      'limitPrice': maxPrice
    });

    // -- Distance with filter

    QuerySnapshot collectionReferenceTest = await db
        .collection('Product')
        .where('price', isLessThan: maxPrice)
        .where('type', whereIn: cont)
        .get();

    for (var element in collectionReferenceTest.docs) {
      // ignore: prefer_typing_uninitialized_variables
      var i, e;
      String name;
      GeoPoint location;
      num idRestaurant;
      String restaurantPhoto;
      var gps = GPS();
      try {
        QuerySnapshot collectionReferenceRest = await db
            .collection('Restaurant')
            .where('id', isEqualTo: element['restaurantId'])
            .get();

        if (collectionReferenceRest.docs.isNotEmpty) {
          i = collectionReferenceRest.docs[0].data();
        }

        if (i?.containsKey('name')) {
          name = i['name'];
          location = i['location'];
          idRestaurant = i['id'];
          restaurantPhoto = i['image'];

          e = element.data();
          e['restaurant_name'] = name;
          e['restaurant_id'] = idRestaurant;
          e['restaurant_photo'] = restaurantPhoto;
          e['restaurant_location'] = location;

          double latRes = location.latitude;
          double longRes = location.longitude;

          double latNow = gps.getLat();
          double longNow = gps.getLong();

          double dist = calculateDistance(latNow, latRes, longNow, longRes);
          e['distancia'] = dist;
        }
      } catch (e) {
        if (kDebugMode) {
          print('No hay elementos con la condición dada');
        }
      }

      test.add(e);
    }

    test.sort((a, b) => a['distancia'].compareTo(b['distancia']));

    Map<num, List> groupedData =
        groupBy(test, (element) => element['restaurant_id']);

    groupedData.forEach((key, value) {
      groupedData[key] = value.take(3).toList();
    });

    return groupedData;
  }

  Future<PlateList> listRecimendations() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int userId = pref.getInt('user')!;

    QuerySnapshot querySnapshot = await _db
        .collection('Filter_Analytics')
        .where('idUser', isEqualTo: userId)
        .get();

    int priceCount = 0;
    num totalPrices = 0;

    for (var document in querySnapshot.docs) {
      if (document['Price'] == true && document['limitPrice'] != null) {
        var limitPrice = document['limitPrice'];

        if (limitPrice is num) {
          totalPrices += limitPrice;
          priceCount++;
        }
      }
    }

    num averagePrice = priceCount > 0 ? totalPrices / priceCount : 0.0;
    int veganCount = querySnapshot.docs
        .where((document) => document['Vegano'] == true)
        .length;

    int vegetarianCount = querySnapshot.docs
        .where((document) => document['Vegetariano'] == true)
        .length;

    String highestCategory;

    if (priceCount >= veganCount && priceCount >= vegetarianCount) {
      highestCategory = 'Price';
    } else if (veganCount >= priceCount && veganCount >= vegetarianCount) {
      highestCategory = 'Vegano';
    } else {
      highestCategory = 'Vegetariano';
    }

    QuerySnapshot collectionReferenceTest;

    if (highestCategory == 'Vegano' || highestCategory == 'Vegetariano') {
      collectionReferenceTest = await _db
          .collection('Product')
          .where('type', whereIn: [highestCategory]).get();
    } else {
      collectionReferenceTest = await _db
          .collection('Product')
          .where('price', isLessThan: averagePrice)
          .get();
    }

    List<Plate> plates = collectionReferenceTest.docs.map((documentSnapshot) {
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        return Plate.fromJson(data);
      } else {
        return Plate.empty();
      }
    }).toList();

    PlateList plateList = PlateList();
    plateList.setPlates(plates);

    return plateList;
  }

  /// Fetches a list of plates available as offers.
  Future<PlateList> getPlatesCategoryOrRestaurant(
      String category, num idR) async {
    QuerySnapshot querySnapshot;

    if (idR == 0) {
      querySnapshot = await _db
          .collection('Product')
          .where('category', isEqualTo: category)
          .orderBy('rating', descending: true)
          .orderBy('price', descending: true)
          .get();
    } else {
      querySnapshot = await _db
          .collection('Product')
          .where('restaurantId', isEqualTo: idR)
          .orderBy('rating', descending: true)
          .orderBy('price', descending: true)
          .get();
    }

    List<Plate> plates = querySnapshot.docs.map((documentSnapshot) {
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        return Plate.fromJson(data);
      } else {
        return Plate.empty();
      }
    }).toList();

    PlateList plateList = PlateList();
    plateList.setPlates(plates);

    return plateList;
  }

  // ERRORES

  /// Records the app startup time and duration.
  void addStartTime(DateTime now, Duration startTime) async {
    // Truncate the time to the beginning of the day
    DateTime truncatedTime = DateTime(now.year, now.month, now.day);

    // Reference to the 'StartingTime' collection
    CollectionReference startingTimeCollection =
        FirebaseFirestore.instance.collection('StartingTime');

    // Prepare the data to be added
    Map<String, dynamic> startTimeData = {
      'Date': truncatedTime.millisecondsSinceEpoch,
      'Now': now.millisecondsSinceEpoch,
      'provider': 'FlutterTeam',
      'time': startTime.inMilliseconds,
    };

    // Add the data to the collection
    await startingTimeCollection.add(startTimeData);
  }

  // ERRORES

  /// Records the app startup time and duration.
  void addDayTime(DateTime now) async {
    // Truncate the time to the beginning of the day
    int currentHour = now.hour;
    String dayOfWeek = getDayOfWeek(now.weekday);

    // Reference to the 'StartingTime' collection
    CollectionReference startingTimeCollection =
        FirebaseFirestore.instance.collection('Date_Time_Analysis');

    // Prepare the data to be added
    Map<String, dynamic> startTimeData = {
      'Day': dayOfWeek,
      'Hour': currentHour,
    };

    // Add the data to the collection
    await startingTimeCollection.add(startTimeData);
  }

  String getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}
