import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonListModel.dart';
import 'package:cooking_app/modules/user/lesson/details/BookingStatusModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class LessonDetailsRepository {
  static const String TAG = "LessonDetailsRepository";

  Future<ResultModel<LessonDetailsModel>> getLessonDetails(Map<String, dynamic> userData) async {
    String exceptionString;
    var response;
    try {

      response = await http.post(Uri.parse(APIConstants.GET_LESSON_DETAILS),
          body: json.encode(userData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson<LessonDetailsModel>.fromGetLessonDetailsJson(
          json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getLessonDetails", "getLessonDetails API success.");
        return ResultModel(data: base.data);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "getLessonDetails", "getLessonDetails API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getLessonDetails", "Getting exception while in getLessonDetails API.", e: e);
      exceptionString = AppStrings.lessonLoadingError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }
  
  Future<ResultModel<LessonListModel>> getOtherLessonsList(Map<String, dynamic> userData) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse(APIConstants.GET_OTHER_LESSONS),
          body: json.encode(userData),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getOtherLessonsList", "getOtherLessonsList API success.");
        var list = json.decode(response.body);
        return ResultModel(data: LessonListModel.fromJson(list));
      } else {
        final base = BaseJson<LessonDetailsModel>.fromGetLessonsJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "getOtherLessonsList", "getOtherLessonsList API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getOtherLessonsList", "Getting exception in getOtherLessonsList API.", e: e);
      exceptionString = AppStrings.cookLoadingError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<bool>> cancelBookingRequest(Map<String , dynamic> requestData, bool isFromCook) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse((isFromCook) ? APIConstants.COOK_CANCEL_LESSON_BOOKING : APIConstants.CANCEL_BOOKING_REQUEST),
          body: json.encode(requestData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "cancelBookingRequest", "cancelBookingRequest API success.");
        return ResultModel(data: true);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "cancelBookingRequest", "cancelBookingRequest API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "cancelBookingRequest", "Getting exception in cancelBookingRequest API.", e: e);
      exceptionString =
          AppStrings.errorCancelBooking + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<BookingStatusModel>> getBookingDetails(Map<String, dynamic> userData) async {
    String exceptionString;
    var response;
    try {

      response = await http.post(Uri.parse(APIConstants.GET_BOOKING_DETAILS),
          body: json.encode(userData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson<BookingStatusModel>.fromGetBookingDetailsJson(
          json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getBookingDetails", "getBookingDetails API success.");
        return ResultModel(data: base.data);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "getBookingDetails", "getBookingDetails API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getBookingDetails", "Getting exception in getBookingDetails API.", e: e);
      exceptionString = AppStrings.bookingLoadingError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }
  
}
