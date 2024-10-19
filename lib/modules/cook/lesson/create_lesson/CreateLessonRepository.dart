import 'dart:convert';
import 'dart:io';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/AttachmentModel.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/shared_preferences/ServerPreferences.dart';
import 'package:cooking_app/modules/user/home/TagsModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CreateLessonRepository{

  static const String TAG = "CreateLessonRepository";

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

  Future<ResultModel> createLesson(Map<String, dynamic> lessonData, List<File> selectedFiles) async {
    String exceptionString;
    http.Response response;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(APIConstants.CREATE_LESSON));
      request.fields.addAll({
        'lesson_data': json.encode(lessonData)
      });
      for (File file in selectedFiles) {
        request.files.add(await http.MultipartFile.fromPath('lesson_images[]', file.path));
      }
      request.headers.addAll({
        "AV" : await ServerPreferences().getAV(),
        "Authorization" : await ServerPreferences().getToken()
      });

      response = await http.Response.fromStream(await request.send());
      if (response.statusCode == APIConstants.STATUS_CODE_CREATED_SUCCESS){
        LogManager().log(TAG, "createLesson", "createLesson API success.");
        return ResultModel();
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "createLesson", "createLesson API error ${base.getErrorMessages()}.");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "createLesson", "Getting exception while creating lesson API.", e: e);
      exceptionString =
          AppStrings.errorUploadPic + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ??
          AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel> updateLesson(Map<String, dynamic> updateLessonData, int lessonId) async {
    String exceptionString;
    http.Response response;
    try {
      response = await http.post(Uri.parse(APIConstants.UPDATE_MY_LESSONS+"/$lessonId"),
          body: json.encode(updateLessonData),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS){
        LogManager().log(TAG, "updateLesson", "updateLesson API success.");
        return ResultModel();
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "updateLesson", "updateLesson API error ${base.getErrorMessages()}.");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "updateLesson", "Getting exception while update lesson API.", e: e);
      exceptionString =
          AppStrings.errorUploadPic + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ??
          AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel> uploadLessonImage(int lessonId, File selectedFile, String fileMediaType) async {
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
      String fileType = "$fileMediaType";

      final request = http.MultipartRequest('POST', Uri.parse((APIConstants.UPLOAD_MY_LESSON_IMAGE)))
        ..files.add(http.MultipartFile('lesson_image', selectedFile.openRead(), length,
            filename: fileName, contentType: MediaType(fileType, extension)));

            request.fields.addAll({
        'lesson': "$lessonId"
      });

      request.headers.addAll({
        "AV" : await ServerPreferences().getAV(),
        "Authorization" : await ServerPreferences().getToken()
      });

      response = await http.Response.fromStream(await request.send());

      if ((response.statusCode == APIConstants.STATUS_CODE_CREATED_SUCCESS)){
        LogManager().log(TAG, "uploadLessonImage", "uploadLessonImage API success.");
        final lessonImageModel = AttachmentModel.fromJson(json.decode(response.body));
        return ResultModel(data: lessonImageModel);
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "uploadLessonImage", "uploadLessonImage API error ${base.getErrorMessages()}.");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "uploadLessonImage", "Getting exception while in uploadLessonImage API.", e: e);
      exceptionString =
          AppStrings.errorUploadImage + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ??
          AppStrings.pleaseTryAgain,
    );

  }

  Future<ResultModel> deleteLessonImage(int lessonId, int imageId) async {
    String exceptionString;
    http.Response response;
    try {
      response = await http.post(Uri.parse(APIConstants.DELETE_MY_LESSON_IMAGE),
          body: json.encode(<String, dynamic>{"l": lessonId, "li": imageId}),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS){
        LogManager().log(TAG, "deleteLessonImage", "deleteLessonImage API success.");
        return ResultModel();
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "deleteLessonImage", "deleteLessonImage API error ${base.getErrorMessages()}.");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "deleteLessonImage", "Getting exception while deleting lesson image API.", e: e);
      exceptionString =
          AppStrings.errorDeleteImage + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ??
          AppStrings.pleaseTryAgain,
    );
  }
}