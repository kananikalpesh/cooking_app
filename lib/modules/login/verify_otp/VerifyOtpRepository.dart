import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

const _TAG = "VerifyOtpRepository";
class VerifyOtpRepository {

  Future<ResultModel<bool>> verifyOtp(Map<String, dynamic> userData) async {

    String exceptionString;
    var response;

    try {
      response = await http.post(Uri.parse(APIConstants.VERIFY_OTP),
          body: json.encode(userData),
          headers: await ServerConnectionHelper.getHeadersUnauthorized());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(_TAG, "verifyOtp", "Success response for verify otp.");
        return ResultModel(data: base.data);
      } else {
        if (base.errors != null) {
          LogManager().log(_TAG, "verifyOtp", "Getting error while verifying otp- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (exc) {
      LogManager().log(_TAG, "verifyOtp", "Getting exception while requesting for verify otp.", e: exc);
      exceptionString = AppStrings.errorVerifyOtp + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
        errorCode: response?.statusCode,
        error: exceptionString ?? AppStrings.pleaseTryAgain
    );
  }

  Future<ResultModel<bool>> resendOtp(Map<String, dynamic> requestData) async {
    String exceptionString;
    var response;

    try {
      response = await http.post(Uri.parse(APIConstants.FORGOT_PASSWORD),
          body: json.encode(requestData),
          headers: await ServerConnectionHelper.getHeadersUnauthorized());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(_TAG, "resendOtp", "Success response for resend otp.");

        return ResultModel(data: true);
      } else {
        if (base.errors != null) {
          LogManager().log(_TAG, "resendOtp", "Getting customized error for resend otp- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (exc) {
      LogManager().log(_TAG, "resendOtp", "Getting exception while requesting for resend otp.", e: exc);
      exceptionString = AppStrings.errorResendOtp + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
        errorCode: response?.statusCode,
        error: exceptionString ?? AppStrings.pleaseTryAgain
    );
  }

}
