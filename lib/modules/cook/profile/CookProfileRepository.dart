import 'dart:convert';
import 'dart:io';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/AttachmentModel.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/model/shared_preferences/ServerPreferences.dart';
import 'package:cooking_app/modules/user/home/TagsModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CookProfileRepository {
  static const String TAG = "CookProfileRepository";

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

  Future<ResultModel<TagsModel>> getCuisineDietList() async {
    String exceptionString;
    var response;
    try {

      response = await http.get(Uri.parse(APIConstants.GET_CUISINE_DIET_LIST),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson<TagsModel>.fromGetHomeTagsJson(
          json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getCuisineDietList", "getCuisineDietList API success.");
        return ResultModel(data: base.data);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "getCuisineDietList", "getCuisineDietList API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getCuisineDietList", "Getting exception in getCuisineDietList API.", e: e);
      exceptionString = AppStrings.tagsLoadingError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel> addMedia(File selectedFile) async {
    String exceptionString;
    http.Response response;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(APIConstants.ADD_MEDIA + "${AppData.user.id}"));
      request.files.add(await http.MultipartFile.fromPath('cook_profile_image', selectedFile.path));

      request.headers.addAll({
        "AV" : await ServerPreferences().getAV(),
        "Authorization" : await ServerPreferences().getToken()
      });

      response = await http.Response.fromStream(await request.send());

      if (response.statusCode == APIConstants.STATUS_CODE_CREATED_SUCCESS){

        LogManager().log(TAG, "addMedia", "add Media API success.");
        final cookImageModel = AttachmentModel.fromJson(json.decode(response.body));
        return ResultModel(data: cookImageModel);
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {

          LogManager().log(TAG, "addMedia", "add Media API error ${base.getErrorMessages()}.");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "addMedia", "Getting exception in add Media API.", e: e);
      exceptionString =
          AppStrings.errorAddCookMedia + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ??
          AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<bool>> deleteMedia(Map<String , dynamic> requestData) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.DELETE_MEDIA + "${AppData.user.id}"),
          body: json.encode(requestData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "deleteMedia", "delete Media API success.");
        return ResultModel();
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "deleteMedia", "deleteMedia API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "deleteMedia", "Getting exception while deleting Media API.", e: e);
      exceptionString =
          AppStrings.errorDeleteMedia + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

}
