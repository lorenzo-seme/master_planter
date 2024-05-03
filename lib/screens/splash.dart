import 'package:flutter/material.dart';
import 'package:master_planter/screens/home.dart';


class Splash extends StatelessWidget {
  const Splash({super.key});

  // Method for navigation SplashPage -> HomePage
  void _toHomePage(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => const Home()));
        // per evitare stack infiniti di pagine
  } //_toHomePage

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () => _toHomePage(context));
    return Scaffold(
        appBar: AppBar(
          title: Text('MasterPlanter v0.0.1',
              style: TextStyle(fontSize: 16)),
          ),
        body: Center(
           child: Image.asset(
      'assets/logo.png',
      scale: 0.5,
    )));
  }
}
