import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/admin/payments/PaymentListModel.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class PaymentListRepository{

  static const String TAG = "PaymentListRepository";

  Future<ResultModel<PaymentListModel>> getPaymentsList(Map<String, dynamic> data) async {
    String exceptionString;
    Response response;
    try {

      response = await http.post(Uri.parse(APIConstants.GET_PAYMENTS_LIST),
          body: json.encode(data),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        LogManager().log(TAG, "getPaymentsList", "getPaymentsList API success.");
        var list = json.decode(response.body);
        return ResultModel(data: PaymentListModel.fromJson(list));
      } else {
        final base = BaseJson<AdminPaymentDetailsModel>.fromGetPaymentListJson(
            json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(TAG, "getPaymentsList", "getPaymentsList API error- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(TAG, "getPaymentsList", "Getting exception in getPaymentsList API.", e: e);
      exceptionString = AppStrings.adminPaymentListError +
          " " +
          AppStrings.pleaseTryAgain;
    }

    return ResultModel(
      errorCode: response?.statusCode,
      error: exceptionString ?? AppStrings.pleaseTryAgain,
    );
  }
}