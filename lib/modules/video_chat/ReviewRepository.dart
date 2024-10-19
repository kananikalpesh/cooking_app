import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

class ReviewRepository{

  static const String TAG = "ReviewRepository";

  Future<ResultModel> addReview(Map<String, dynamic> data) async {
    String exceptionString;
    http.Response response;
    try {

      response = await http.post(Uri.parse(((AppData.user.role == AppConstants.ROLE_COOK)
          ? APIConstants.ADD_USER_REVIEW
          : APIConstants.ADD_COOK_AND_LESSON_REVIEW)),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_CREATED_SUCCESS){
        LogManager().log(TAG, "addReview", "addReview API success.");
        return ResultModel();
      } else {
        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "addReview", "addReview API error ${base.getErrorMessages()}.");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "addReview", "Getting exception while addReview API.", e: e);
      exceptionString =
          AppStrings.errorAddReview + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      error: exceptionString ??
          AppStrings.pleaseTryAgain,
    );
  }

}