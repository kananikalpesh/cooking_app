import 'dart:convert';
import 'dart:io';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/model/shared_preferences/ServerPreferences.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UserProfileRepository {
  static const String TAG = "UserProfileRepository";

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

  Future<ResultModel> updateProfilePic(File selectedFile) async {
    String exceptionString;
    http.Response response;
    try {
      final length = await selectedFile.length();
      var filePath = selectedFile.path;
      var lastIndex = filePath.lastIndexOf("/");
      String fileName = filePath
          .substring((lastIndex + 1))
          .replaceAllMapped(" ", (match) => "");
      String extension = fileName.substring((fileName.lastIndexOf(".") + 1));
      String fileType = "Image";
      final request = http.MultipartRequest('POST', Uri.parse((APIConstants.UPLOAD_PROFILE_PIC)))
        ..files.add(http.MultipartFile('file', selectedFile.openRead(), length,
            filename: fileName, contentType: MediaType(fileType, extension)));

      request.headers['AV'] = await ServerPreferences().getAV();
      request.headers['Authorization'] = await ServerPreferences().getToken();

      response = await http.Response.fromStream(await request.send());

      if ((response.body == null || response.body.isEmpty) && response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS){
        LogManager().log(TAG, "updateProfilePic", "updateProfilePic API success.");
        return ResultModel();
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "updateProfilePic", "updateProfilePic API error ${base.getErrorMessages()}.");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "updateProfilePic", "Getting exception while in updateProfilePic API.", e: e);
      exceptionString =
          AppStrings.errorUploadPic + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ??
          AppStrings.pleaseTryAgain,
    );

  }

  Future<ResultModel<bool>> updateUserProfile(Map<String , dynamic> userData) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.UPDATE_PROFILE),
          body: json.encode(userData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_CREATED_SUCCESS) {
        LogManager().log(TAG, "updateUserProfile", "updateUserProfile API success.");
        return ResultModel(data: true);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "updateUserProfile", "updateUserProfile API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "updateUserProfile", "Getting exception while in updateUserProfile API.", e: e);
      exceptionString =
          AppStrings.updateProfileError + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<bool>> changePassword(Map<String , dynamic> userData) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.CHANGE_PASSWORD),
          body: json.encode(userData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "changePassword", "change password API success.");
        return ResultModel(data: true);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "changePassword", "change password API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "changePassword", "Getting exception while changing the password API.", e: e);
      exceptionString =
          AppStrings.changePassError + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }
}
