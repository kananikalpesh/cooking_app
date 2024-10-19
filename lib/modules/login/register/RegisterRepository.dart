import 'dart:convert';

import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/modules/login/register/RegisterModel.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:http/http.dart' as http;

const _TAG = "RegisterRepository";
class RegisterRepository {

  Future<ResultModel<RegisterModel>> registerUser(Map<String, dynamic> userData) async {

    String exceptionString;
    var response;

    try {
      response = await http.post(Uri.parse(APIConstants.REGISTER_USER),
          body: json.encode(userData),
          headers: await ServerConnectionHelper.getHeadersUnauthorized());

      final base = BaseJson<RegisterModel>.fromRegisterModelJson(json.decode(response.body));

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS || response.statusCode == APIConstants.STATUS_CODE_CREATED_SUCCESS) {

        LogManager().log(_TAG, "registerUser", "Success response for register new user.");
        return ResultModel(data: base.data);
      } else {
        if (base.errors != null) {
          LogManager().log(_TAG, "registerUser", "Getting error for register new user- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (exc) {
      LogManager().log(_TAG, "registerUser", "Getting exception while registering new user.", e: exc);
      exceptionString = AppStrings.errorRegister + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
        errorCode: response?.statusCode,
        error: exceptionString ?? AppStrings.pleaseTryAgain
    );
  }

  Future<ResultModel<List<String>>> getCountries() async {

    String exceptionString;
    var response;

    try {
      response = await http.get(Uri.parse(APIConstants.GET_COUNTRIES_LIST),
          headers: await ServerConnectionHelper.getHeadersUnauthorized());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS || response.statusCode == APIConstants.STATUS_CODE_CREATED_SUCCESS) {
        final base = BaseJson<List<String>>.fromCountries(successJson: json.decode(response.body));
        LogManager().log(_TAG, "getCountries", "Success response for getCountries.");
        return ResultModel(data: base.data);
      } else {
        final base = BaseJson<List<String>>.fromCountries(errorJson: json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(_TAG, "getCountries", "Getting error for getCountries- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (exc) {
      LogManager().log(_TAG, "getCountries", "Getting exception in getCountries.", e: exc);
      exceptionString = AppStrings.errorCountriesList + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
        errorCode: response?.statusCode,
        error: exceptionString ?? AppStrings.pleaseTryAgain
    );
  }

}
