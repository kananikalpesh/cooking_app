
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/login/password/PasswordRepository.dart';
import 'package:cooking_app/utils/ConCubeUtils.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import 'SetPasswordRepository.dart';

const _TAG = "SetPasswordBloc";
class SetPasswordBloc extends Bloc {
  static const String PASSWORD_EVENT = "set_password";
  static const String LOGIN_WITH_PASSWORD_EVENT = "login_password";
  static const String REGISTER_CC = "register_cc";

  final _repository = SetPasswordRepository();
  final _loginRepository = PasswordRepository();

  final event = PublishSubject<EventModel>();
  final obsPassword = BehaviorSubject<ResultModel<UserModel>>();
  final obsLogin = BehaviorSubject<ResultModel<UserModel>>();
  final obsRegisterCCId = BehaviorSubject<ResultModel<bool>>();

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  SetPasswordBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case PASSWORD_EVENT:
          _handleSetPassword(event.data);
          break;
        case LOGIN_WITH_PASSWORD_EVENT:
          _handleLogin(event.data);
          break;
        case REGISTER_CC:
          LogManager().log(_TAG, "SetPasswordBloc", "Connectycube registration.");
          ConCubeUtils.handleRegisterCC(event.data, obsRegisterCCId);
          break;
      }
    });
  }

  _handleSetPassword(Map<String, dynamic> userData) async {
    LogManager().log(_TAG, "_handleSetPassword", "Call API for set new password.");
    ResultModel resultModel = await _repository.setNewPassword(userData);
    obsPassword.sink.add(resultModel);
  }

  _handleLogin(Map<String, dynamic> userData) async {
    LogManager().log(_TAG, "_handleLogin", "Call API for login with password.");
    ResultModel resultModel = await _loginRepository.loginWithPassword(userData);
    obsLogin.sink.add(resultModel);
    isLoading.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsPassword.close();
    obsRegisterCCId.close();
    isLoading.dispose();
    obsLogin.close();
  }
}
