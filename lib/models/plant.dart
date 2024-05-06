//import 'dart:io';
//This is the data model of a plant. 
class Plant{

  //The name of the plant
  String plant_name;

  //When the plant was bought
  DateTime dateTime;

  String? plant_image_path;

  //Constructor
  Plant({required this.plant_name, required this.dateTime, required this.plant_image_path});

  // Convert a Plant into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'id': plant_name,
      'date': dateTime.toString(),
      'img': plant_image_path,
    };
  }

  // Implement toString to make it easier to see information about
  // each plant when using the print statement.
  @override
  String toString() {
    return 'Plant{id: $plant_name, date: $dateTime, img: $plant_image_path}';
  }

}//Plant