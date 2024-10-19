import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/admin/analytics/AnalyticsModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

class AnalyticsRepository {
  static const String TAG = "AnalyticsRepository";

  Future<ResultModel<AnalyticsModel>> getAnalyticsDetails() async {
    String exceptionString;
    var response;
    try {

      response = await http.post(Uri.parse(APIConstants.GET_ANALYTICS_DETAILS),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson<AnalyticsModel>.fromGetAnalyticsJson(
          json.decode(response.body));

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getAnalyticsDetails", "getAnalyticsDetails API success.");
        return ResultModel(data: base.data);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "getAnalyticsDetails", "getAnalyticsDetails API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getAnalyticsDetails", "Getting exception in getAnalyticsDetails API.", e: e);
      exceptionString = AppStrings.analyticsLoadingError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

}
