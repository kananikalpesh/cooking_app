import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/model/shared_preferences/SharedPreference.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

const _TAG = "PasswordRepository";
class PasswordRepository {

  Future<ResultModel<UserModel>> loginWithPassword(Map<String, dynamic> userData) async {

    String exceptionString;
    var response;

    try {
      var headers = await ServerConnectionHelper.getHeadersUnauthorized();
      response = await http.post(Uri.parse(APIConstants.LOGIN_WITH_PASSWORD),
          body: json.encode(userData),
          headers: await ServerConnectionHelper.getHeadersUnauthorized());

      final base = BaseJson<UserModel>.fromUserModelJson(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {

        ServerConnectionHelper.setHeaders(base.data.token, response.headers);
        await SharedPreferenceManager().setUser(base.data);
        await SharedPreferenceManager().setLoggedIn(true);
        LogManager().log(_TAG, "loginWithPassword", "Success response for login with password.");
        return ResultModel(data: base.data);
      } else {
        if (base.errors != null) {

          LogManager().log(_TAG, "loginWithPassword", "Getting error for login with password- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (exc) {
      LogManager().log(_TAG, "loginWithPassword", "Getting exception while requesting for login with password.", e: exc);
      exceptionString = AppStrings.errorLoginWithPassword + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
        errorCode: response?.statusCode,
        error: exceptionString ?? AppStrings.pleaseTryAgain
    );
  }

}
