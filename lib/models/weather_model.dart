class CurrentWeather {
  final String currentDescription;
  final String currentIcon;
  final double currentTemp;
  final double currentTempFeelsLike;
  final double currentTempMin;
  final double currentTempMax;
  final double currentPressure;
  final double currentHumidity;
  final double currentWindSpeed;
  final double currentClouds;
  final DateTime currentLastUpdated;
  final String currentName;
  CurrentWeather({
    required this.currentDescription,
    required this.currentIcon,
    required this.currentTemp,
    required this.currentTempFeelsLike,
    required this.currentTempMin,
    required this.currentTempMax,
    required this.currentPressure,
    required this.currentHumidity,
    required this.currentWindSpeed,
    required this.currentClouds,
    required this.currentLastUpdated,
    required this.currentName,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final List<dynamic> weatherData = json['weather'];

    DateTime lastUpdated = DateTime.now();

    if (json.containsKey('dt') && json['dt'] != null) {
      lastUpdated = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);
    }

    return CurrentWeather(
      currentIcon: weatherData[0]['icon'] ?? '',
      currentTemp: json['main']['temp'].toDouble(),
      currentTempFeelsLike: json['main']['feels_like'].toDouble(),
      currentTempMin: json['main']['temp_max'].toDouble(),
      currentTempMax: json['main']['temp_min'].toDouble(),
      currentDescription: weatherData[0]['description'] ?? '',
      currentPressure: json['main']['pressure'].toDouble(),
      currentHumidity: json['main']['humidity'].toDouble(),
      currentWindSpeed: json['wind']['speed'].toDouble(),
      currentClouds: json['clouds']['all'].toDouble(),
      currentLastUpdated: lastUpdated,
      currentName: json['name'],
    );
  }
}
