import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

class OtherCookProfileRepository {
  static const String TAG = "OtherCookProfileRepository";

  Future<ResultModel<UserModel>> getProfile(int userId) async {
    String exceptionString;
    var response;
    try {

      response = await http.get(Uri.parse(APIConstants.GET_PROFILE + "$userId"),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson<UserModel>.fromGetUserProfileJson(
          json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getProfile", "getProfile API success.");
        return ResultModel(data: base.data);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "getProfile", "getProfile API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getProfile", "Getting exception while in getProfile API.", e: e);
      exceptionString = AppStrings.profileLoadingError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }
}
