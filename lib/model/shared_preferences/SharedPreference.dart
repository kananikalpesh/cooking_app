import 'dart:convert';

import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/dashboard/DeviceInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceManager {
  static const String IS_LOGGED_IN = 'isLoggedIn';
  static const String DEVICE_ID = 'deviceId';
  static const String FIREBASE_TOKEN = 'firebaseToken';
  static const String USER = 'user';
  static const String IS_HELP_SCREEN_VISIBLE = 'isHelpScreenVisible';
  static const String STORAGE_LIMIT = 'storageLimit';
  static const String STORAGE_UTILIZED = 'storageUtilized';
  static const String VOIP_TOKEN = 'VoIP_TOKEN';
  static const String CC_NOTIFICATION_SUBSCRIPTION_ID =
      'cc_notification_subscription_Id';
  static const String PG_STATUS = 'pg_status';

  static final SharedPreferenceManager _instance =
      new SharedPreferenceManager._internal();

  factory SharedPreferenceManager() {
    return _instance;
  }

  SharedPreferenceManager._internal();

  Future<dynamic> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_LOGGED_IN) ?? false;
  }

  Future<bool> setLoggedIn(bool isLogin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(IS_LOGGED_IN, isLogin);
  }

  Future<bool> isHelpScreenVisible() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_HELP_SCREEN_VISIBLE) ?? true;
  }

  Future<bool> setHelpScreenVisible(bool isLogin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(IS_HELP_SCREEN_VISIBLE, isLogin);
  }

  Future<String> getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(DEVICE_ID) ?? null;
  }

  Future<bool> setDeviceId(String deviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(DEVICE_ID, deviceId);
  }

  Future<String> getFirebaseToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(FIREBASE_TOKEN) ?? "";
  }

  Future<bool> setFirebaseToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(FIREBASE_TOKEN, token);
  }

  Future<UserModel> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String strJson = prefs.getString(USER);
    if(strJson == null){
      return null;
    }
    return UserModel.fromJson(json.decode(strJson));
  }

  Future<bool> setUser(UserModel userModel) async {
    AppData.user = userModel;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonStr = null;
    if (userModel != null) {
      jsonStr = json.encode(userModel.toJson());
    }
    return prefs.setString(USER, jsonStr);
  }

  Future<double> getStorageLimit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(STORAGE_LIMIT);
  }

  Future<bool> setStorageLimit(double limit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(STORAGE_LIMIT, limit);
  }

  Future<double> getStorageUtilized() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(STORAGE_UTILIZED);
  }

  Future<bool> setStorageUtilized(double utilized) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(STORAGE_UTILIZED, utilized);
  }

  Future<String> getVoIPToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(VOIP_TOKEN) ?? "";
  }

  Future<bool> setVoIPToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(VOIP_TOKEN, token);
  }

  Future<int> getCCSubscriptionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(CC_NOTIFICATION_SUBSCRIPTION_ID) ?? -1;
  }

  Future<bool> setCCSubscriptionId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(CC_NOTIFICATION_SUBSCRIPTION_ID, id);
  }

  //setPgStatus
  Future<PgStatus> getPgStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String strJson = prefs.getString(PG_STATUS);
    if(strJson == null){
      return null;
    }
    return PgStatus.fromJson(json.decode(strJson));
  }

  Future<bool> setPgStatus(PgStatus pgStatus) async {
    AppData.pgStatus = pgStatus;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonStr = null;
    if (pgStatus != null) {
      jsonStr = json.encode(pgStatus.toJson());
    }
    return prefs.setString(PG_STATUS, jsonStr);
  }

}