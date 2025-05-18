import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  static bool? getBoolean({
    required String key,
  }) {
    return sharedPreferences.getBool(key);
  }

  static Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is String) return await sharedPreferences.setString(key, value);
    if (value is bool) return await sharedPreferences.setBool(key, value);
    if (value is int) return await sharedPreferences.setInt(key, value);
    return await sharedPreferences.setDouble(key, value);
  }

  static Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  static Future<bool> clearAllData() async {
    return await sharedPreferences.clear();
  }

  // Helper: Retrieve the cached exchange rates map.
  static Map<String, dynamic>? getCachedExchangeRates() {
    final jsonRates = sharedPreferences.getString('exchange_rates');
    if (jsonRates != null) {
      try {
        return Map<String, dynamic>.from(json.decode(jsonRates));
      } catch (e) {
        print("Error decoding cached exchange rates: $e");
      }
    }
    return null;
  }

  // Helper: Get cached exchange rate for a target code.
  static double getExchangeRate(String target) {
    final rates = getCachedExchangeRates();
    if (rates != null && rates.containsKey(target)) {
      return rates[target] is int
          ? (rates[target] as int).toDouble()
          : (rates[target] as double);
    }
    return 1; // fallback
  }
}