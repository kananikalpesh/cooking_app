
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/utils/ConCubeUtils.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import 'PasswordRepository.dart';

const _TAG = "PasswordBloc";
class PasswordBloc extends Bloc {
  static const String PASSWORD_EVENT = "login_password";
  static const String REGISTER_CC = "register_cc";

  final _repository = PasswordRepository();

  final event = PublishSubject<EventModel>();
  final obsPassword = BehaviorSubject<ResultModel<UserModel>>();
  final obsRegisterCCId = BehaviorSubject<ResultModel<bool>>();

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  PasswordBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case PASSWORD_EVENT:
          _handlePassword(event.data);
          break;

        case REGISTER_CC:
          LogManager().log(_TAG, "PasswordBloc", "Connectycube registration.");
          ConCubeUtils.handleRegisterCC(event.data, obsRegisterCCId);
          break;
      }
    });
  }

  _handlePassword(Map<String, dynamic> userData,) async {
    LogManager().log(_TAG, "_handlePassword", "Call API for login with password.");
    isLoading.value = true;
    ResultModel resultModel = await _repository.loginWithPassword(userData);
    obsPassword.sink.add(resultModel);
    isLoading.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsPassword.close();
    obsRegisterCCId.close();
    isLoading.dispose();
  }
}
