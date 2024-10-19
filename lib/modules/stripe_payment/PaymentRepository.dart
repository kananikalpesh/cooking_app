import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/stripe_payment/OnboardingModel.dart';
import 'package:cooking_app/modules/stripe_payment/PaymentModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

class PaymentRepository {
  static const String TAG = "PaymentRepository";

  Future<ResultModel<PaymentModel>> getPaymentDetails(Map<String, dynamic> userData) async {
    String exceptionString;
    var response;
    try {

      response = await http.post(Uri.parse(APIConstants.LESSON_BOOKING_PAYMENT),
          body: json.encode(userData),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson<PaymentModel>.fromGetPaymentDetailsJson(
          json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getPaymentDetails", "getPaymentDetails API success.");
        return ResultModel(data: base.data);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "getPaymentDetails", "getPaymentDetails API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getPaymentDetails", "Getting exception in getPaymentDetails API.", e: e);
      exceptionString = AppStrings.lessonPaymentError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }

  Future<ResultModel<OnboardingModel>> getOnBoardingDetails() async {
    String exceptionString;
    var response;
    try {

      response = await http.get(Uri.parse(APIConstants.ON_BOARDING_CREATE_ACCOUNT),
          headers: await ServerConnectionHelper.getHeaders());
      final base = BaseJson<OnboardingModel>.fromGetOnboardingDetailsJson(
          json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getOnBoardingDetails", "getOnBoardingDetails API success.");
        return ResultModel(data: base.data);
      } else {
        if (base.errors != null) {
          LogManager().log(TAG, "getOnBoardingDetails", "getOnBoardingDetails API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getOnBoardingDetails", "Getting exception in getOnBoardingDetails API.", e: e);
      exceptionString = AppStrings.onboardingPaymentError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }
  
}
