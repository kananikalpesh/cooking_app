
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/login/password/PasswordRepository.dart';
import 'package:cooking_app/modules/login/register/RegisterModel.dart';
import 'package:cooking_app/utils/ConCubeUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';

import 'RegisterRepository.dart';

const _TAG = "RegisterBloc";
class RegisterBloc extends Bloc {
  static const String REGISTER_EVENT = "register_user";
  static const String PASSWORD_EVENT = "login_password";
  static const String REGISTER_CC = "register_cc";
  static const String GET_COUNTRY_LIST_EVENT = "get_country_list";

  final _repository = RegisterRepository();
  final _loginRepository = PasswordRepository();

  final event = PublishSubject<EventModel>();
  final obsRegister = BehaviorSubject<ResultModel<RegisterModel>>();
  final obsPassword = BehaviorSubject<ResultModel<UserModel>>();
  final obsRegisterCCId = BehaviorSubject<ResultModel<bool>>();
  final obsCountryList = BehaviorSubject<ResultModel<List<String>>>();

  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<bool> isLoadingForCountries = ValueNotifier(false);

  RegisterBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case REGISTER_EVENT:
          _handleRegister(event.data);
          break;
        case PASSWORD_EVENT:
          _handleLogin(event.data);
          break;
        case REGISTER_CC:
          LogManager().log(_TAG, "RegisterBloc", "Connectycube registration.");
          ConCubeUtils.handleRegisterCC(event.data, obsRegisterCCId);
          break;
        case GET_COUNTRY_LIST_EVENT:
          _getCountries();
          break;
      }
    });
  }

  _handleRegister(Map<String, dynamic> userData) async {
    LogManager().log(_TAG, "_handleRegister", "Call API for register user.");
    isLoading.value = true;
    ResultModel resultModel = await _repository.registerUser(userData);
    obsRegister.sink.add(resultModel);
  }

  _handleLogin(Map<String, dynamic> userData) async {
    LogManager().log(_TAG, "_handleLogin", "Call API for login with password.");
    ResultModel resultModel = await _loginRepository.loginWithPassword(userData);
    obsPassword.sink.add(resultModel);
    isLoading.value = false;
  }

  _getCountries() async {
    isLoadingForCountries.value = true;
    ResultModel resultModel = await _repository.getCountries();
    obsCountryList.sink.add(resultModel);
    isLoadingForCountries.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsRegister.close();
    obsPassword.close();
    obsRegisterCCId.close();
    isLoading.dispose();
    isLoadingForCountries.dispose();
    obsCountryList.close();
  }
}
