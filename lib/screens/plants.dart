import 'package:master_planter/models/plantDB.dart';
import 'package:master_planter/screens/plantpage.dart';
import 'package:master_planter/utils/formats.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Plants extends StatelessWidget{
  Plants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //Here we are using a Consumer because we want the UI showing 
        //the list of plants to rebuild every time the plant DB updates.
        child: Consumer<PlantDB>(
          builder: (context, plantDB, child) {
            //If the list of plants is empty, show a simple Text, otherwise show the list of plants using a ListView.
            return plantDB.plants.isEmpty
                ? Text('The plant list is currently empty')
                : ListView.builder(
                    itemCount: plantDB.plants.length,
                    itemBuilder: (context, plantIndex) {
                      //Here, I'm showing to you some new things:
                      //1. We are using the Card widget to wrap each ListTile to make the UI prettier;
                      //2. I'm using DateTime to manage dates;
                      //3. I'm using a custom DateFormats to format the DateTime (take a look at the utils/formats.dart file);
                      //4. Improving UI/UX adding a leading and a trailing to the ListTile
                      return Card(
                        elevation: 5,
                        child: ListTile(
                          leading: Icon(Icons.abc),
                          trailing: Icon(Icons.ac_unit),
                          title:
                              Text('Plant name : ${plantDB.plants[plantIndex].plant_name}'),
                          subtitle: Text('${Formats.fullDateFormatNoSeconds.format(plantDB.plants[plantIndex].dateTime)}'),
                          //When a ListTile is tapped, the user is redirected to the MealPage, where it will be able to edit it.
                          onTap: () => _toPlantPage(context, plantDB, plantIndex),
                        ),
                      );
                    });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(MdiIcons.plus),
        onPressed: () => _toPlantPage(context, Provider.of<PlantDB>(context, listen: false), -1),
      ),
    );
  }
      //Utility method to navigate to PlantPage
  void _toPlantPage(BuildContext context, PlantDB plantDB, int plantIndex) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PlantPage(plantDB: plantDB, plantIndex: plantIndex,)));
  } //_toPlantPage
}