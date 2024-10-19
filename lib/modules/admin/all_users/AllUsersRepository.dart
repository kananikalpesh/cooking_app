import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/admin/all_users/AllUsersListModel.dart';
import 'package:cooking_app/modules/admin/all_users/FlaggedUsersListModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class AllUsersRepository{

  static const String TAG = "AllUsersRepository";

  Future<ResultModel<AllUsersListModel>> usersList(Map<String, dynamic> data) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse(APIConstants.GET_ALL_USERS_LIST),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "usersList", "usersList API success.");
        var list = json.decode(response.body);
        return ResultModel(data: AllUsersListModel.fromJson(list));
      } else {
        final base = BaseJson<UserModel>.fromGetAllUsersListJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "usersList", "usersList API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "usersList", "Getting exception in usersList API.", e: e);
      exceptionString = AppStrings.adminUsersListError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<FlaggedUsersListModel>> flaggedUsersList(Map<String, dynamic> data) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse(APIConstants.GET_FLAGGED_USERS_LIST),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "flaggedUsersList", "flaggedUsersList API success.");
        var list = json.decode(response.body);
        return ResultModel(data: FlaggedUsersListModel.fromJson(list));
      } else {
        final base = BaseJson<UserModel>.fromGetAllUsersListJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "flaggedUsersList", "flaggedUsersList API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "flaggedUsersList", "Getting exception in flaggedUsersList API.", e: e);
      exceptionString = AppStrings.adminUsersListError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel> deleteUser(Map<String, dynamic> data) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.DELETE_USER),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "deleteUser", "deleteUser API success.");
        return ResultModel();
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "deleteUser", "deleteUser API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "deleteUser", "Getting exception in deleteUser API.", e: e);
      exceptionString =
          AppStrings.errorDeleteUser + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel> blockUser(Map<String, dynamic> data) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.BLOCK_FLAGGED_USER),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "deleteUser", "deleteUser API success.");
        return ResultModel();
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "deleteUser", "deleteUser API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {

      LogManager().log(TAG, "deleteUser", "Getting exception in deleteUser API.", e: e);
      exceptionString =
          AppStrings.errorBlockUser + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel> ignoreUser(Map<String, dynamic> data) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.IGNORE_FLAGGED_USER),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "ignoreUser", "ignoreUser API success.");
        return ResultModel();
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "ignoreUser", "ignoreUser API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {

      LogManager().log(TAG, "ignoreUser", "Getting exception in ignoreUser API.", e: e);
      exceptionString =
          AppStrings.errorIgnoreUser + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

}