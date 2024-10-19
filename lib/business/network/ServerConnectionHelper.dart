
import 'dart:io';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/shared_preferences/ServerPreferences.dart';
import 'package:cooking_app/model/shared_preferences/SharedPreference.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:cooking_app/utils/ConCubeUtils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ServerConnectionHelper{

  static void setHeaders(String token, Map<String, String> headers){
    ServerPreferences().setToken("Token token=${token}");
    log("ServerConnectionHelper headers['AV'] = ${headers['AV']}");
    ServerPreferences().setAV(headers['AV']);
  }

  static Future<Map<String, String>> getHeaders() async{
    return {
      "Content-type": "application/json",
      "AV" : await ServerPreferences().getAV(),
      "Authorization" : await ServerPreferences().getToken()
    };
  }

  static handleDefaultServerError(BuildContext context, ResultModel resultModel){
    CommonBottomSheet.showErrorBottomSheet(context, resultModel);
  }

  static String getDefaultHttpError(int error){
    return 'Getting default http error- $error';
  }

  static Future<Map<String, String>> getHeadersUnauthorized() async{
    return  {
      "Content-type": "application/json",
      "AV" : await ServerPreferences().getAV(),
    };

  }

  static void handleDefaultException(BuildContext context, String exception) {

    if(exception is SocketException){
      CommonBottomSheet.showErrorBottomSheet(context, ResultModel(error: '$exception',));
    }else{
      CommonBottomSheet.showErrorBottomSheet(context, ResultModel(error: '$exception',));
    }
  }

  static String getDefaultException(BuildContext context, Exception exception) {

    if(exception is SocketException){
      return 'We are facing technical difficulty at the moment, please try again after some time.';
    }else{
      return 'We are facing technical difficulty at the moment, please try again after some time.';
    }
  }

  static void resetHeaders() {
    ServerPreferences().setAV("");
    ServerPreferences().setToken("");
  }

  static Future handleUnAuthorizedStatusCode(BuildContext context) async {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleLogin);

    resetHeaders();


    int id = await SharedPreferenceManager().getCCSubscriptionId();
    deleteSubscription(id);

    await SharedPreferenceManager().clearPreferences();

    ConCubeUtils.logoutConCube();

    Navigator.of(context).pushNamedAndRemoveUntil(
        '/LauncherScreen', (Route<dynamic> route) => false);
  }
}