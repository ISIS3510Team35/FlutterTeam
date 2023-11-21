import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fud/services/models/plate_model.dart';
import 'package:fud/services/models/restaurant_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class for interacting with Firestore.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USERS

  /// Checks if a user with the provided [username] and [password] exists.
  Future<bool> doesUserExist(String username, String password) async {
    QuerySnapshot querySnapshot = await _db
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

  // RESTAURANT

  /// Fetches details of a specific restaurant by its [id].
  Future<Restaurant?> getPRestaurant(num id) async {
    try {
      QuerySnapshot queryTest =
          await _db.collection('Restaurant').where('id', isEqualTo: id).get();
      if (queryTest.docs.isNotEmpty) {
        final plateData = queryTest.docs[0].data() as Map<String, dynamic>;
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
      QuerySnapshot queryTest =
          await _db.collection('Product').where('id', isEqualTo: id).get();
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
}
