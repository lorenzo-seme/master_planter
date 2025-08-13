import 'package:flutter/material.dart';
import 'package:master_planter/models/plant.dart';
import 'package:master_planter/services/local_db_service.dart';
//import 'dart:io';

// e se implementassi qui l'inserimento e l'eliminazione da database?

//This class extends ChangeNotifier. 
//It will act as data repository for the plants and will be shared thorugh the application.
class PlantDB extends ChangeNotifier{

  //The PlantDB can be represented here as list of plants.
  List<Plant> plants = [];

  PlantDB() {_init();}

  Future<void> _init() async {
    plants = await LocalDbService().getPlants();
    notifyListeners();
  }
  //Method to use to add a plant.
  void addPlant(Plant toAdd){
    plants.add(toAdd);
    //Call the notifyListeners() method to alert that something happened.
    notifyListeners();
  }//addPlant

  //Method to use to edit a plantl.
  void editPlant(int index, Plant newPlant){
    plants[index] = newPlant;
    //Call the notifyListeners() method to alert that something happened.
    notifyListeners();
  }//editPlant

  //Method to use to delete a plant.
  void deletePlant(int index){
    plants.removeAt(index);
    //Call the notifyListeners() method to alert that something happened.
    notifyListeners();
  }//deletePlant

/*     //Method to use to add a plant photo.
  void addPlantPhoto(int index, String newPlant){
    plants[index].plant_image_path = newPlant;
    //Call the notifyListeners() method to alert that something happened.
    notifyListeners();
  }//editPlant */
  
}//PlantDB