
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

class UserReviewsRepository{

  static const String TAG = "UserReviewsRepository";

  Future<ResultModel<ReviewListModel>> getUserCookReviews(Map<String, dynamic> data, bool isCook) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse( (isCook) ? APIConstants.GET_OTHER_COOK_REVIEWS :  APIConstants.GET_OTHER_USER_REVIEWS),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getUserCookReviews", "getUserCookReviews API success.");
        var list = json.decode(response.body);
        return ResultModel(data: ReviewListModel.fromJson(list));
      } else {
        final base = BaseJson<ReviewModel>.fromGetLessonsJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "getUserCookReviews", "getUserCookReviews API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getUserCookReviews", "Getting exception in getUserCookReviews API.", e: e);
      exceptionString = AppStrings.otherUserReviewsError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

}