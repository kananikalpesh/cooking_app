
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/dashboard/DeviceInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_call_kit/flutter_call_kit.dart';

class AppData {
  static BuildContext appContext;
  static UserModel user;
  static PgStatus pgStatus;

  static P2PClient callClient;
  static P2PSession currentCall;
  static CubeUser cubeUser;

  static bool isProduction = true;

  ///Call_Kit
  static String callKitCurrentCallId;
  static FlutterCallKit callKit;

}