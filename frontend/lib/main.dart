import 'package:flutter/material.dart';
import 'package:master_planter/database/backend_operations.dart';
import 'package:master_planter/models/plant.dart';
//import 'package:master_planter/models/plantDB.dart';
import 'package:master_planter/screens/splash.dart';
import 'package:master_planter/utils/app_info.dart';
import 'package:provider/provider.dart';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final packageInfo = await PackageInfo.fromPlatform();
  final version = packageInfo.version;
  final buildNumber = packageInfo.buildNumber;
  AppInfo.version = 'v$version (build $buildNumber)';

  openDatabase(
    join(await getDatabasesPath(), 'plants_db.db'),
    onCreate: (db, version) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', 'anonymous${Uuid().v4()}');
      
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE plants(plant_id TEXT PRIMARY KEY, plant_name TEXT, date_of_adoption TEXT, plant_location TEXT, img TEXT, sync_status TEXT)',
      ); // TOGLI USERNAME DA DATABASE LOCALE
  },

    // for (final {
    //     'plant_id': plant_id as String,
    //     'username': username as String,
    //     'plant_name': plant_name as String,
    //     'date_of_adoption': date as String,
    //     'plant_location': plant_location as String,
    //     'img': img as String,
    //     'sync_status': sync_status as String,
    //   } in plantMaps){

  //     'user_id': username,
  //     'plant_id': plant_id,
  //     'plant_name': plant_name,
  //     'date': date_of_adoption.toString(),
  //     'plant_location': plant_location,
  //     'img': plant_image_path,
  //     'sync_status': sync_status,
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
            scaffoldBackgroundColor: const Color(0xFFFAFAF8),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2B5A4D),
              foregroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF2B5A4D),
              primary: Color(0xFF2B5A4D),
              secondary: Color(0xFFEDF1F1),
              background: Color(0xFFFAFAF8),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF2B5A4D),
              foregroundColor: Colors.white,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2E2E2E)),
              bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D)),
            ),
            cardTheme: CardTheme(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),

          home: const Splash(),
        ),);
  }
}

/*
Idea: potrei implementare la lettura dal database nello splash, in modo da accedere all'app solo una volta completata questa lettura. In questo modo non devo usare initialData
e quindi potrei usare direttamente un ChangeNotifierProvider
*/