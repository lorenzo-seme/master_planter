import 'package:flutter/material.dart';
import 'package:master_planter/database/backend_operations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfoPage extends StatefulWidget {
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('user_name');
    if (name != null) {
      _nameController.text = name;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String previous_username = prefs.getString('user_name')!;
    await prefs.setString('user_name', _nameController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Name saved!')),
    );
    FocusScope.of(context).unfocus();
    setState(() {});
    if (previous_username != _nameController.text.trim()) {
      await changeUsername(previous_username, _nameController.text.trim());
      print('Username changed from $previous_username to ${_nameController.text.trim()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Personal Info')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Personal Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Your Name: ", style: TextStyle(fontSize: 18)),
                const SizedBox(width: 20),
                Expanded(
                child:TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                )
              ],
            ),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveName,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}