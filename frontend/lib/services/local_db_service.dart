import 'package:path/path.dart';
import 'package:master_planter/models/plant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

// USING SINGLETON PATTERN
class LocalDbService{
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;

  LocalDbService._internal();

  Database? _db;

  Future<void> initDb() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'plants_db.db'),
      onCreate: (db, version) async {
        // Together with the creation of the database, we also assign a default username
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', 'anonymous${Uuid().v4()}');

        return db.execute(
        'CREATE TABLE plants(plant_id TEXT PRIMARY KEY, plant_name TEXT, date_of_adoption TEXT, plant_location TEXT, img TEXT, sync_status TEXT)',
      );
      },
      version: 1,
    );
  }

  Future<List<Plant>> getPlants() async {
    List<Plant> plantDB = [];

    // Query the table for all the plants.
    final List<Map<String, Object?>> plantMaps = await _db!.query('plants');

    // Convert the list of each plant's fields into a list of `Plant` objects.
    for (final {
          'plant_id': plant_id as String,
          'plant_name': plant_name as String,
          'date_of_adoption': date as String,
          'plant_location': plant_location as String,
          'img': img as String,
          'sync_status': sync_status as String,
        } in plantMaps){
      plantDB.add(Plant(plant_id: plant_id, plant_name: plant_name, date_of_adoption: DateTime.parse(date), plant_location: plant_location, plant_image_path: img, sync_status: sync_status));
    }

    return plantDB;
  }

  Future<void> insertPlant(Plant plant) async {
    // Insert the Plant into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same plant is inserted twice.
    //
    // In this case, replace any previous data.
    await _db!.insert(
      'plants',
      plant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
  }

  Future<void> markPlantAsDeletePending(String plant_id) async {
    // Remove the Plant from the database.
    await _db!.update(
      'plants',
      {'sync_status': 'delete_pending'}, // Mark as deleted
      // Use a `where` clause to delete a specific plant.
      where: 'plant_id = ?',
      // Pass the Plant's id as a whereArg to prevent SQL injection.
      whereArgs: [plant_id],
    );

  }

  Future<void> deletePlant(String plant_id) async {
    await _db!.delete(
                'plants',
                where: 'plant_id = ?',
                whereArgs: [plant_id],
              );

  }

  Future<void> setPlantAsSynced(String plant_id) async {
    await _db!.update(
                'plants',
                {'sync_status': 'synced'},
                where: 'plant_id = ?',
                whereArgs: [plant_id],
              );

  }

  Future<List<Map<String, dynamic>>> getUnsyncedPlants() async {
      return await _db!.query(
        'plants',
        where: 'sync_status != ?',
        whereArgs: ['synced'],
      );
  }
}