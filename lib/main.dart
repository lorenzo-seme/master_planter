import 'package:flutter/material.dart';
import 'package:master_planter/database/db_operations.dart';
import 'package:master_planter/models/plant.dart';
//import 'package:master_planter/models/plantDB.dart';
import 'package:master_planter/screens/splash.dart';
import 'package:provider/provider.dart';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  openDatabase(
    join(await getDatabasesPath(), 'plants_db.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE plants(id TEXT PRIMARY KEY, date TEXT, img TEXT)',
      );
  },
  // Set the version. This executes the onCreate function and provides a
  // path to perform database upgrades and downgrades.
  version: 1,
    );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureProvider<List<Plant>>(
      initialData: [],
      create: (context) => getPlantsFromDb(),
      child:
        MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.
            colorScheme: ColorScheme.fromSeed(
                background: const Color(0xFFFFFFFF),
                primary: const Color(0xFF2b5a4d),
                secondary: const Color(0xFFedf1f1),
                seedColor: const Color(0xFF2b5a4d)),
            useMaterial3: true,
          ),
          home: const Splash(),
        ),);
  }
}

/*
Idea: potrei implementare la lettura dal database nello splash, in modo da accedere all'app solo una volta completata questa lettura. In questo modo non devo usare initialData
e quindi potrei usare direttamente un ChangeNotifierProvider
*/