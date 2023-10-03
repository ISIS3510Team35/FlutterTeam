import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getTest() async {
  List test = [];

  CollectionReference collectionReferenceTest = db.collection('Usuario');
  QuerySnapshot queryTest = await collectionReferenceTest.get();

  for (var element in queryTest.docs) {
    test.add(element.data());
  }

  return test;
}

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
        e['restaurant'] = name;
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

// Autenticación !!!

Future<bool> doesUserExist(String username, String password) async {
  // Initialize Firebase Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  print(password);
  print(username);

  // Query the 'Usuario' collection for a document with the given username and password
  QuerySnapshot querySnapshot = await firestore
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
