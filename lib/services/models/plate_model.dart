class PlateList {
  List<Plate> _plates = [];

  PlateList();

  /// Creates a PlateList from JSON data.
  PlateList.fromJson(Map<String, dynamic> parsedJson) {
    _plates = List<Plate>.from(
      (parsedJson['results'] as List<dynamic>?)
              ?.map((plateJson) =>
                  Plate.fromJson(plateJson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  List<Plate> get plates => _plates;

  bool isEmpty() {
    return _plates.isEmpty;
  }

  /// Sets the list of plates to a new list.
  void setPlates(List<Plate> newPlates) {
    _plates = newPlates;
  }
}

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

  /// Creates an empty Plate.
  Plate.empty()
      : category = '',
        description = '',
        discount = false,
        id = 0,
        name = '',
        offerPrice = 0.0,
        photo = '',
        price = 0.0,
        rating = 0.0,
        restaurant = 0,
        type = '';

  /// Creates a Plate from JSON data.
  Plate.fromJson(Map<String, dynamic> json)
      : category = json['category'] as String? ?? '',
        description = json['description'] as String? ?? '',
        discount = json['inOffer'] as bool? ?? false,
        id = json['id'] as num? ?? 0,
        name = json['name'] as String? ?? '',
        offerPrice = (json['offerPrice'] as num? ?? 0).toDouble(),
        photo = json['image'] as String? ?? '',
        price = (json['price'] as num? ?? 0).toDouble(),
        rating = (json['rating'] as num? ?? 0).toDouble(),
        restaurant = json['restaurantId'] as num? ?? 0,
        type = json['type'] as String? ?? '';

  /// Creates a Plate from database data.
  Plate.fromDatabase({
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

  /// Converts a Plate to a map for database storage.
  Map<String, dynamic> toDatabaseMap() {
    return {
      'category': category,
      'description': description,
      'discount': discount,
      'id': id,
      'name': name,
      'offerPrice': offerPrice,
      'photo': photo,
      'price': price,
      'rating': rating,
      'restaurant': restaurant,
      'type': type,
    };
  }

  // Getters for each property
  String get getCategory => category;
  String get getDescription => description;
  bool get getDiscount => discount;
  num get getId => id;
  String get getName => name;
  double get getOfferPrice => offerPrice;
  String get getPhoto => photo;
  double get getPrice => price;
  double get getRating => rating;
  num get getRestaurant => restaurant;
  String get getType => type;
}
