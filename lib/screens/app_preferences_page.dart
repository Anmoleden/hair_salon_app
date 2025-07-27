import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppPreferencesPage extends StatefulWidget {
  const AppPreferencesPage({super.key});

  @override
  State<AppPreferencesPage> createState() => _AppPreferencesPageState();
}

class _AppPreferencesPageState extends State<AppPreferencesPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _darkMode = false;
  String _genderPreference = 'All';
  String _defaultTryOnMode = 'Overlay';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final darkModeValue = await _secureStorage.read(key: 'darkMode');
    final gender = await _secureStorage.read(key: 'genderPreference');
    final tryOnMode = await _secureStorage.read(key: 'tryOnMode');

    setState(() {
      _darkMode = darkModeValue == 'true';
      _genderPreference = gender ?? 'All';
      _defaultTryOnMode = tryOnMode ?? 'Overlay';
    });
  }

  Future<void> _savePreference(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  void _showGenderDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Gender Preference"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Male', 'Female', 'All'].map((gender) {
            return RadioListTile<String>(
              title: Text(gender),
              value: gender,
              groupValue: _genderPreference,
              onChanged: (value) {
                setState(() => _genderPreference = value!);
                _savePreference('genderPreference', value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTryOnModeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Default Try-On Mode"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Overlay', 'Model Preview'].map((mode) {
            return RadioListTile<String>(
              title: Text(mode),
              value: mode,
              groupValue: _defaultTryOnMode,
              onChanged: (value) {
                setState(() => _defaultTryOnMode = value!);
                _savePreference('tryOnMode', value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Preferences")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Gender Preference"),
            subtitle: Text(_genderPreference),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showGenderDialog,
          ),
          ListTile(
            leading: const Icon(Icons.face),
            title: const Text("Default Try-On Mode"),
            subtitle: Text(_defaultTryOnMode),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showTryOnModeDialog,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            value: _darkMode,
            onChanged: (val) {
              setState(() => _darkMode = val);
              _savePreference('darkMode', val.toString());
            },
          ),
        ],
      ),
    );
  }
}
