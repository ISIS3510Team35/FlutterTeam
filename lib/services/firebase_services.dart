import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fud/services/factories.dart';
import 'package:collection/collection.dart';
import 'package:fud/services/gps_service.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
var gps = GPS();

Future<List> getOffer() async {
  List test = [];

  CollectionReference collectionReferenceTest = db.collection('Producto');
  QuerySnapshot queryTest =
      await collectionReferenceTest.where('discount', isEqualTo: true).get();

  for (var element in queryTest.docs) {
    var i, e;
    String name;

    try {
      QuerySnapshot collectionReferenceRest = await db
          .collection('Restaurante')
          .where('id', isEqualTo: element['restaurant'])
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
    CollectionReference collectionReferenceTest = db.collection('Producto');
    QuerySnapshot queryTest =
        await collectionReferenceTest.where('id', isEqualTo: id).get();
    if (queryTest.docs.isNotEmpty) {
      final plateData = queryTest.docs[0].data() as Map<String, dynamic>;
      final plate = Plate.fromJson(plateData);
      return plate;
    } else {
      return null;
      // No matching document found
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error: $e");
    }
    return null; // Handle the error as needed
  }
}

Future<Restaurant?> getRestaurant({required id}) async {
  try {
    CollectionReference collectionReferenceTest = db.collection('Restaurante');
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
    return null; // Handle the error as needed
  }
}
// Autenticación !!!

Future<bool> doesUserExist(String username, String password) async {
  // Query the 'Usuario' collection for a document with the given username and password
  QuerySnapshot querySnapshot = await db
      .collection('Usuario')
      .where('username', isEqualTo: username)
      .where('password', isEqualTo: password)
      .get();

  // Check if any documents match the query
  if (querySnapshot.docs.isNotEmpty) {
    return true; // User with the given username and password exists
  } else {
    return false; // User does not exist or password is incorrect
  }
}

Future<List> getBest() async {
  List test = [];

  CollectionReference collectionReferenceTest = db.collection('Producto');
  QuerySnapshot queryTest = await collectionReferenceTest.get();

  for (var element in queryTest.docs) {
    var i, e;
    String name;

    try {
      QuerySnapshot collectionReferenceRest = await db
          .collection('Restaurante')
          .where('id', isEqualTo: element['restaurant'])
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

Future<Map<String, List>> getFilter(double max_price, bool vegetariano, bool vegano) async {
  List test = [];
  List cont = [''];
  if(vegetariano){
    cont.add('Vegetariano');
  }
  if(vegano){
    cont.add('Vegano');
  }
  if(!vegano && !vegetariano){
    cont.add('Normal');
    cont.add('Vegano');
    cont.add('Vegetariano');
  }
  print(cont);
  await db.collection('Filter_Analytics').add(
    {'Price':max_price!=100.0,
    'Vegano':vegano,
    'Vegetariano':vegetariano}
  );
  QuerySnapshot collectionReferenceTest = await db
    .collection('Producto')
    .where('price', isLessThan: max_price)
    .where('type',whereIn: cont)
    .get();
  
  for (var element in collectionReferenceTest.docs) {
    var i, e;
    String name;
    GeoPoint location;
    String idRestaurant;
    String restaurantPhoto;

    try {
      QuerySnapshot collectionReferenceRest = await db
          .collection('Restaurante')
          .where('id', isEqualTo: element['restaurant'])
          .get();

      if (collectionReferenceRest.docs.isNotEmpty) {
        i = collectionReferenceRest.docs[0].data();
      }

      if (i?.containsKey('name')) {
        name = i['name'];
        location = i['location'];
        idRestaurant = i['id'];
        restaurantPhoto = i['photo'];

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
  print(test);
  test.sort((a, b) => a['distancia'].compareTo(b['distancia']));
  Map<String, List> groupedData =
      groupBy(test, (element) => element['restaurant_id']);

  return groupedData;
}
