import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getTest() async {
  List test = [];

  CollectionReference collectionReferenceTest = db.collection('Test');
  QuerySnapshot queryTest = await collectionReferenceTest.get();

  for (var element in queryTest.docs) {
    test.add(element.data());
  }

  return test;
}
