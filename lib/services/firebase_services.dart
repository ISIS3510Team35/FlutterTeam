import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fud/services/factories.dart';
import 'package:collection/collection.dart';
import 'package:fud/services/gps_service.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
var gps = GPS();

Future<List> getOffer() async {
  List test = [];

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

Future<Plate?> getPlate({required id}) async {
  try {
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

Future<Restaurant?> getRestaurant({required id}) async {
  try {
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

Future<bool> doesUserExist(String username, String password) async {
  QuerySnapshot querySnapshot = await db
      .collection('User')
      .where('username', isEqualTo: username)
      .where('password', isEqualTo: password)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return true;
  } else {
    return false;
  }
}

Future<List> getBest() async {
  List test = [];

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

Future<Map<num, List>> getFilter(
    double max_price, bool vegetariano, bool vegano) async {
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
