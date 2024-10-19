
import 'dart:io';

import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/shared_preferences/SharedPreference.dart';
import 'package:cooking_app/modules/dashboard/DashboardRepository.dart';
import 'package:cooking_app/modules/dashboard/DeviceInfo.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';

class DashboardBloc extends Bloc {
  static const _TAG = "DashboardBloc";

  static const String SEND_DEVICE_DATA_EVENT = "send_device_data";

  final _repository = DashboardRepository();

  final event = PublishSubject<EventModel>();
  final obsDeviceInfo = PublishSubject<ResultModel<DeviceInfo>>();

  final ValueNotifier<bool> updateCookDashBoardBottomBar = ValueNotifier(false);

  DashboardBloc() {
    event.listen((event) {
      switch (event.eventType) {
        case SEND_DEVICE_DATA_EVENT:
          _collectDeviceInfo(event.data);
          break;
      }
    });
  }

  void _collectDeviceInfo(String firebaseToken) async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    Map<String, dynamic> deviceInfo;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var deviceId = await SharedPreferenceManager().getDeviceId();

    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceInfo = <String, dynamic>{
          //'deviceID': deviceId,
          'OSVersion': build.version.sdkInt.toString(),
          'OSName': 'Android',
          'DevicePlatform': 'Android',
          'AppVersion': packageInfo.version,
          'DeviceTimezone': DateTime.now().timeZoneName,
          'DeviceCurrentTimestamp':
          new DateFormat("dd/MM/y HH:mm:ss").format(DateTime.now()),
          'currentFirebaseToken': firebaseToken,
          'ModelName': build.model
        };
      } else if (Platform.isIOS) {
        var build = await deviceInfoPlugin.iosInfo;
        deviceInfo = <String, dynamic>{
          //'deviceID': deviceId,
          'OSVersion': build.systemVersion,
          'OSName': 'iOS',
          'DevicePlatform': 'iOS',
          'AppVersion': packageInfo.version,
          'DeviceTimezone': DateTime.now().timeZoneName,
          'DeviceCurrentTimestamp':
          new DateFormat("dd/MM/y HH:mm:ss").format(DateTime.now()),
          'currentFirebaseToken': firebaseToken,
          'ModelName': build.utsname.machine
        };
      }

      if(deviceId != null){
        deviceInfo.putIfAbsent("deviceId", () => deviceId);
      }

      var metaData = <String, dynamic>{
        "metadata" : deviceInfo
      };

      final String timezone = await FlutterNativeTimezone.getLocalTimezone();
      metaData.putIfAbsent("timezone", () => timezone);

      _sendDeviceInfo(metaData);
    } on PlatformException catch(exc) {
      LogManager().log(_TAG, "_collectDeviceInfo", "Error while collecting device information.", e: exc);
      obsDeviceInfo.sink.add(ResultModel(error: AppStrings.device_error,));
    }
  }

  void _sendDeviceInfo(Map<String, dynamic> deviceInfo) async {
    LogManager().log(_TAG, "_sendDeviceInfo", "Call API for send device information.");
    final results = await _repository.sendDeviceData(deviceInfo);

    if(results.error != null){
      obsDeviceInfo.sink.add(results);
    }else{
      SharedPreferenceManager().setDeviceId(results.data.deviceId);
      obsDeviceInfo.sink.add(results);
    }
  }

  @override
  void dispose() {
    event.close();
    obsDeviceInfo.close();
  }
}