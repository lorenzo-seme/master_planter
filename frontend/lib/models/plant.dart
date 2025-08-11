//import 'dart:io';
import 'package:master_planter/utils/utils_functions.dart';
import 'package:uuid/uuid.dart';

//This is the data model of a plant. 
class Plant{

  String plant_id; //The id of the plant, used as primary key in the database

  //The name of the plant
  String plant_name;

  //When the plant was bought
  DateTime date_of_adoption;

  String? plant_image_path;
  
  String plant_location;

  String sync_status; // Status of the plant in the database, used to track synchronization with the server

  //Constructor
  Plant({
    String? plant_id,
    required this.plant_name,
    required this.date_of_adoption,
    this.plant_location = 'unknown',
    this.plant_image_path,
    this.sync_status = 'pending',
    }) : plant_id = plant_id ?? Uuid().v4();

  // Convert a Plant into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'plant_id': plant_id,
      'plant_name': plant_name,
      'date_of_adoption': date_of_adoption.toString(),
      'plant_location': plant_location,
      'img': plant_image_path,
      'sync_status': sync_status,
    };
  }

  Future<Map<String, Object?>> toMapBackend() async {

    return {
      'PlantId': plant_id.toString(),
      'Username': await getUsernameFromPrefs(),
      'PlantName': plant_name,
      'DateOfAdoption': date_of_adoption.toString(),
      'PlantLocation': plant_location,
    };
  }

  // Implement toString to make it easier to see information about
  // each plant when using the print statement.
  @override
  String toString() {
    return 'Plant{plant_id: $plant_id, plant_name: $plant_name, date_of_adoption: $date_of_adoption, plant_location: $plant_location, img: $plant_image_path, sync_status: $sync_status}';
  }

}//Plant