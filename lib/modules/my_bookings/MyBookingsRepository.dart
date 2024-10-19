import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/my_bookings/MyBookingsListModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class MyBookingsRepository{

  static const String TAG = "MyBookingsRepository";

  Future<ResultModel<MyBookingsListModel>> getMyBookings(Map<String, dynamic> data) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse((AppData.user.role == AppConstants.ROLE_COOK) ?
      APIConstants.COOK_MY_BOOKINGS : APIConstants.USER_MY_BOOKINGS),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getMyBookings", "getMyBookings API success.");
        var list = json.decode(response.body);
        return ResultModel(data: MyBookingsListModel.fromJson(list));
      } else {
        final base = BaseJson<MyBookingDetailsModel>.fromGetLessonsJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "getMyBookings", "getMyBookings API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getMyBookings", "Getting exception in getMyBookings API.", e: e);
      exceptionString = AppStrings.cookMyBookingsError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<bool>> reportUserOrCook(Map<String , dynamic> requestData) async {
    String exceptionString;
    Response response;
    try {
      response = await http.post(Uri.parse(APIConstants.REPORT_USER_OR_COOK_TO_ADMIN),
          body: json.encode(requestData),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "reportUserOrCook", "reportUserOrCook API success.");
        return ResultModel(data: true);
      } else {

        final base = BaseJson.forNullResponse(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "reportUserOrCook", "reportUserOrCook API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {

      LogManager().log(TAG, "reportUserOrCook", "Getting exception in reportUserOrCook API.", e: e);
      exceptionString =
          ((AppData.user.role == AppConstants.ROLE_USER) ? AppStrings.errorReportingCook : AppStrings.errorReportingUser) + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

}