import 'package:cloud_firestore/cloud_firestore.dart';

class Plate {
  final String category;
  final String description;
  final bool discount;
  final num id;
  final String name;
  final double offerPrice;
  final String photo;
  final double price;
  final double rating;
  final num restaurant;
  final String type;

  Plate({
    required this.category,
    required this.description,
    required this.discount,
    required this.id,
    required this.name,
    required this.offerPrice,
    required this.photo,
    required this.price,
    required this.rating,
    required this.restaurant,
    required this.type,
  });

  factory Plate.fromJson(Map<String, dynamic> json) {
    return Plate(
      category: json['category'] as String,
      description: json['description'] as String,
      discount: json['inOffer'] as bool,
      id: json['id'] as num,
      name: json['name'] as String,
      offerPrice: (json['offerPrice'] as num).toDouble(),
      photo: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      restaurant: json['restaurantId'] as num,
      type: json['type'] as String,
    );
  }
}

class Restaurant {
  final num id;
  final String name;
  final String photo;
  final GeoPoint location; // Change the type to GeoPoint

  Restaurant({
    required this.id,
    required this.name,
    required this.photo,
    required this.location,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final GeoPoint location =
        json['location'] as GeoPoint; // Change the type here

    return Restaurant(
      id: json['id'] as num,
      name: json['name'] as String,
      photo: json['image'] as String,
      location: location,
    );
  }
}
