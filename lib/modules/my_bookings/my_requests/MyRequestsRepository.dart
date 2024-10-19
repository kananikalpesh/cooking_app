import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/my_bookings/MyBookingsListModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class MyRequestsRepository{

  static const String TAG = "MyRequestsRepository";

  Future<ResultModel<MyBookingsListModel>> getMyRequests(Map<String, dynamic> data) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse(APIConstants.COOK_MY_BOOKINGS),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getMyRequests", "getMyRequests API success.");
        var list = json.decode(response.body);
        return ResultModel(data: MyBookingsListModel.fromJson(list));
      } else {
        final base = BaseJson<MyBookingDetailsModel>.fromGetMyBookingsJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "getMyRequests", "getMyRequests API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getMyRequests", "Getting exception in getMyRequests API.", e: e);
      exceptionString = AppStrings.cookMyRequestsError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<bool>> rejectBookingRequest(Map<String , dynamic> requestData) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.COOK_CANCEL_LESSON_BOOKING),
          body: json.encode(requestData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "rejectBookingRequest", "rejectBookingRequest API success.");
        return ResultModel(data: true);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "rejectBookingRequest", "rejectBookingRequest API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "rejectBookingRequest", "Getting exception in rejectBookingRequest API.", e: e);
      exceptionString =
          AppStrings.errorRejectingBooking + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<bool>> approveBookingRequest(Map<String , dynamic> requestData) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.COOK_APPROVE_LESSON_BOOKING),
          body: json.encode(requestData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "approveBookingRequest", "approveBookingRequest API success.");
        return ResultModel(data: true);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "approveBookingRequest", "approveBookingRequest API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "approveBookingRequest", "Getting exception in approveBookingRequest API.", e: e);
      exceptionString =
          AppStrings.errorApproveBooking + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

}