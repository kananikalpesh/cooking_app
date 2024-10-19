import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/dashboard/DeviceInfo.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

class DashboardRepository {
  static const _TAG = "DashboardRepository";

  Future<ResultModel<DeviceInfo>> sendDeviceData(
      Map<String, dynamic> deviceData) async {
    String exceptionString;
    var response;
    try {
      response = await http.post(Uri.parse(APIConstants.UPDATE_DEVICE_METADATA),
          body: json.encode(deviceData),
          headers: await ServerConnectionHelper.getHeaders());

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        final base =
        BaseJson<DeviceInfo>.fromDeviceInfoJson(json.decode(response.body));

          return ResultModel(data: base.data);
      } else {
        final base = BaseJson.fromDeviceInfoJson(json.decode(response.body));
        if (base.errors != null) {
          LogManager().log(_TAG, "sendDeviceData", "sendDeviceData API error ${base.getErrorMessages()}.");
          exceptionString = base.getErrorMessages();
        }
        exceptionString =
            ServerConnectionHelper.getDefaultHttpError(response.statusCode);
      }
    } catch (exc) {
      LogManager().log(_TAG, "sendDeviceData", "Getting exception while sending device data.", e: exc);
      exceptionString = AppStrings.couldNotSendInfo;
    }

    return ResultModel(
        errorCode: response?.statusCode,
        error: exceptionString ??
            AppStrings.pleaseTryAgain);
  }

}