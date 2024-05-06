//import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:master_planter/models/plantDB.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:master_planter/models/plant.dart';

// Potrei provare a implementarlo come provider es.
// class PlantsProvider extends ChangeNotifier{}

// A method that retrieves all the dogs from the dogs table.
Future<PlantDB> getPlantsFromDb() async {
  PlantDB plantDB = PlantDB();
  // Get a reference to the database.
  final db = await openDatabase(join(await getDatabasesPath(), 'plants_db.db'));

  // Query the table for all the dogs.
  final List<Map<String, Object?>> plantMaps = await db.query('plants');

  // Convert the list of each dog's fields into a list of `Dog` objects.
  for (final {
        'id': id as String,
        'date': date as String,
        'img': img as String,
      } in plantMaps){
    plantDB.addPlant(Plant(plant_name: id, dateTime: DateTime.parse(date), plant_image_path: img));
  }

  return plantDB;
}

Future<void> insertPlantIntoDB(Plant plant) async {
  // Get a reference to the database.
  final db = await openDatabase(join(await getDatabasesPath(), 'plants_db.db'));

  // Insert the Dog into the correct table. You might also specify the
  // `conflictAlgorithm` to use in case the same dog is inserted twice.
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

  // Remove the Dog from the database.
  await db.delete(
    'plants',
    // Use a `where` clause to delete a specific dog.
    where: 'id = ?',
    // Pass the Dog's id as a whereArg to prevent SQL injection.
    whereArgs: [name],
  );
}
