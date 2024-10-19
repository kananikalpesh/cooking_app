import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonListModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:dio/dio.dart';

class SearchLessonRepository {
  static const String TAG = "SearchLessonRepository";

  CancelToken searchLessonToken;

  Future<ResultModel<LessonListModel>> getLessonsList(Map<String, dynamic> userData) async {
    String exceptionString;
    Response response;
    try {
      searchLessonToken?.cancel(AppStrings.cancelTokenMsg);
      searchLessonToken = new CancelToken();
      response = await Dio().post(APIConstants.GET_SEARCHED_LESSONS_LIST,
          data: userData,
          options: Options(headers: await ServerConnectionHelper.getHeaders()),
          cancelToken: searchLessonToken
      );

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getLessonsList", "getLessonsList API success.");
        var list = response.data;
        return ResultModel(data: LessonListModel.fromJson(list));
      } else {
        final base = BaseJson<LessonDetailsModel>.fromGetLessonsJson(response.data);
        if (base.errors != null) {
          LogManager().log(TAG, "getLessonsList", "getLessonsList API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      if (e is DioError && CancelToken.isCancel(e)) {
        LogManager().log(TAG, "getLessonsList", "API Request canceled!.",);
      } else {
        LogManager().log(TAG, "getLessonsList", "Getting exception in getLessonsList API.", e: e);
        exceptionString = AppStrings.searchLoadingError +
            " " +
            AppStrings.pleaseTryAgain;
      }
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? "",
    );
  }

}
