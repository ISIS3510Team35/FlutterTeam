import 'package:fud/services/models/factories.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorage {
  factory LocalStorage() => _singleton;
  static final LocalStorage _singleton = LocalStorage._internal();
  LocalStorage._internal();

  late final database;
  void init() async {
    database = openDatabase(join(await getDatabasesPath(), 'plates.db'),
        onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE plates(id INTEGER PRIMARY KEY, name TEXT, category TEXT, description TEXT, discount INTEGER, offerPrice REAL, image TEXT, price REAL, rating REAL, restaurantId INTEGER, type TEXT, inOffer INTEGER, restaurant_name TEXT)',
      );
    }, version: 1);
  }

  Future<void> insertPlate(Plate plate) async {
    final db = await database;
    await db.insert(
      'plates',
      plate.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Plate> plate(num id) async {
    final db = await database;
    return Plate.fromJson(
        db.query('plates', where: '"id" = $id') as Map<String, dynamic>);
  }

  Future<List> platesOffer() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('plates', where: '"offerPrice" > 0');
    print(maps);
    return maps;
  }

  Future<List> plates() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('plates');
    print(maps);
    return maps;
  }

  Future<List> bestPlates() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM "plates" ORDER BY "rating" DESC,"price" DESC LIMIT 3',
    );
    return maps;
  }
}
