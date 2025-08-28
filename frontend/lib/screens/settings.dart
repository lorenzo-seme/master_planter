import 'package:flutter/material.dart';
import 'package:master_planter/services/backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _dailyTipsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('user_name');
    if (name != null) _nameController.text = name;

    _notificationsEnabled = prefs.getBool('care_reminders') ?? true;
    _dailyTipsEnabled = prefs.getBool('daily_tips') ?? true;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String previousUsername = prefs.getString('user_name') ?? '';
    String newName = _nameController.text.trim();
    await prefs.setString('user_name', newName);

    if (previousUsername != newName) {
      await BackendService().changeUsername(previousUsername, newName);
      print('Username changed from $previousUsername to $newName');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Name saved!')),
    );
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Profile', style: TextStyle(color: Colors.black)),
            tiles: [
              SettingsTile.navigation(
                leading: Icon(Icons.person),
                title: Text('Your Name'),
                trailing: Text(
                  _nameController.text,
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                onPressed: (context) {
                  // Mostra dialog per modificare il nome
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Edit Name'),
                      content: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _saveName();
                            Navigator.pop(context);
                            setState(() {}); // Aggiorna la tile
                          },
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text('Preferences', style: TextStyle(color: Colors.black)),
            tiles: [
              SettingsTile.switchTile(
                onToggle: (value) async {
                  setState(() => _notificationsEnabled = value);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('care_reminders', value);
                },
                initialValue: _notificationsEnabled,
                leading: Icon(Icons.notifications),
                title: Text('Care reminders'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  setState(() => _dailyTipsEnabled = value);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('daily_tips', value);
                },
                initialValue: _dailyTipsEnabled,
                leading: Icon(Icons.lightbulb),
                title: Text('Daily care tips'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
