import 'dart:io';

import 'package:master_planter/services/backend_service.dart';
import 'package:master_planter/models/plantDB.dart';
import 'package:master_planter/screens/plantpage.dart';
import 'package:master_planter/services/local_db_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Plants extends StatefulWidget {
  const Plants({Key? key}) : super(key: key);

  @override
  State<Plants> createState() => _PlantsState();
}

class _PlantsState extends State<Plants> {
  bool _isSearching = false;
  String _searchText = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlantDB(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search plants...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value.toLowerCase();
                    });
                  },
                )
              : const Text('My Plants'),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _searchText = '';
                    _searchController.clear();
                  }
                  _isSearching = !_isSearching;
                });
              },
            ),
          ],
        ),
        body: Center(
          child: Consumer<PlantDB>(
            builder: (context, plantDB, child) {
              final filteredPlants = plantDB.plants.where((plant) {
                return plant.plant_name
                    .toLowerCase()
                    .contains(_searchText);
              }).toList();

              return RefreshIndicator(
                displacement: 80,
                onRefresh: () async {
                  await BackendService().sync();
                  setState(() {});
                },
                child: filteredPlants.isEmpty
                    ? ListView( // Necessario per permettere il pull-to-refresh anche senza elementi
                        children: const [
                          SizedBox(height: 300, child: Center(child: Text('No plants found'))),
                        ],
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        itemCount: filteredPlants.length,
                        itemBuilder: (context, index) {
                          final plant = filteredPlants[index];
                          return Dismissible(
                            key: Key(plant.plant_id), // TODO: CAMBIA QUI, USA ID NON PLANT NAME
                            direction: DismissDirection.endToStart, // Swipe da destra a sinistra
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) async {
                              // Cancella la pianta dal database
                              await LocalDbService().markPlantAsDeletePending(plant.plant_id);
                              await BackendService().sync();
                              plantDB.deletePlant(index);

                              // Mostra un messaggio
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${plant.plant_name} removed"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFDDEDE3)),
                                ),
                              elevation: 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _toPlantPage(
                                  context,
                                  Provider.of<PlantDB>(context, listen: false),
                                  plantDB.plants.indexOf(plant),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: plant.plant_image_path != ''
                                            ? Image.file(
                                                File(plant.plant_image_path!),
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[300],
                                                child: Icon(MdiIcons.image, size: 40, color: Colors.grey),
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              plant.plant_name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            FutureBuilder<String>(
                                              future: LocalDbService().getSyncStatus(plant.plant_id),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return Text(
                                                    'Loading...',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                    'Error',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.red,
                                                    ),
                                                  );
                                                } else {
                                                  return Text(
                                                    snapshot.data ?? '',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                            // Text(
                                            //   'Last update: ${Formats.onlyDayDateFormat.format(plant.date_of_adoption)}',
                                            //   style: TextStyle(
                                            //     fontSize: 14,
                                            //     color: Colors.grey[600],
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                    ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(MdiIcons.plus),
          onPressed: () => _toPlantPage(
              context, Provider.of<PlantDB>(context, listen: false), -1),
        ),
      ),
    );
  }

  void _toPlantPage(BuildContext context, PlantDB plantDB, int plantIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantPage(
          plantDB: plantDB,
          plantIndex: plantIndex,
        ),
      ),
    );
  }
}
