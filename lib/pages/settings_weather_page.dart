import 'package:flutter/material.dart';
import '../services/current_weather_service.dart';

class SettingsWeatherPage extends StatefulWidget {
  _SettingsWeatherPageState createState() => _SettingsWeatherPageState();
}

class _SettingsWeatherPageState extends State<SettingsWeatherPage> {
  int _currentIndex = 1;
  TextEditingController _apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 25, right: 25, bottom: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'Enter API Key',
                    labelStyle: TextStyle(color: Colors.white),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    String newApiKey = _apiKeyController.text;
                    try {
                      await CurrentWeatherService().setApiKey(newApiKey);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('API Key updated'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(80),
                        ),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $error'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(80),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(50, 235, 235, 235),
                  ),
                  child: Text(
                    'Save API Key',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          BottomNavigationBar(
            selectedItemColor: Colors.white,
            backgroundColor: Color.fromARGB(255, 50, 50, 50),
            currentIndex: _currentIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = 1;
              });

              switch (index) {
                case 0:
                  Navigator.pop(context);
                  break;
                case 1:
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}
