import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

class UserAddressRepository {
  static const String TAG = "UserAddressRepository";
  
  Future<ResultModel<bool>> updateAddress(Map<String , dynamic> userData) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.UPDATE_ADDRESS),
          body: json.encode(userData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_CREATED_SUCCESS || response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "updateAddress", "updateAddress API success.");
        return ResultModel(data: true);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "updateAddress", "updateAddress API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "updateAddress", "Getting exception in updateAddress API.", e: e);
      exceptionString =
          AppStrings.updateAddressError + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
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
        LogManager().log(TAG, "getCountries", "Success response for getCountries.");
        return ResultModel(data: base.data);
      } else {
        final base = BaseJson<List<String>>.fromCountries(errorJson: json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "getCountries", "Getting error for getCountries- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (exc) {
      LogManager().log(TAG, "getCountries", "Getting exception in getCountries.", e: exc);
      exceptionString = AppStrings.errorCountriesList + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
        errorCode: response?.statusCode,
        error: exceptionString ?? AppStrings.pleaseTryAgain
    );
  }

}
