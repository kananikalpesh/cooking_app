import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

class AvailabilitiesRepository {
  static const String TAG = "AvailabilitiesRepository";

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

  Future<ResultModel<bool>> addAvailability(Map<String , dynamic> requestData) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.ADD_AVAILABILITY),
          body: json.encode(requestData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "addAvailability", "add Availability API success.");
        return ResultModel(data: true);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "addAvailability", "addAvailability API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "addAvailability", "Getting exception while adding Availability API.", e: e);
      exceptionString =
          AppStrings.errorAddAvailability + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<bool>> updateAvailability(Map<String , dynamic> requestData) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.UPDATE_AVAILABILITY),
          body: json.encode(requestData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "updateAvailability", "update Availability API success.");
        return ResultModel(data: true);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "updateAvailability", "updateAvailability API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "updateAvailability", "Getting exception while updating Availability API.", e: e);
      exceptionString =
          AppStrings.errorUpdateAvailability + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel> deleteAvailability(int availabilityId) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.DELETE_AVAILABILITY + "$availabilityId"),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "deleteAvailability", "delete Availability API success.");
        return ResultModel();
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "deleteAvailability", "deleteAvailability API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "deleteAvailability", "Getting exception while deleting Availability API.", e: e);
      exceptionString =
          AppStrings.errorDeleteAvailability + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

}
