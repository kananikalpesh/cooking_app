
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/admin/analytics/AnalyticsModel.dart';
import 'package:cooking_app/modules/admin/analytics/AnalyticsRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class AnalyticsBloc extends Bloc {
  static const String TAG = "AnalyticsBloc";

  static const String GET_ANALYTICS_EVENT = "get_analytics_details";

  final _repository = AnalyticsRepository();

  final event = PublishSubject<EventModel>();

  final obsGetAnalytics = BehaviorSubject<ResultModel<AnalyticsModel>>();
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  
  AnalyticsBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_ANALYTICS_EVENT:
          _getAnalyticsDetails();
          break;
      }
    });
  }

  _getAnalyticsDetails() async{
    isLoading.value = true;
    LogManager().log(TAG, "_getAnalyticsDetails", "Call API for getAnalyticsDetails.");
    ResultModel<AnalyticsModel> resultModel = await _repository.getAnalyticsDetails();
    obsGetAnalytics.sink.add(resultModel);
    isLoading.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsGetAnalytics.close();
  }

}