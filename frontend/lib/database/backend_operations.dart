import 'package:flutter/material.dart';
import 'package:master_planter/utils/utils_functions.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:master_planter/models/plant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// TODO: Separa db_operations.dart in backend_operations.dart e db_operations.dart

// Potrei provare a implementarlo come provider es.
// class PlantsProvider extends ChangeNotifier{}

final url = Uri.parse('http://192.168.1.169:5034/plants'); // DEVELOPMENT: Change to server URL for production

// A method that retrieves all the plants from the plants table.
Future<List<Plant>> getPlantsFromDb() async {
  List<Plant> plantDB = [];
  // Get a reference to the database.
  final db = await openDatabase(join(await getDatabasesPath(), 'plants_db.db'));

  // Query the table for all the plants.
  final List<Map<String, Object?>> plantMaps = await db.query('plants');

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

  // HTTP TEST
  // final response = await http.get(url);
  // if (response.statusCode == 200) {
  //   // Decodifica la lista JSON delle piante
  //   List<dynamic> plants = jsonDecode(response.body);
  //   print(plants);
  // } else {
  //   throw Exception('Failed to load plants');
  // }

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
  
  try {
    final response = await http.put(
      Uri.parse('$url/${plant.plant_id}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(await plant.toMapBackend()),
    );

    if (response.statusCode == 204) {
      print("Plant upserted to backend!");
      await db.update('plants', {'sync_status': 'synced'},
      where: 'plant_id = ?',
      whereArgs: [plant.plant_id],
      );
      print(await db.query(
      'plants',
      columns: ['sync_status'],
      where: 'plant_id = ?',
      whereArgs: [plant.plant_id],
      ));
    } else {
      print("Errore inserimento: ${response.statusCode} - ${response.body}");
      await db.update('plants', {'sync_status': 'error'},
        where: 'plant_id = ?',
        whereArgs: [plant.plant_id],
      );
    }
  } catch (e) {
    print("Errore di connessione: $e");
  }


}

Future<void> deletePlantFromDB(String plant_id) async {
  // Get a reference to the database.
  final db = await openDatabase(join(await getDatabasesPath(), 'plants_db.db'));

  // Remove the Plant from the database.
  await db.delete(
    'plants',
    // Use a `where` clause to delete a specific plant.
    where: 'plant_id = ?',
    // Pass the Plant's id as a whereArg to prevent SQL injection.
    whereArgs: [plant_id],
  );

  final response = await http.delete(Uri.parse('$url/$plant_id'));
  if (response.statusCode == 204) { // 204 No Content è risposta comune per delete riuscito
    print('Plant deleted from server.');
  }

}

Future<void> changeUsername(String oldUsername, String newUsername) async {
  final response = await http.put(
    Uri.parse('$url/update-username'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'oldUsername': oldUsername,
      'newUsername': newUsername,
    }),
  );

  if (response.statusCode == 200) {
    print('Username updated successfully.');
  } else {
    print('Error: ${response.body}');
  }
}

Future<void> onRefresh(context) async {
  final db = await openDatabase(join(await getDatabasesPath(), 'plants_db.db'));

  final unsyncedPlants = await db.query(
    'plants',
    where: 'sync_status != ?',
    whereArgs: ['synced'],
  );

  int tot_unsynced = unsyncedPlants.length;
  int count = 0;

  if (tot_unsynced == 0) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('All plants are synced with the server.'),
    ));
    return;
  } 

  for (final plant in unsyncedPlants) {
    try {
      final response = await http.put(
        Uri.parse('$url/${plant['plant_id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'PlantId': plant['plant_id'],
          'Username': await getUsernameFromPrefs(),
          'PlantName': plant['plant_name'],
          'DateOfAdoption': plant['date_of_adoption'],
          'PlantLocation': plant['plant_location'],
        }),
      );

      if (response.statusCode == 204 || response.statusCode == 201) {
        print('${plant['plant_name']} synced with server.');
        count += 1;
        await db.update(
          'plants',
          {'sync_status': 'synced'},
          where: 'plant_id = ?',
          whereArgs: [plant['plant_id']],
        );
      } else {
        print('Unable to send ${plant['plant_name']} to server.');
        // lascio sync_status invariato (rimane 'error')
      }
    } catch (e) {
      // errore di connessione → lascio sync_status invariato
      print('Connection error for ${plant['plant_name']}: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Check your connection and try again.'),
      ));
    }
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Synced $count out of $tot_unsynced pending plants.'),
  ));
  print('Synced $count out of $tot_unsynced pending plants.');
}
