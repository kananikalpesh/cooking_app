import 'dart:convert';

import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/BaseJson.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/model/shared_preferences/SharedPreference.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:http/http.dart' as http;

const _TAG = "ConCubeRepository";
class ConCubeRepository {
  Future<ResultModel<bool>> updateCCUserId(UserModel userModel) async {
    String exceptionString;
    var response;

    try {
      response = await http.post(Uri.parse(APIConstants.UPDATE_CC_ID),
          body: json.encode(<String, dynamic>{
            "c": AppData.cubeUser.id
          }),
          headers: await ServerConnectionHelper.getHeaders());

      final base = BaseJson.forNullResponse(json.decode(response.body));

      if (response.statusCode == APIConstants.STATUS_CODE_API_SUCCESS) {
        userModel.ccId = AppData.cubeUser.id;
        AppData.user = userModel;
        await SharedPreferenceManager().setUser(userModel);
        LogManager().log(_TAG, "updateCCUserId", "Success response for update cc user id.");
        return ResultModel(data: true);
      } else {
        if (base.errors != null) {

          LogManager().log(_TAG, "updateCCUserId", "Getting error for updateCCUserId- ${base.getErrorMessages()}");
          exceptionString = base.getErrorMessages();
        }
      }
    } catch (e) {
      LogManager().log(_TAG, "updateCCUserId", "Getting exception while updating cc user id.", e: e);
      exceptionString =
          AppStrings.couldNotUpdateCCId + " " + AppStrings.pleaseTryAgain;
    }

      return ResultModel(
        errorCode: response?.statusCode,
        error: exceptionString ?? AppStrings.pleaseTryAgain,
      );

  }
}