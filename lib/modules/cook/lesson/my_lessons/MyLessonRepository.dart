import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonListModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class MyLessonRepository{

  static const String TAG = "MyLessonRepository";

  Future<ResultModel<LessonListModel>> getMyLessons(Map<String, dynamic> data) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse(APIConstants.GET_MY_LESSONS),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getMyLessons", "getMyLessons API success.");
        var list = json.decode(response.body);
        return ResultModel(data: LessonListModel.fromJson(list));
      } else {
        final base = BaseJson<LessonDetailsModel>.fromGetLessonsJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "getMyLessons", "getMyLessons API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getMyLessons", "Getting exception in getMyLessons API.", e: e);
      exceptionString = AppStrings.cookMyLessonsError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }


  Future<ResultModel> deleteMyLesson(int lessonId) async {
    String exceptionString;
    http.Response response;
    try {

      response = await http.post(Uri.parse(APIConstants.DELETE_MY_LESSON+"/$lessonId"),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS){
        LogManager().log(TAG, "deleteMyLesson", "deleteMyLesson API success.");
        return ResultModel();
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "deleteMyLesson", "deleteMyLesson API error ${base.getErrorMessages()}.");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "deleteMyLesson", "Getting exception while deleting lesson API.", e: e);
      exceptionString =
          AppStrings.errorDeleteLesson + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ??
          AppStrings.pleaseTryAgain,
    );
  }

}