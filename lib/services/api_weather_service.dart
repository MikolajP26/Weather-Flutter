import 'package:shared_preferences/shared_preferences.dart';

class CurrentApiWeatherService {
  static const String apiKeyKey = 'api_key';

  static Future<String?> getApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(apiKeyKey);
  }

  static Future<void> setApiKey(String apiKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(apiKeyKey, apiKey);
  }
}
