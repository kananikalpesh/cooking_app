
import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/cook/profile/other_user/other_cook_reviews/ReviewListModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class OtherCookReviewRepository{

  static const String TAG = "OtherCookReviewRepository";

  Future<ResultModel<ReviewListModel>> getOtherCookReviews(Map<String, dynamic> data) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse(APIConstants.GET_OTHER_COOK_REVIEWS),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getOtherCookReviews", "getOtherCookReviews API success.");
        var list = json.decode(response.body);
        return ResultModel(data: ReviewListModel.fromJson(list));
      } else {
        final base = BaseJson<ReviewModel>.fromGetLessonsJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "getOtherCookReviews", "getOtherCookReviews API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getOtherCookReviews", "Getting exception in getOtherCookReviews API.", e: e);
      exceptionString = AppStrings.otherCookReviewsError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

}