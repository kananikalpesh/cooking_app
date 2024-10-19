import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/AvailableSlotsListModel.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/CalendarDateModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class BookLessonRepository{

  static const String TAG = "BookLessonRepository";

  Future<ResultModel<AvailableSlotsListModel>> getTimeSlots(Map<String, dynamic> data) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse(APIConstants.GET_AVAILABLE_SLOTS),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getTimeSlots", "getTimeSlots API success.");
        var data = json.decode(response.body);
        return ResultModel(data: AvailableSlotsListModel.fromJson(data));
      } else {
        final base = BaseJson<AvailableSlotModel>.fromGetAvailableSlotJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "getTimeSlots", "getTimeSlots API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {

      LogManager().log(TAG, "getTimeSlots", "Getting exception in getTimeSlots API.", e: e);
      exceptionString = AppStrings.availableSlotsError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<bool>> requestLessonBooking(Map<String , dynamic> userData) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.BOOK_LESSON_REQUEST),
          body: json.encode(userData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_CREATED_SUCCESS) {
        LogManager().log(TAG, "requestLessonBooking", "requestLessonBooking API success.");
        return ResultModel(data: true);
      } else if (response.statusCode == APIConstants.STATUS_CODE_COUNTRY_NOT_SUPPORTED) {
        LogManager().log(TAG, "requestLessonBooking", "Stripe does not support user's country- show error screen.");
        return ResultModel(errorCode: response.statusCode, error: base.getErrorMessages());
      } else if (response.statusCode == APIConstants.STATUS_CODE_ADDRESS_NEEDED) {
        LogManager().log(TAG, "requestLessonBooking", "Address needed- go to edit address screen.");
        return ResultModel(errorCode: response.statusCode, error: base.getErrorMessages());
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "requestLessonBooking", "requestLessonBooking API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "requestLessonBooking", "Getting exception while requestLessonBooking API.", e: e);
      exceptionString =
          AppStrings.bookLessonError + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<CalendarDateModel>> getCalenderDates(Map<String, dynamic> data) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse(APIConstants.CALENDER_DATES),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getCalenderDates", "getCalenderDates API success.");
        var data = BaseJson<CalendarDateModel>.fromCalenderDateJson(json.decode(response.body));
        return ResultModel(data: data.data);
      } else {
        final base = BaseJson<CalendarDateModel>.fromGetAvailableSlotJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "getCalenderDates", "getCalenderDates API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getCalenderDates", "Getting exception in getCalenderDates API.", e: e);
      exceptionString = AppStrings.calenderDatesError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

}