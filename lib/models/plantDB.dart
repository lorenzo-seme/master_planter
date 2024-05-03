import 'package:flutter/material.dart';
import 'package:master_planter/models/plant.dart';

//This class extends ChangeNotifier. 
//It will act as data repository for the meals and will be shared thorugh the application.
class PlantDB extends ChangeNotifier{

  //The PlantDB can be represented here as list of plants.
  List<Plant> plants = [];

  //Method to use to add a plant.
  void addPlant(Plant toAdd){
    plants.add(toAdd);
    //Call the notifyListeners() method to alert that something happened.
    notifyListeners();
  }//addPlant

  //Method to use to edit a plantl.
  void editPlant(int index, Plant newMeal){
    plants[index] = newMeal;
    //Call the notifyListeners() method to alert that something happened.
    notifyListeners();
  }//editPlant

  //Method to use to delete a plant.
  void deletePlant(int index){
    plants.removeAt(index);
    //Call the notifyListeners() method to alert that something happened.
    notifyListeners();
  }//deletePlant
  
}//PlantDB