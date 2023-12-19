import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesScreen extends StatefulWidget {
  @override
  _SharedPreferencesScreenState createState() =>
      _SharedPreferencesScreenState();
}

class _SharedPreferencesScreenState extends State<SharedPreferencesScreen> {
  TextEditingController _controller = TextEditingController();
  late SharedPreferences _prefs;
  String _storedValue = "";

  @override
  void initState() {
    super.initState();
    _loadStoredValue();
  }

  // Load the stored value from SharedPreferences
  Future<void> _loadStoredValue() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedValue = _prefs.getString('userInput') ?? "";
    });
  }

  // Save the input value to SharedPreferences
  Future<void> _saveInput() async {
    await _prefs.setString('userInput', _controller.text);
    _loadStoredValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SharedPreferences Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stored Value:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(_storedValue),
            SizedBox(height: 16),
            Text(
              'Enter a new value:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type something...',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _saveInput();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Input saved to SharedPreferences')),
                );
              },
              child: Text('Save Input'),
            ),
          ],
        ),
      ),
    );
  }
}
