
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import 'ForgotPasswordRepository.dart';

const _TAG = "ForgotPasswordBloc";
class ForgotPasswordBloc extends Bloc {
  static const String FORGOT_PASSWORD_EVENT = "forgot_password";

  final _repository = ForgotPasswordRepository();

  final event = PublishSubject<EventModel>();
  final obsForgotPassword = BehaviorSubject<ResultModel<bool>>();

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  ForgotPasswordBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case FORGOT_PASSWORD_EVENT:
          _handleForgotPassword(event.data);
          break;
      }
    });
  }

  _handleForgotPassword(Map<String, dynamic> userData) async {
    LogManager().log(_TAG, "_handleForgotPassword", "Call API for forgot password.");
    isLoading.value = true;
    ResultModel resultModel = await _repository.forgotPassword(userData);
    obsForgotPassword.sink.add(resultModel);
    isLoading.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsForgotPassword.close();
    isLoading.dispose();
  }
}
