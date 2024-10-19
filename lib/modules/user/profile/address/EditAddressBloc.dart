
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/user/profile/address/UserAddressRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class EditAddressBloc extends Bloc{
  static const String TAG = "EditAddressBloc";

  static const String UPDATE_ADDRESS_EVENT = "update_address";
  static const String GET_COUNTRIES_EVENT = "get_countries";

  final _repository = UserAddressRepository();
  final event = PublishSubject<EventModel>();

  final obsUpdateAddress = BehaviorSubject<ResultModel<bool>>();
  final obsCountryList = BehaviorSubject<ResultModel<List<String>>>();
  ValueNotifier<bool> isLoadingForCountries = ValueNotifier(false);

  ValueNotifier<bool> isAddressUpdating = ValueNotifier(false);

  EditAddressBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case UPDATE_ADDRESS_EVENT:
          _updateAddress(event.data);
          break;
        case GET_COUNTRIES_EVENT:
          _getCountries();
          break;
      }
    });
  }

  _updateAddress(Map<String , dynamic> userData) async {
    LogManager().log(TAG, "_updateAddress", "Call API for updateAddress.");
    ResultModel resultModel = await _repository.updateAddress(userData);
    obsUpdateAddress.sink.add(resultModel);
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
    obsUpdateAddress.close();
    isLoadingForCountries.dispose();
    obsCountryList.close();
  }
}