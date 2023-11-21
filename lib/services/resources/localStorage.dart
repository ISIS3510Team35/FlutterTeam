import 'package:fud/services/models/plate_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// A class for local storage using SQLite.
class LocalStorage {
  factory LocalStorage() => _singleton;
  static final LocalStorage _singleton = LocalStorage._internal();
  LocalStorage._internal();

  late final Database database;

  /// Initializes the local database.
  Future<void> init() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'plates.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE plates(id INTEGER PRIMARY KEY, name TEXT, category TEXT, description TEXT, discount INTEGER, offerPrice REAL, image TEXT, price REAL, rating REAL, restaurantId INTEGER, type TEXT, inOffer INTEGER, restaurant_name TEXT)',
        );
      },
      version: 1,
    );
  }

  /// Inserts a [Plate] into the local database.
  Future<void> insertPlate(Plate plate) async {
    await database.insert(
      'plates',
      plate.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves a [Plate] with the specified [id] from the local database.
  Future<Plate> getPlate(num id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'plates',
      where: '"id" = ?',
      whereArgs: [id],
    );
    return Plate.fromJson(maps.first);
  }

  /// Retrieves a list of plates with offer prices from the local database.
  Future<List<Map<String, dynamic>>> getOfferPlates() async {
    return database.query('plates', where: '"offerPrice" > 0');
  }

  /// Retrieves a list of all plates from the local database.
  Future<List<Map<String, dynamic>>> getAllPlates() async {
    return database.query('plates');
  }

  /// Retrieves a list of the best-rated plates from the local database.
  Future<List<Map<String, dynamic>>> getBestPlates() async {
    return database.rawQuery(
      'SELECT * FROM "plates" ORDER BY "rating" DESC, "price" DESC LIMIT 3',
    );
  }
}
