import 'dart:async';

import 'package:fud/services/models/plate_model.dart';
import 'package:fud/services/models/restaurant_model.dart';
import 'package:fud/services/resources/firebase_logic.dart';

class Repository {
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
  Future<bool> doesUserExist(String username, String password) =>
      _firebaseProvider.doesUserExist(username, password);

  // PLATES

  /// Fetches a list of plates available as offers.
  Future<PlateList> fetchOfferPlates() =>
      _firebaseProvider.getPlatesOfferFromFirestore();

  /// Fetches the top 3 plates.
  Future<PlateList> fetchTop3Plates() =>
      _firebaseProvider.getPlatesTop3FromFirestore();

  /// Fetches details of a specific plate by its [id].
  Future<Plate?> fetchPlate(num id) => _firebaseProvider.getPlate(id);

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

  // RESTAURANTS

  /// Fetches details of a specific restaurant by its [id].
  Future<Restaurant?> fetchRestaurant(num id) =>
      _firebaseProvider.getPRestaurant(id);

  // ERRORS
  /// Records the app startup time and duration.
  void fetchTime(DateTime now, Duration startTime) =>
      _firebaseProvider.addStartTime(now, startTime);
}
