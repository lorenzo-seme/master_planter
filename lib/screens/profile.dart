import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';


class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 12.0, right: 12.0, top: 60, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text("Info about you and your preferences",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                )),
            Divider(
              color: Color(0xFFFFFFFF),
              thickness: 3,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Account",
              style: TextStyle(fontSize: 16),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Text(
                    "Personal Info",
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {
                  },
                ),
                Divider(
                  color: Color(0xFFFFFFFF),
                  thickness: 3,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "This app helps you managing your plants!",
                    style: TextStyle(
                        fontSize: 14, color: Colors.black.withOpacity(0.4)),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Text("version 0.0.1"),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  //_toLogin(context);
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 12)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF384242))),
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
