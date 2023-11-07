import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fud/services/factories.dart';
import 'package:collection/collection.dart';
import 'package:fud/services/gps_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

final logger = Logger();

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

Future<void> createFavPromoAnalyticsDocument(bool isPromotion, bool isFavorite,
    RootIsolateToken? rootIsolateToken) async {
  try {
    await runFirebaseIsolateFunction(rootIsolateToken);
    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference favPromoAnalyticsCollection =
        db.collection('Fav_Promo_Analytics');
    int currentDate = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> data = {
      'Date': currentDate,
      'Provider': 'FlutterTeam',
      'promotion': isPromotion,
      'favourite': isFavorite,
    };
    await favPromoAnalyticsCollection.add(data);
    logger.d('Documento creado exitosamente');
  } catch (e) {
    logger.d('Error al crear el documento: $e');
  }
}

Future<List> getOffer(RootIsolateToken? rootIsolateToken) async {
  await runFirebaseIsolateFunction(rootIsolateToken);
  List test = [];
  FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference collectionReferenceTest = db.collection('Product');
  QuerySnapshot queryTest =
      await collectionReferenceTest.where('inOffer', isEqualTo: true).get();

  for (var element in queryTest.docs) {
    var i, e;
    String name;

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
        e = element.data();
        e['restaurant_name'] = name;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }

    test.add(e);
  }

  return test;
}

Future<Plate?> getPlate(
    {required id, RootIsolateToken? rootIsolateToken}) async {
  await runFirebaseIsolateFunction(rootIsolateToken);
  try {
    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference collectionReferenceTest = db.collection('Product');
    QuerySnapshot queryTest =
        await collectionReferenceTest.where('id', isEqualTo: id).get();
    if (queryTest.docs.isNotEmpty) {
      final plateData = queryTest.docs[0].data() as Map<String, dynamic>;
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

Future<Restaurant?> getRestaurant(
    {required id, RootIsolateToken? rootIsolateToken}) async {
  await runFirebaseIsolateFunction(rootIsolateToken);
  try {
    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference collectionReferenceTest = db.collection('Restaurant');
    QuerySnapshot queryTest =
        await collectionReferenceTest.where('id', isEqualTo: id).get();

    if (queryTest.docs.isNotEmpty) {
      final restaurantData = queryTest.docs[0].data() as Map<String, dynamic>;
      final restaurant = Restaurant.fromJson(restaurantData);
      return restaurant;
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
// Autenticación !!!

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

Future<List> getBest(RootIsolateToken? rootIsolateToken) async {
  await runFirebaseIsolateFunction(rootIsolateToken);
  List test = [];
  FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference collectionReferenceTest = db.collection('Product');
  QuerySnapshot queryTest = await collectionReferenceTest.get();

  for (var element in queryTest.docs) {
    var i, e;
    String name;

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
        e = element.data();
        e['restaurant_name'] = name;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }

    test.add(e);
  }

  test.sort((a, b) => b['rating'].compareTo(a['rating']));
  test = test.take(3).toList();

  return test;
}

Future<Map<num, List>> getFilter(double max_price, bool vegetariano,
    bool vegano, RootIsolateToken? rootIsolateToken) async {
  await runFirebaseIsolateFunction(rootIsolateToken);
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

  await db.collection('Filter_Analytics').add({
    'Price': max_price != 100.0,
    'Vegano': vegano,
    'Vegetariano': vegetariano
  });

  // -- Distance with filter

  QuerySnapshot collectionReferenceTest = await db
      .collection('Product')
      .where('price', isLessThan: max_price)
      .where('type', whereIn: cont)
      .get();

  for (var element in collectionReferenceTest.docs) {
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

  //print(test);

  test.sort((a, b) => a['distancia'].compareTo(b['distancia']));

  Map<num, List> groupedData =
      groupBy(test, (element) => element['restaurant_id']);

  return groupedData;
}

Future<bool> addFavourites(
    num plate_id, RootIsolateToken? rootIsolateToken) async {
  await runFirebaseIsolateFunction(rootIsolateToken);
  FirebaseFirestore db = FirebaseFirestore.instance;
  SharedPreferences pref = await SharedPreferences.getInstance();
  int user_id = pref.getInt('user')!;
  QuerySnapshot querySnapshot = await db
      .collection('Favourites')
      .where('product_id', isEqualTo: plate_id)
      .where('user_id', isEqualTo: user_id)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    await db.collection('Favourites').doc(querySnapshot.docs[0].id).delete();
    return false;
  } else {
    await db
        .collection('Favourites')
        .add({'product_id': plate_id, 'user_id': user_id});
    return true;
  }
}

Future<bool> isFavourite(
    num plate_id, RootIsolateToken? rootIsolateToken) async {
  await runFirebaseIsolateFunction(rootIsolateToken);
  SharedPreferences pref = await SharedPreferences.getInstance();
  FirebaseFirestore db = FirebaseFirestore.instance;
  int user_id = pref.getInt('user')!;
  QuerySnapshot querySnapshot = await db
      .collection('Favourites')
      .where('product_id', isEqualTo: plate_id)
      .where('user_id', isEqualTo: user_id)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return true;
  } else {
    return false;
  }
}

Future<List> Favourites(RootIsolateToken? rootIsolateToken) async {
  await runFirebaseIsolateFunction(rootIsolateToken);
  FirebaseFirestore db = FirebaseFirestore.instance;
  SharedPreferences pref = await SharedPreferences.getInstance();
  int user_id = pref.getInt('user')!;
  List fav = [];
  QuerySnapshot querySnapshot = await db
      .collection('Favourites')
      .where('user_id', isEqualTo: user_id)
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    List prod = [];
    for (var fa in querySnapshot.docs) {
      prod.add(fa['product_id']);
    }
    QuerySnapshot collectionProducts =
        await db.collection('Product').where('id', whereIn: prod).get();
    if (collectionProducts.docs.isNotEmpty) {
      for (var element in collectionProducts.docs) {
        var i, e;
        String name;
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
            e = element.data();
            e['restaurant_name'] = name;
          }
        } catch (err) {
          if (kDebugMode) {
            print("Error: $err");
          }
        }
        fav.add(e);
      }
    }
  }
  return fav;
}
