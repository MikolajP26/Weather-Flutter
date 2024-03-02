import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/current_weather_service.dart';
import '../pages/settings_weather_page.dart';

class WeatherPage extends StatefulWidget {
  WeatherPage({Key? key}) : super(key: key);
  State<WeatherPage> createState() => _WeatherPageState();
}

int _currentIndex = 0;

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = CurrentWeatherService();
  CurrentWeather? _weather;
  String _locationText = '';
  bool _isCurrentLocation = true;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _fetchWeather() async {
    try {
      final cityName = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
        _isCurrentLocation = true;
      });

      _updateLocationText('Current location: $cityName');
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }

  Future<void> _searchCity(String city) async {
    try {
      final weather = await _weatherService.getWeather(city);
      setState(() {
        _weather = weather;
        _isCurrentLocation = false;
      });

      _clearSearchField();
      _updateLocationText('Searched location: ${_weather?.currentName}');

      _saveCityName(_weather?.currentName);
    } catch (e) {
      print(e);
      _updateLocationText('Location not found');
    }
  }

  Future<void> _loadSavedCityName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCityName = prefs.getString('lastCityName');
    if (savedCityName != null) {
      _searchCity(savedCityName);
    } else {
      _fetchWeather();
    }
  }

  Future<void> _refreshWeatherForCurrentLocation() async {
    try {
      if (_isCurrentLocation) {
        final cityName = await _weatherService.getCurrentCity();
        final weather = await _weatherService.getWeather(cityName);
        setState(() {
          _weather = weather;
        });

        _updateLocationText('Refreshed data for: ${_weather?.currentName}');
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _updateLocationText(_isCurrentLocation
                ? 'Current location: $cityName'
                : 'Searched location: ${_weather?.currentName}');
          });
        });
      } else {
        if (_weather != null) {
          final weather =
              await _weatherService.getWeather(_weather!.currentName);
          setState(() {
            _weather = weather;
          });

          _updateLocationText('Refreshed data for: ${_weather?.currentName}');
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _updateLocationText(_isCurrentLocation
                  ? 'Current location: ${_weather?.currentName}'
                  : 'Searched location: ${_weather?.currentName}');
            });
          });
        }
      }
    } catch (e) {
      print('Error refreshing weather for current location: $e');
    }
  }

  void _updateLocationText(String location) {
    setState(() {
      _locationText = _isCurrentLocation ? '$location' : location;
    });
  }

  void _clearSearchField() {
    setState(() {
      _searchController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCityName();
  }

  Future<void> _saveCityName(String? cityName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCityName', cityName ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 30, 30, 30),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              _buildWeatherContainer(),
              SizedBox(
                height: 10,
              ),
              _buildSearchContainer(),
              SizedBox(
                height: 10,
              ),
              _buildWeatherInfoContainer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            _currentIndex = 0;
          });

          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsWeatherPage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildWeatherContainer() {
    return Container(
      width: 400,
      height: 300,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color.fromARGB(50, 105, 105, 105),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _weather?.currentName != null
                    ? (_weather!.currentName.length > 16
                        ? _weather!.currentName.substring(0, 16) + "..."
                        : _weather!.currentName)
                    : "Loading city...",
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
              ElevatedButton(
                onPressed: _refreshWeatherForCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(50, 235, 235, 235),
                  shape: CircleBorder(),
                ),
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Actual',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${_weather?.currentTemp.round()}°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _weather?.currentIcon != null
                        ? Image.network(
                            'https://openweathermap.org/img/wn/${_weather?.currentIcon}@2x.png',
                          )
                        : Text('null'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Feels Like',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      '${_weather?.currentTempFeelsLike.round()}°C',
                      style: TextStyle(color: Colors.white, fontSize: 28),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            _weather?.currentDescription ?? "",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(
            height: 82,
          ),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'Last Update: ' +
                        DateFormat('yyyy-MM-dd HH:mm').format(
                            _weather?.currentLastUpdated ?? DateTime.now()) +
                        ' UTC',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContainer() {
    return Container(
      width: 400,
      height: 80,
      decoration: BoxDecoration(
        color: Color.fromARGB(50, 105, 105, 105),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: ElevatedButton(
                  onPressed: () {
                    _fetchWeather();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(50, 235, 235, 235),
                    shape: CircleBorder(),
                  ),
                  child: Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 42,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(50, 235, 235, 235),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(color: Colors.white),
                                border: InputBorder.none,
                              ),
                              onChanged: (text) {},
                              onSubmitted: (text) {
                                _searchCity(text);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: _weather != null ? 1.0 : 0.0,
            child: Text(
              _weather != null ? _locationText : 'Location not found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfoContainer() {
    return Container(
      width: 400,
      height: 300,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color.fromARGB(50, 105, 105, 105),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              'Current Conditions',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCityWeatherContainer(
                'Wind',
                '${_weather?.currentWindSpeed} m/s',
              ),
              SizedBox(width: 16.0),
              _buildCityWeatherContainer(
                'Humidity',
                '${_weather?.currentHumidity} %',
              ),
              SizedBox(width: 16.0),
              _buildCityWeatherContainer(
                'Pressure',
                '${_weather?.currentPressure} hPa',
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCityWeatherContainer(
                'Max Temp',
                '${_weather?.currentTempMax} °C',
              ),
              SizedBox(width: 16.0),
              _buildCityWeatherContainer(
                'Cloudiness',
                '${_weather?.currentClouds} %',
              ),
              SizedBox(width: 16.0),
              _buildCityWeatherContainer(
                'Min Temp',
                '${_weather?.currentTempMin} °C',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCityWeatherContainer(String title, String value) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(50, 105, 105, 105),
          borderRadius: BorderRadius.circular(25.0),
        ),
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: [
                    'Wind',
                    'Humidity',
                    'Pressure',
                    'Max Temp',
                    'Cloudiness',
                    'Min Temp',
                  ].contains(title)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                value,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
