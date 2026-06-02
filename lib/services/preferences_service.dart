import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool(
      'isFirstTimeOpen',
      _prefs.getBool('isFirstTimeOpen') ?? true,
    );
  }

  bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;
  String get currencySymbol => _prefs.getString('currencySymbol') ?? 'Rp';
  String get userName => _prefs.getString('userName') ?? 'Noval';
  bool get isFirstTimeOpen => _prefs.getBool('isFirstTimeOpen') ?? true;
  bool get monthlyLimitAlert => _prefs.getBool('monthlyLimitAlert') ?? true;
  double get monthlyLimit => _prefs.getDouble('monthlyLimit') ?? 5000000.0;
  String get languagePref => _prefs.getString('languagePref') ?? 'id';

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
  Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);
}
