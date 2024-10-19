
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/cook/profile/availabilities/AvailabilitiesRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class ManageAvailabilityBloc extends Bloc {
  static const String TAG = "ManageAvailabilityBloc";

  static const String GET_PROFILE_EVENT = "get_profile";
  static const String DELETE_AVAILABILITY = "delete_availability";

  final _repository = AvailabilitiesRepository();

  final event = PublishSubject<EventModel>();

  final obsGetUserProfile = BehaviorSubject<ResultModel<UserModel>>();
  final obsAddAvailability = PublishSubject<ResultModel<bool>>();
  final obsDeleteAvailability = PublishSubject<ResultModel>();

  ValueNotifier<bool> isProfileLoading = ValueNotifier(false);
  ValueNotifier<bool> isLoadingForAdd = ValueNotifier(false);

  int deleteLoadingIndex = -1;

  ManageAvailabilityBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_PROFILE_EVENT:
          _getUserProfile(event.data);
          break;
        case DELETE_AVAILABILITY:
          _deleteAvailability(event.data);
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

  _deleteAvailability(int availabilityId) async {
    LogManager().log(TAG, "_deleteAvailability", "Call API for delete availability.");
    ResultModel resultModel = await _repository.deleteAvailability(availabilityId);
    obsDeleteAvailability.sink.add(resultModel);
  }

  @override
  void dispose() {
    event.close();
    obsGetUserProfile.close();
    obsAddAvailability.close();
    obsDeleteAvailability.close();
  }

}