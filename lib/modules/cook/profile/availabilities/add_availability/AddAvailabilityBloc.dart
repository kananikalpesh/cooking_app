
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/cook/profile/availabilities/AvailabilitiesRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class AddAvailabilityBloc extends Bloc {
  static const String TAG = "AddAvailabilityBloc";

  static const String ADD_AVAILABILITY = "add_availability";
  static const String UPDATE_AVAILABILITY = "update_availability";

  final _repository = AvailabilitiesRepository();

  final event = PublishSubject<EventModel>();

  final obsAddAvailability = PublishSubject<ResultModel<bool>>();

  ValueNotifier<bool> isLoadingForAdd = ValueNotifier(false);

  AddAvailabilityBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case ADD_AVAILABILITY:
          _handleAddAvailability(event.data);
          break;
        case UPDATE_AVAILABILITY:
          _handleUpdateAvailability(event.data);
          break;
      }
    });
  }

  _handleAddAvailability(Map<String, dynamic> data) async {
    LogManager().log(TAG, "_handleAddAvailability", "Call API for add new availability.");
    isLoadingForAdd.value = true;
    ResultModel resultModel = await _repository.addAvailability(data);
    obsAddAvailability.sink.add(resultModel);
    isLoadingForAdd.value = false;
  }

  _handleUpdateAvailability(Map<String, dynamic> data) async {
    LogManager().log(TAG, "_handleUpdateAvailability", "Call API for update availability.");
    isLoadingForAdd.value = true;
    ResultModel resultModel = await _repository.updateAvailability(data);
    obsAddAvailability.sink.add(resultModel);
    isLoadingForAdd.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsAddAvailability.close();
  }

}