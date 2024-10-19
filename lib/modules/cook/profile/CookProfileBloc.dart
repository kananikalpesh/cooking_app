
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/model/shared_preferences/SharedPreference.dart';
import 'package:cooking_app/modules/cook/profile/CookProfileRepository.dart';
import 'package:cooking_app/modules/stripe_payment/OnboardingModel.dart';
import 'package:cooking_app/modules/stripe_payment/PaymentRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class CookProfileBloc extends Bloc {
  static const String TAG = "CookProfileBloc";

  static const String GET_PROFILE_EVENT = "get_profile";
  static const String ON_BOARDING_CREATE_ACCOUNT = "on_boarding_account";

  final _repository = CookProfileRepository();
  final _onboardingRepository = PaymentRepository();

  final event = PublishSubject<EventModel>();

  final obsGetUserProfile = BehaviorSubject<ResultModel<UserModel>>();
  ValueNotifier<bool> isProfileLoading = ValueNotifier(false);

  final obsOnBoardingDetails = PublishSubject<ResultModel<OnboardingModel>>();
  ValueNotifier<bool> isLoadingForOnBoarding = ValueNotifier(false);

  CookProfileBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_PROFILE_EVENT:
          _getUserProfile(event.data);
          break;
        case ON_BOARDING_CREATE_ACCOUNT:
          _createAccountRequest();
          break;
      }
    });
  }

  _getUserProfile(int userId) async{
    isProfileLoading.value = true;
    LogManager().log(TAG, "_getUserProfile", "Call API for getProfile.");
    ResultModel<UserModel> resultModel = await _repository.getProfile(userId);
    if(resultModel.error == null){
      await SharedPreferenceManager().setPgStatus(resultModel.data.pgStatus);
    }
    obsGetUserProfile.sink.add(resultModel);
    isProfileLoading.value = false;
  }

  _createAccountRequest() async{
    LogManager().log(TAG, "_createAccountRequest", "Call API for onboarding request.");
    isLoadingForOnBoarding.value = true;
    ResultModel<OnboardingModel> resultModel = await _onboardingRepository.getOnBoardingDetails();
    obsOnBoardingDetails.sink.add(resultModel);
    isLoadingForOnBoarding.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsGetUserProfile.close();
    obsOnBoardingDetails.close();
  }

}