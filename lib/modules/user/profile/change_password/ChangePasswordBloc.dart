
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../UserProfileRepository.dart';

const _TAG = "ChangePasswordBloc";

class ChangePasswordBloc extends Bloc{

  static const String CHANGE_PASSWORD = "change_password";
  final _repository = UserProfileRepository();
  final event = PublishSubject<EventModel>();
  final obsChangePass = PublishSubject<ResultModel<bool>>();

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  ChangePasswordBloc(){
    event.stream.listen((event) {
      switch(event.eventType){
        case CHANGE_PASSWORD:
          _handleChangePass(event.data);
          break;
      }
    });
  }

  _handleChangePass(Map<String, dynamic> data) async {
    LogManager().log(_TAG, "_handleChangePass", "Call API for change password.");
    isLoading.value = true;
    ResultModel resultModel = await _repository.changePassword(data);
    obsChangePass.sink.add(resultModel);
    isLoading.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsChangePass.close();
  }
}