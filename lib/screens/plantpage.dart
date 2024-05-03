import 'package:flutter/material.dart';
import 'package:master_planter/models/plantDB.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:master_planter/models/plant.dart';
import 'package:master_planter/widgets/formTiles.dart';
import 'package:master_planter/widgets/formSeparator.dart';
import 'package:master_planter/utils/formats.dart';

//This is the class that implement the page to be used to edit existing plants and add new plants.
//This is a StatefulWidget since it needs to rebuild when the form fields change.
class PlantPage extends StatefulWidget {

  //PlantPage needs to know the index of the plant we are editing (it is equal to -1 if the plant is new)
  final int plantIndex;
  //For simplicity, even if it is not necessary, we are also passing the instance of PlantDB. 
  //This choice is not mandatory and maybe redundant, but it will allow us to initialize easily the form values.
  final PlantDB plantDB;

  //PlantPage constructor
  PlantPage({Key? key, required this.plantDB, required this.plantIndex}) : super(key: key);

  static const routeDisplayName = 'Plant page';

  @override
  State<PlantPage> createState() => _MealPageState();
}//PlantPage

//Class that manages the state of PlantPage
class _MealPageState extends State<PlantPage> {

  //Form globalkey: this is required to validate the form fields.
  final formKey = GlobalKey<FormState>();

  //Variables that maintain the current form fields values in memory.
  TextEditingController _choController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  
  //Here, we are using initState() to initialize the form fields values.
  //Rationale: Plant content and time are not known is the plant is new (plantIndex == -1). 
  //  In this case, initilize them to empty and now(), respectively, otherwise set them to the respective values.
  @override
  void initState() {
    _choController.text = widget.plantIndex == -1 ? '' : widget.plantDB.plants[widget.plantIndex].plant_name.toString();
    _selectedDate = widget.plantIndex == -1 ? DateTime.now() : widget.plantDB.plants[widget.plantIndex].dateTime;
    super.initState();
  } // initState

  //Form controllers need to be manually disposed. So, here we need also to override the dispose() method.
  @override
  void dispose() {
    _choController.dispose();
    super.dispose();
  } // dispose

  @override
  Widget build(BuildContext context) {    

    //Print the route display name for debugging
    print('${PlantPage.routeDisplayName} built');

    //The page is composed of a form. An action in the AppBar is used to validate and save the information provided by the user.
    //A FAB is showed to provide the "delete" functinality. It is showed only if the plant already exists.
    return Scaffold(
      appBar: AppBar(
        title: Text(PlantPage.routeDisplayName),
        actions: [
          IconButton(onPressed: () => _validateAndSave(context), icon: Icon(Icons.done))
        ],
      ),
      body: Center(
        child: _buildForm(context),
      ),
      floatingActionButton: widget.plantIndex == -1 ? null : FloatingActionButton(onPressed: () => _deleteAndPop(context), child: Icon(Icons.delete),),
    );
  }//build

  //Utility method used to build the form.
  //Here, I'm showing to you how to do some new things:
  //1. How to actually implement a Form;
  //2. Define custom-made FormTiles (take a look at the widgets/formSeparator.dart and widgets/formTiles.dart files);
  //3. How to implement a Date+Time picker (take a look at the _selectDate utility method).
  Widget _buildForm(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 8, left: 20, right: 20),
        child: ListView(
          children: <Widget>[
            FormSeparator(label: 'Plant name'),
            FormTextTile(
              labelText: 'Plant name',
              controller: _choController,
              icon: MdiIcons.sprout,
            ),
            FormSeparator(label: 'Plant time'),
            FormDateTile(
              labelText: 'Plant Time',
              date: _selectedDate,
              icon: MdiIcons.clockTimeFourOutline,
              onPressed: () {
                _selectDate(context);
              },
              dateFormat: Formats.fullDateFormatNoSeconds,
            ),
          ],
        ),
      ),
    );
  } // _buildForm

  //Utility method that implements a Date+Time picker. 
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2010),
            lastDate: DateTime(2101))
        .then((value) async {
      if (value != null) {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
              hour: _selectedDate.hour, minute: _selectedDate.minute),
        );
        return pickedTime != null ? value.add(
              Duration(hours: pickedTime.hour, minutes: pickedTime.minute)) : null;
      }
      return null;
    });
    if (picked != null && picked != _selectedDate)
      //Here, I'm using setState to update the _selectedDate field and rebuild the UI.
      setState(() {
        _selectedDate = picked;
      });
  }//_selectDate

  //Utility method that validate the form and, if it is valid, save the new plant information.
  void _validateAndSave(BuildContext context) {
    if(formKey.currentState!.validate()){
      Plant newPlant = Plant(plant_name: _choController.text, dateTime: _selectedDate);
      widget.plantIndex == -1 ? widget.plantDB.addPlant(newPlant) : widget.plantDB.editPlant(widget.plantIndex, newPlant);
      Navigator.pop(context);
    }
  } // _validateAndSave

  //Utility method that deletes a plant entry.
  void _deleteAndPop(BuildContext context){
    widget.plantDB.deletePlant(widget.plantIndex);
    Navigator.pop(context);
  }//_deleteAndPop

} //PlantPage
