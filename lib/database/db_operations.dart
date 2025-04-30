import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:master_planter/models/plant.dart';

// Potrei provare a implementarlo come provider es.
// class PlantsProvider extends ChangeNotifier{}

// A method that retrieves all the plants from the plants table.
Future<List<Plant>> getPlantsFromDb() async {
  List<Plant> plantDB = [];
  // Get a reference to the database.
  final db = await openDatabase(join(await getDatabasesPath(), 'plants_db.db'));

  // Query the table for all the plants.
  final List<Map<String, Object?>> plantMaps = await db.query('plants');

  // Convert the list of each plant's fields into a list of `Plant` objects.
  for (final {
        'id': id as String,
        'date': date as String,
        'img': img as String,
      } in plantMaps){
    plantDB.add(Plant(plant_name: id, dateTime: DateTime.parse(date), plant_image_path: img));
  }

  return plantDB;
}

Future<void> insertPlantIntoDB(Plant plant) async {
  // Get a reference to the database.
  final db = await openDatabase(join(await getDatabasesPath(), 'plants_db.db'));

  // Insert the Plant into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same plant is inserted twice.
  //
  // In this case, replace any previous data.
  await db.insert(
    'plants',
    plant.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> deletePlantFromDB(String name) async {
  // Get a reference to the database.
  final db = await openDatabase(join(await getDatabasesPath(), 'plants_db.db'));

  // Remove the Plant from the database.
  await db.delete(
    'plants',
    // Use a `where` clause to delete a specific plant.
    where: 'id = ?',
    // Pass the Plant's id as a whereArg to prevent SQL injection.
    whereArgs: [name],
  );
}
