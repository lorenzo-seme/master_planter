import 'package:flutter/material.dart';
import 'package:master_planter/services/backend_service.dart';
import 'package:master_planter/models/plantDB.dart';
import 'package:master_planter/services/local_db_service.dart';
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

  // PLANT DATA CARD
  bool isEditing = false; // controlla se i campi sono editabili
  TextEditingController adoptionController = TextEditingController(text: '01/01/2024');
  TextEditingController locationController = TextEditingController(text: '');
  // NOTES CARD
  TextEditingController notesController = TextEditingController(text: '');
  bool isEditingNotes = false; // controlla se il campo note è editabile

  List<Widget> photos = [];
  
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
    adoptionController.dispose();
    locationController.dispose();
    notesController.dispose();
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
        title: TextFormField(
          controller: _choController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Plant name',
            hintStyle: TextStyle(
              color: Colors.white60, // colore dell’hint
            ),
            border: InputBorder.none,
          ),
          style: const TextStyle(
            color: Colors.white, // per il testo nell'AppBar
            fontSize: 20,
          ),
        ),
        //_choController.text == "" ? Text("New Plant") : Text(_choController.text),
        actions: [
          IconButton(onPressed: () => _validateAndSave(context), icon: Icon(Icons.done))
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            _buildPhotoSection(context),
            _buildPlantData(context),
            _buildCareRecords(context),
            _buildPlantStatus(context),
            _buildNotes(context),
          ],
        ),
      ),
      floatingActionButton: widget.plantIndex == -1 ? null : FloatingActionButton(onPressed: () => _deleteAndPop(context), child: Icon(Icons.delete),),
    );
  }//build

  //Utility method used to build the form.
  //Here, I'm showing to you how to do some new things:
  //1. How to actually implement a Form;
  //2. Define custom-made FormTiles (take a look at the widgets/formSeparator.dart and widgets/formTiles.dart files);
  //3. How to implement a Date+Time picker (take a look at the _selectDate utility method).

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
      await LocalDbService().insertPlant(newPlant);
      BackendService().sync();
      setState(() {});
      print(newPlant);
      Navigator.pop(context);
    }
  } // _validateAndSave

  //Utility method that deletes a plant entry.
  Future<void> _deleteAndPop(BuildContext context) async{
    await LocalDbService().markPlantAsDeletePending(widget.plantDB.plants[widget.plantIndex].plant_id);
    BackendService().sync();
    widget.plantDB.deletePlant(widget.plantIndex); 
    Navigator.pop(context);
  }//_deleteAndPop

  Widget _addPhotoButton(BuildContext context){
    return SizedBox(
      height: 15,
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
    );
  }

  Widget _buildPhotoSection(BuildContext context){
    return SizedBox(
      height:280,
      child:
      PageView(
        children: _image_path=='' ? [_addPhotoButton(context)] : photos + [Image.file(File(_image_path))] + [_addPhotoButton(context)],
        ),
    );
                
    //             photos.map((path) {
    //       return Image.asset(
    //         path,
    //         fit: BoxFit.cover,
    //       );
    //     }).toList(),
    // ),
    
  }

  Widget _buildPlantData(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
          ),
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intestazione con titolo e penna
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Plant Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(isEditing ? Icons.check : Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing; // cambia modalità
                    });
                  },
                )
              ],
            ),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adoption Date:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: isEditing ? () => _selectDate(context) : null,
                  child: Row(
                    children: [
                      Text(
                        Formats.onlyDayDateFormat.format(_selectedDate),
                        style: TextStyle(
                          color: isEditing ? Colors.blue : Colors.black,
                          decoration: isEditing
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      ),
                      if (isEditing)
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            
            SizedBox(height: 8),
            
            // Campo Location
            Text('Location:', style: TextStyle(fontWeight: FontWeight.bold)),
            isEditing
                ? TextFormField(
                  controller: locationController,
                  validator:(value){return null;})
                : Text(locationController.text),
          ],
        ),
      ),
    );
    // return Form(
    //   key: formKey,
    //   child: Padding(
    //     padding: const EdgeInsets.only(top: 10, bottom: 8, left: 20, right: 20),
    //     child: Expanded(
    //       child: ListView(
    //         shrinkWrap: true,
    //         children: <Widget>[
    //           FormSeparator(label: 'Plant name'),
    //           FormTextTile(
    //             //labelText: 'Plant name',
    //             controller: _choController,
    //             icon: MdiIcons.sprout,
    //           ),
    //           FormSeparator(label: 'Adoption day'),
    //           FormDateTile(
    //             labelText: 'Adoption day ',
    //             date: _selectedDate,
    //             icon: MdiIcons.clockTimeFourOutline,
    //             onPressed: () {
    //               _selectDate(context);
    //             },
    //             dateFormat: Formats.onlyDayDateFormat,
    //           ),
    //           FormSeparator(label: 'Photo'),
    //           Align(
    //             alignment: Alignment.center,
    //             child: ElevatedButton(
    //               onPressed: () async {
    //                 _showPicker(context);
    //               },
    //               style: ButtonStyle(
    //                   padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
    //                       const EdgeInsets.symmetric(
    //                           horizontal: 60, vertical: 12)),
    //                   foregroundColor:
    //                       MaterialStateProperty.all<Color>(Colors.white),
    //                   backgroundColor: MaterialStateProperty.all<Color>(
    //                       const Color(0xFF384242))),
    //               child: const Text('Tap to add a photo'),
    //             ),
    //           ),
    //           Align(
    //             alignment: Alignment.center,
    //             child: Container(
    //               alignment: Alignment.center,
    //               width: 400,
    //               height: 400,
    //               child: (_image_path!='') ? Image.file(File(_image_path)) : Text('No photo added'),
    //             )
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  } // _buildForm

  Widget _buildCareRecords(BuildContext context) {
    return Card(
              shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                  ),
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: const Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Records',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 12),
            Text('Last watering: not available', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('Last fertilization: not available', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('Last repot: not available', style: TextStyle(fontSize: 16)),
          ]
        ),
      ),
    );
  }

  Widget _buildPlantStatus(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
          ),
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: const Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plant Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 12),
            Text('Watering', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('Fertilization', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('Repot', style: TextStyle(fontSize: 16)),
          ]
        ),
      ),
    );
  }

  Widget _buildNotes(BuildContext context) {
    return Card(
              shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                  ),
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(isEditingNotes ? Icons.check : Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditingNotes = !isEditingNotes;
                    });
                  },
                )
              ],
            ),
            SizedBox(height: 8),

            // Campo Note
            Text(
              'Your notes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            isEditingNotes
                ? TextFormField(
                    controller: notesController,
                    validator:(value){return null;},
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Enter your notes here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                : Text(
                    notesController.text.isEmpty
                        ? 'No notes yet'
                        : notesController.text,
                    style: TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }
}