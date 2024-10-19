import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/shared_preferences/SharedPreference.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

class LogoutRepository {
  static const String TAG = "LogoutRepository";

  Future<ResultModel> logout() async {
    String exceptionString;
    var response;
    try {
      String deviceId =  await SharedPreferenceManager().getDeviceId();
      response = await http.delete(Uri.parse(APIConstants.LOGOUT),
          body: json.encode(<String, dynamic>{"deviceId" : deviceId}),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "logout", "logout API success.");
        return ResultModel();
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "logout", "logout API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "logout", "Getting exception in logout API.", e: e);
      exceptionString =
          AppStrings.logoutError + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

}
