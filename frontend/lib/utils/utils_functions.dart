import 'package:shared_preferences/shared_preferences.dart';

Future<String> getUsernameFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_name')!;
}