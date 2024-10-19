import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

const _TAG = "ForgotPasswordRepository";
class ForgotPasswordRepository {

  Future<ResultModel<bool>> forgotPassword(Map<String, dynamic> requestData) async {

    String exceptionString;
    var response;

    try {
      response = await http.post(Uri.parse(APIConstants.FORGOT_PASSWORD),
          body: json.encode(requestData),
          headers: await ServerConnectionHelper.getHeadersUnauthorized());

      final base = BaseJson.forNullResponse(json.decode(response.body));
      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(_TAG, "forgotPassword", "Success response for forgot password.");
        return ResultModel(data: true);
      } else {
        if (base.errors != null) {
          LogManager().log(_TAG, "forgotPassword", "Getting error for forgot password- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (exc) {
      LogManager().log(_TAG, "forgotPassword", "Getting exception while requesting for forgot password.", e: exc);
      exceptionString = AppStrings.errorForgotPass + " " + AppStrings.pleaseTryAgain;
    }

    return ResultModel(
        errorCode: response?.statusCode,
        error: exceptionString ?? AppStrings.pleaseTryAgain
    );
  }

}
