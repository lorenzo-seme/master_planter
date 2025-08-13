import 'package:master_planter/services/local_db_service.dart';
import 'package:master_planter/utils/utils_functions.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

// USING SINGLETON PATTERN
class BackendService{
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;

  BackendService._internal();

  final String baseUrl = 'http://192.168.1.169:5034/plants'; // DEVELOPMENT: Change to server URL for production

  Future<void> changeUsername(String oldUsername, String newUsername) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update-username'),
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

  Future<void> sync() async {
    
    final unsyncedPlants = await LocalDbService().getUnsyncedPlants();

    int tot_unsynced = unsyncedPlants.length;
    int count = 0;

    if (tot_unsynced == 0) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Text('All plants are synced with the server.'),
      // ));
      return;
    } 

    for (final plant in unsyncedPlants) {
      String status = plant['sync_status'] as String;

      try {
        final response;
        if (status == 'delete_pending'){
          response = await http.delete(Uri.parse('$baseUrl/${plant['plant_id']}'));
        }
        else {//if (status == 'pending'){
          response = await http.put(
            Uri.parse('$baseUrl/${plant['plant_id']}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'PlantId': plant['plant_id'],
              'Username': await getUsernameFromPrefs(),
              'PlantName': plant['plant_name'],
              'DateOfAdoption': plant['date_of_adoption'],
              'PlantLocation': plant['plant_location'],
            }),
          );
        }
        if (response.statusCode == 204) {
          print('${plant['plant_name']} synced with server. [${status=='pending' ? 'PUT' : 'DELETE'}]');
          count += 1;
          status == 'delete_pending'
            ? 
              await LocalDbService().deletePlant(plant['plant_id'])
            :
              await LocalDbService().setPlantAsSynced(plant['plant_id']);

        } else {
          print('Unable to sync ${plant['plant_name']} with server. [${status=='pending' ? 'PUT' : 'DELETE'}]');
          // lascio sync_status invariato (rimane 'error')
        }
      } catch (e) {
        // errore di connessione → lascio sync_status invariato
        print('Connection error for ${plant['plant_name']}: $e');
      }
    }
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text('Synced $count out of $tot_unsynced pending plants.'),
    // ));
    print('Synced $count out of $tot_unsynced pending plants.');
  }
}