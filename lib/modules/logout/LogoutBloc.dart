import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/logout/LogoutRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

const _TAG = "LogoutBloc";
class LogoutBloc extends Bloc {
  static const String LOGOUT_EVENT = "logout";

  final _repository = LogoutRepository();

  final event = PublishSubject<EventModel>();
  final obsLogout = BehaviorSubject<ResultModel>();

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  LogoutBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case LOGOUT_EVENT:
          _handleLogout();
          break;
      }
    });
  }

  _handleLogout() async {
    LogManager().log(_TAG, "_handleLogout", "Call API for logout.");
    isLoading.value = true;
    ResultModel resultModel = await _repository.logout();
    obsLogout.sink.add(resultModel);
    isLoading.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsLogout.close();
    isLoading.dispose();
  }
}
