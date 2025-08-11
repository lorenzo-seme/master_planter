import 'package:flutter/material.dart';
import 'package:master_planter/database/backend_operations.dart';
import 'package:master_planter/models/plantDB.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:master_planter/models/plant.dart';
import 'package:master_planter/widgets/formTiles.dart';
import 'package:master_planter/widgets/formSeparator.dart';
import 'package:master_planter/utils/formats.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  State<PlantPage> createState() => _PlantPageState();
}//PlantPage

//Class that manages the state of PlantPage
class _PlantPageState extends State<PlantPage> {

  //Form globalkey: this is required to validate the form fields.
  final formKey = GlobalKey<FormState>();

  //Variables that maintain the current form fields values in memory.
  TextEditingController _choController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _image_path = '';
  
  //Here, we are using initState() to initialize the form fields values.
  //Rationale: Plant content and time are not known is the plant is new (plantIndex == -1). 
  //  In this case, initilize them to empty and now(), respectively, otherwise set them to the respective values.
  @override
  void initState() {
    _choController.text = widget.plantIndex == -1 ? '' : widget.plantDB.plants[widget.plantIndex].plant_name.toString();
    _selectedDate = widget.plantIndex == -1 ? DateTime.now() : widget.plantDB.plants[widget.plantIndex].date_of_adoption;
    _image_path = (widget.plantIndex == -1 ? '' : widget.plantDB.plants[widget.plantIndex].plant_image_path)!;
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
        title: _choController.text == "" ? Text("New Plant") : Text(_choController.text),
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
              //labelText: 'Plant name',
              controller: _choController,
              icon: MdiIcons.sprout,
            ),
            FormSeparator(label: 'Adoption day'),
            FormDateTile(
              labelText: 'Adoption day ',
              date: _selectedDate,
              icon: MdiIcons.clockTimeFourOutline,
              onPressed: () {
                _selectDate(context);
              },
              dateFormat: Formats.onlyDayDateFormat,
            ),
            FormSeparator(label: 'Photo'),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  _showPicker(context);
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 12)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF384242))),
                child: const Text('Tap to add a photo'),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                width: 400,
                height: 400,
                child: (_image_path!='') ? Image.file(File(_image_path)) : Text('No photo added'),
              )
            ),
          ],
        ),
      ),
    );
  } // _buildForm

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea( // SafeArea evita che il contenuto vada sotto elementi di sistema (es. la barra inferiore su iOS)
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  _takeSnapshot(context, ImageSource.gallery);
                  Navigator.of(context).pop(); // Chiude il bottom sheet
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  _takeSnapshot(context, ImageSource.camera);
                  Navigator.of(context).pop(); // Chiude il bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _takeSnapshot(BuildContext context, ImageSource source) async {
        final ImagePicker picker = ImagePicker();
        final XFile? img = await picker.pickImage(
          source: source, // alternatively, use ImageSource.gallery
          maxWidth: 400,
        );
        if (img == null) return;
        setState(() {
        _image_path = img.path;
      });
        //widget.plantDB.addPlantPhoto(widget.plantIndex, img.path); // convert it to a Dart:io file
  }

  //Utility method that implements a Date+Time picker. 
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2010),
            lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate) {
      //Here, I'm using setState to update the _selectedDate field and rebuild the UI.
      setState(() {
        _selectedDate = picked;
      });
    }
  }//_selectDate

  //Utility method that validate the form and, if it is valid, save the new plant information.
  Future<void> _validateAndSave(BuildContext context) async{

    String? plant_id;

    try{
      plant_id = widget.plantDB.plants[widget.plantIndex].plant_id;
    } catch (e) {
      plant_id = null;
    }

    if(formKey.currentState!.validate()){
      Plant newPlant = Plant(plant_id: plant_id, plant_name: _choController.text, date_of_adoption: _selectedDate, plant_image_path: _image_path);
      widget.plantIndex == -1 ? widget.plantDB.addPlant(newPlant) : widget.plantDB.editPlant(widget.plantIndex, newPlant);
      await insertPlantIntoDB(newPlant);
      print(newPlant);
      Navigator.pop(context);
    }
  } // _validateAndSave

  //Utility method that deletes a plant entry.
  Future<void> _deleteAndPop(BuildContext context) async{
    await deletePlantFromDB(widget.plantDB.plants[widget.plantIndex].plant_id);
    widget.plantDB.deletePlant(widget.plantIndex); 
    Navigator.pop(context);
  }//_deleteAndPop

} //PlantPage
