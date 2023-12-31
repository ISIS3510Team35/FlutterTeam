// ignore_for_file: avoid_print

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fud/services/models/plate_model.dart';
import 'package:fud/services/models/restaurant_model.dart';
import 'package:fud/services/resources/firebase_logic.dart';
import 'package:fud/services/resources/localStorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repository {
  final localStorage = LocalStorage();
  final FirestoreService _firebaseProvider = FirestoreService();

  // Make the constructor private
  Repository._();

  // Create a static instance of the class
  static final Repository _instance = Repository._();

  // Provide a global point of access to the instance
  factory Repository() {
    return _instance;
  }

  // USERS

  /// Checks if a user with the provided [username] and [password] exists.
  Future<bool> doesUserExist(String username, String password) async {
    return _firebaseProvider.doesUserExist(username, password);
  }

  Future<bool> changeUserInfo(String newUserName, String newNumber) {
    return _firebaseProvider.changeUserInfo(newUserName, newNumber);
  }

  Future<bool> addUser(
          String username, String name, String phone, String password) =>
      _firebaseProvider.postUser(username, name, phone, password);

  Future<bool> doesOnlyUserExist(String username) =>
      _firebaseProvider.doesOnlyUserExist(username);

  Future<bool> changePassword(String username, String newPassword) =>
      _firebaseProvider.updatePassword(username, newPassword);

  Future<bool> deleteInfo() {
    return _firebaseProvider.deleteAccount();
  }

  Future<bool> addTimeView(int duration, String view) =>
      _firebaseProvider.postDuration(duration, view);
  // PLATES

  /// Fetches a list of plates available as offers.
  Future<PlateList> fetchOfferPlates() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      var r = _firebaseProvider.getPlatesOfferFromFirestore();
      localStorage.insertPlates(r);
      return r;
    } else {
      return localStorage.getOfferPlates();
    }
  }

  /// Fetches the top 3 plates.
  Future<PlateList> fetchTop3Plates() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      var r = _firebaseProvider.getPlatesTop3FromFirestore();
      localStorage.insertPlates(r);
      return r;
    } else {
      return localStorage.getBestPlates();
    }
  }

  /// Fetches details of a specific plate by its [id].
  Future<Plate?> fetchPlate(num id) async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult != ConnectivityResult.none) {
      var r = _firebaseProvider.getPlate(id);
      localStorage.insertPlate((await r) as Plate);
      return r;
    } else {
      return localStorage.getPlate(id);
    }
  }

  /// Checks if a plate with the specified [id] is marked as a favorite.
  Future<bool> fetchIsFavorite(num id) => _firebaseProvider.isFavourite(id);

  /// Adds or removes a plate with the specified [id] to/from favorites.
  Future<bool> fetchAddRemoveFavorite(num id) =>
      _firebaseProvider.addFavourites(id);

  /// Fetches the list of favorite plates.
  Future<PlateList> fetchFavorites() => _firebaseProvider.listFavorities();

  /// Fetches analytic data for favorite promotions.
  Future<void> fetchAnalyticFavorite(bool isPromotion, bool isFavorite) =>
      _firebaseProvider.createFavPromoAnalyticsDocument(
          isPromotion, isFavorite);

  /// Fetches filter information based on maxPrice, vegetariano, and vegano.
  Future<Map<num, List>> fetchFilterInfo(
          double maxPrice, bool vegetariano, bool vegano) =>
      _firebaseProvider.getFilter(maxPrice, vegetariano, vegano);

  /// Fetches recomendations based on maxPrice, vegetariano, and vegano.
  Future<PlateList> fetchRecomendations() =>
      _firebaseProvider.listRecimendations();

  Future<PlateList> fetchPlatesCategoryOrRestaurant(
      String category, num idR) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      var r = _firebaseProvider.getPlatesCategoryOrRestaurant(category, idR);
      localStorage.insertPlates(r);
      return r;
    } else {
      if (idR == 0) {
        return localStorage.getCategoryPlates(category);
      } else {
        return localStorage.getRestaurantPlates(idR);
      }
    }
  }

  Future<PlateList> fetchMinMaxPrice(num restaurant) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      var r = _firebaseProvider.fetchMinMaxPrice(restaurant);
      localStorage.insertPlates(r);
      print(r);
      return r;
    } else {
      return localStorage.getMinMax(restaurant);
    }
  }
  // RESTAURANTS

  /// Fetches details of a specific restaurant by its [id].
  Future<Restaurant?> fetchRestaurant(num id) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      var r = _firebaseProvider.getPRestaurant(id);
      localStorage.insertRestaurant((await r) as Restaurant);
      return r;
    } else {
      return localStorage.getRestaurant(id);
    }
  }

  Future<RestaurantList?> fetchRestaurantMostInteracted() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      var r = _firebaseProvider.getMostInteracted();
      localStorage.insertRestaurants(r);
      return r;
    } else {
      var sp = await SharedPreferences.getInstance();
      int? id1 = sp.getInt('mostInteracted1');
      int? id2 = sp.getInt('mostInteracted2');
      int? id3 = sp.getInt('mostInteracted3');
      return localStorage.getRestaurantsMostInt(
          id1 as num, id2 as num, id3 as num);
    }
  }

  Future<void> addInteraction(num id) async {
    _firebaseProvider.addInteraction(id);
  }

  // ERRORS
  /// Records the app startup time and duration.
  void fetchTime(DateTime now, Duration startTime) =>
      _firebaseProvider.addStartTime(now, startTime);

  void fetchDayTime(DateTime now) => _firebaseProvider.addDayTime(now);
}
