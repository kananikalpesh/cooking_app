
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

class OtherCookLessonRepository{

  static const String TAG = "OtherCookLessonRepository";

  Future<ResultModel<LessonListModel>> getOtherCookLessons(Map<String, dynamic> data) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse(APIConstants.GET_OTHER_LESSONS),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getOtherCookLessons", "getOtherCookLessons API success.");
        var list = json.decode(response.body);
        return ResultModel(data: LessonListModel.fromJson(list));
      } else {
        final base = BaseJson<LessonDetailsModel>.fromGetLessonsJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "getOtherCookLessons", "getOtherCookLessons API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getOtherCookLessons", "Getting exception in getOtherCookLessons API.", e: e);
      exceptionString = AppStrings.otherCookLessonsError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

}