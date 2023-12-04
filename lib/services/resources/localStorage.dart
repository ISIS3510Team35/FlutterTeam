import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fud/services/models/plate_model.dart';
import 'package:fud/services/models/restaurant_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// A class for local storage using SQLite.
class LocalStorage {
  factory LocalStorage() => _singleton;
  static final LocalStorage _singleton = LocalStorage._internal();
  LocalStorage._internal();

  // ignore: prefer_typing_uninitialized_variables
  late final database;

  /// Initializes the local database.
  Future<void> init() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'plates.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE plates(id INTEGER PRIMARY KEY, name TEXT, category TEXT, description TEXT, discount INTEGER, offerPrice REAL, photo TEXT, price REAL, rating REAL, restaurant INTEGER, type TEXT)',
        );
        db.execute(
          'CREATE TABLE restaurants(id INTEGER PRIMARY KEY, name TEXT, photo TEXT, lat REAL, lon REAL)',
        );
      },
      version: 1,
    );
  }

  /// Inserts a [Plate] into the local database.
  Future<void> insertPlate(Plate plate) async {
    final db = await database;
    await db.insert(
      'plates',
      plate.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPlates(Future<PlateList> plateList) async {
    var list = await plateList;
    for (Plate plate in list.plates) {
      insertPlate(plate);
    }
  }

  Future<void> insertRestaurant(Restaurant restaurant) async {
    final db = await database;
    await db.insert(
      'restaurants',
      restaurant.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

    Future<void> insertRestaurants(Future<RestaurantList> restaurants) async {
    final db = await database;
    var list = await restaurants;
    for(Restaurant restaurant in list.restaurants){
    insertRestaurant(restaurant);}
  }

  Future<Restaurant> getRestaurant(num id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('restaurants', where: '"id" = $id');
    return Restaurant(
      id: maps[0]['id'],
      name: maps[0]['name'],
      photo: maps[0]['photo'],
      location: GeoPoint(maps[0]['lat'] as double, maps[0]['lon'] as double),
    );
  }

  Future<RestaurantList> getRestaurantsMostInt(num id1,num id2,num id3) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('restaurants', where: '"id" IN ($id1,$id2,$id3)');
    RestaurantList restaurantList = RestaurantList();
    List<Restaurant> restaurants = List.generate(maps.length, (i) {
      return Restaurant(
      id: maps[i]['id'],
      name: maps[i]['name'],
      photo: maps[i]['photo'],
      location: GeoPoint(maps[i]['lat'] as double, maps[i]['lon'] as double),
    );});
    restaurantList.setRestaurants(restaurants);
    return restaurantList;
  }

  /// Retrieves a [Plate] with the specified [id] from the local database.
  Future<Plate> getPlate(num id) async {
    final db = await database;
    final List<Map<String, dynamic>> q =
        await db.query('plates', where: '"id" = $id');
    var i = 0;
    return Plate(
      id: q[i]['id'] as num,
      name: q[i]['name'] as String,
      category: q[i]['category'] as String,
      description: q[i]['description'] as String,
      discount: (q[i]['discount'] == 0 ? true : false),
      offerPrice: q[i]['offerPrice'] as double,
      photo: q[i]['photo'] as String,
      price: q[i]['price'] as double,
      rating: q[i]['rating'] as double,
      restaurant: q[i]['restaurant'] as num,
      type: q[i]['type'] as String,
    );
  }

  /// Retrieves a list of plates with offer prices from the local database.
  Future<PlateList> getOfferPlates() async {
    final db = await database;
    final List<Map<String, dynamic>> q =
        await db.query('plates', where: 'offerPrice > 0');

    PlateList plateList = PlateList();
    List<Plate> plates = List.generate(q.length, (i) {
      return Plate(
        id: q[i]['id'] as num,
        name: q[i]['name'] as String,
        category: q[i]['category'] as String,
        description: q[i]['description'] as String,
        discount: (q[i]['discount'] == 0 ? true : false),
        offerPrice: q[i]['offerPrice'] as double,
        photo: q[i]['photo'] as String,
        price: q[i]['price'] as double,
        rating: q[i]['rating'] as double,
        restaurant: q[i]['restaurant'] as num,
        type: q[i]['type'] as String,
      );
    });
    plateList.setPlates(plates);
    return plateList;
  }

  /// Retrieves a list of all plates from the local database.
  Future<PlateList> getAllPlates() async {
    final db = await database;
    List<Map<String, Object?>> q = await db.query('plates');
    List<Plate> plates = [];
    q.map((plate) => {plates.add(Plate.fromJson(plate))});
    PlateList plateList = PlateList();
    plateList.setPlates(plates);
    return plateList;
  }

  /// Retrieves a list of the best-rated plates from the local database.
  Future<PlateList> getBestPlates() async {
    final db = await database;
    final List<Map<String, dynamic>> q = await db.rawQuery(
      'SELECT * FROM plates ORDER BY rating DESC, price DESC LIMIT 3',
    );

    PlateList plateList = PlateList();
    List<Plate> plates = List.generate(q.length, (i) {
      return Plate(
        id: q[i]['id'] as num,
        name: q[i]['name'] as String,
        category: q[i]['category'] as String,
        description: q[i]['description'] as String,
        discount: (q[i]['discount'] == 0 ? true : false),
        offerPrice: q[i]['offerPrice'] as double,
        photo: q[i]['photo'] as String,
        price: q[i]['price'] as double,
        rating: q[i]['rating'] as double,
        restaurant: q[i]['restaurant'] as num,
        type: q[i]['type'] as String,
      );
    });
    plateList.setPlates(plates);
    return plateList;
  }

  /// Retrieves a list of plates with a specific category from the local database.
  Future<PlateList> getCategoryPlates(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> q = await db.query('plates',
        where: 'category == \'$category\'', orderBy: 'rating DESC, price DESC');

    PlateList plateList = PlateList();
    List<Plate> plates = List.generate(q.length, (i) {
      return Plate(
        id: q[i]['id'] as num,
        name: q[i]['name'] as String,
        category: q[i]['category'] as String,
        description: q[i]['description'] as String,
        discount: (q[i]['discount'] == 0 ? true : false),
        offerPrice: q[i]['offerPrice'] as double,
        photo: q[i]['photo'] as String,
        price: q[i]['price'] as double,
        rating: q[i]['rating'] as double,
        restaurant: q[i]['restaurant'] as num,
        type: q[i]['type'] as String,
      );
    });
    plateList.setPlates(plates);
    return plateList;
  }

  /// Retrieves a list of plates with a specific category from the local database.
  Future<PlateList> getRestaurantPlates(num id) async {
    final db = await database;
    final List<Map<String, dynamic>> q = await db.query('plates',
        where: 'restaurant == $id', orderBy: 'rating DESC, price DESC');

    PlateList plateList = PlateList();
    List<Plate> plates = List.generate(q.length, (i) {
      return Plate(
        id: q[i]['id'] as num,
        name: q[i]['name'] as String,
        category: q[i]['category'] as String,
        description: q[i]['description'] as String,
        discount: (q[i]['discount'] == 0 ? true : false),
        offerPrice: q[i]['offerPrice'] as double,
        photo: q[i]['photo'] as String,
        price: q[i]['price'] as double,
        rating: q[i]['rating'] as double,
        restaurant: q[i]['restaurant'] as num,
        type: q[i]['type'] as String,
      );
    });
    plateList.setPlates(plates);
    return plateList;
  }

  Future<PlateList> getMinMax(num id) async {
    final db = await database;
    final List<Map<String, dynamic>> q = await db.query('plates',
        where: 'restaurant == $id', orderBy: 'price ASC');

    PlateList plateList = PlateList();
    List<Plate> plates =[];
    plates.add(
       Plate(
        id: q[0]['id'] as num,
        name: q[0]['name'] as String,
        category: q[0]['category'] as String,
        description: q[0]['description'] as String,
        discount: (q[0]['discount'] == 0 ? true : false),
        offerPrice: q[0]['offerPrice'] as double,
        photo: q[0]['photo'] as String,
        price: q[0]['price'] as double,
        rating: q[0]['rating'] as double,
        restaurant: q[0]['restaurant'] as num,
        type: q[0]['type'] as String,
      )
    );
    if(q.length>1){
      plates.add(
       Plate(
        id: q[q.length-1]['id'] as num,
        name: q[q.length-1]['name'] as String,
        category: q[q.length-1]['category'] as String,
        description: q[q.length-1]['description'] as String,
        discount: (q[q.length-1]['discount'] == 0 ? true : false),
        offerPrice: q[q.length-1]['offerPrice'] as double,
        photo: q[q.length-1]['photo'] as String,
        price: q[q.length-1]['price'] as double,
        rating: q[q.length-1]['rating'] as double,
        restaurant: q[q.length-1]['restaurant'] as num,
        type: q[q.length-1]['type'] as String,
      )
    );
    }
    plateList.setPlates(plates);
    return plateList;
  }
}
