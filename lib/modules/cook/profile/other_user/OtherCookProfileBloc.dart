
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/cook/profile/CookProfileRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class OtherCookProfileBloc extends Bloc {
  static const String TAG = "OtherCookProfileBloc";

  static const String GET_PROFILE_EVENT = "get_profile";

  final _repository = CookProfileRepository();

  final event = PublishSubject<EventModel>();

  final obsGetUserProfile = BehaviorSubject<ResultModel<UserModel>>();

  ValueNotifier<bool> isProfileLoading = ValueNotifier(false);

  OtherCookProfileBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_PROFILE_EVENT:
          _getUserProfile(event.data);
          break;
      }
    });
  }

  _getUserProfile(int userId) async{
    isProfileLoading.value = true;
    LogManager().log(TAG, "_getUserProfile", "Call API for getProfile.");
    ResultModel resultModel = await _repository.getProfile(userId);
    obsGetUserProfile.sink.add(resultModel);
    isProfileLoading.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsGetUserProfile.close();
  }

}