import 'package:shared_preferences/shared_preferences.dart';

class ServerPreferences {
  static const String AV = "av";
  static const String TOKEN = "token";

  static final ServerPreferences _instance = new ServerPreferences._internal();

  factory ServerPreferences() {
    return _instance;
  }

  ServerPreferences._internal();

  Future<String> getAV() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getString(AV)?.isEmpty ?? true) ? '0.1' :  prefs.getString(AV);
  }

  Future<bool> setAV(String av) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(AV, av);
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN) ?? '';
  }

  Future<bool> setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(TOKEN, token);
  }

}
