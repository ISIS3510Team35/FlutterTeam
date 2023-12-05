import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantList {
  List<Restaurant> _restaurants = [];

  RestaurantList();

  /// Creates a RestaurantList from a list of JSON data.
  RestaurantList.fromJsonList(List<dynamic> restaurantList) {
    _restaurants = restaurantList
        .map((restaurantJson) =>
            Restaurant.fromJson(restaurantJson as Map<String, dynamic>))
        .toList();
  }

  List<Restaurant> get restaurants => _restaurants;

  bool isEmpty() {
    return _restaurants.isEmpty;
  }

  /// Sets the list of restaurants to a new list.
  void setRestaurants(List<Restaurant> newRestaurants) {
    _restaurants = newRestaurants;
  }
}

class Restaurant {
  final num id;
  final String name;
  final String photo;
  final GeoPoint location;

  // Empty constructor
  Restaurant.empty()
      : id = 0,
        name = '',
        photo = '',
        location = const GeoPoint(0, 0);

  Restaurant({
    required this.id,
    required this.name,
    required this.photo,
    required this.location,
  });

  /// Creates a Restaurant from JSON data.
  Restaurant.fromJson(Map<String, dynamic> json)
      : id = json['id'] as num? ?? 0,
        name = json['name'] as String? ?? '',
        photo = json['image'] as String? ?? '',
        location = json['location'] as GeoPoint? ?? const GeoPoint(0, 0);

  /// Creates a Restaurant from database data.
  Restaurant.fromDatabase({
    required this.id,
    required this.name,
    required this.photo,
    required this.location,
  });

  /// Converts a Restaurant to a map for database storage.
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'lat': location.latitude,
      'lon': location.longitude
    };
  }

  // Getters for each property
  num get getId => id;
  String get getName => name;
  String get getPhoto => photo;
  GeoPoint get getLocation => location;
}
