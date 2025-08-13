import 'package:flutter/material.dart';
import 'package:master_planter/models/plant.dart';
//import 'package:master_planter/models/plantDB.dart';
import 'package:master_planter/screens/splash.dart';
import 'package:master_planter/services/local_db_service.dart';
import 'package:master_planter/utils/app_info.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final packageInfo = await PackageInfo.fromPlatform();
  final version = packageInfo.version;
  final buildNumber = packageInfo.buildNumber;
  AppInfo.version = 'v$version (build $buildNumber)';

  // Initialize the local database and set the default username on shared preferences
  LocalDbService().initDb();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureProvider<List<Plant>>(
      initialData: [],
      create: (context) => LocalDbService().getPlants(),
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