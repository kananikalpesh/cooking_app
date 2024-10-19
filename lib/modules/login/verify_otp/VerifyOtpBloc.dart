
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import 'VerifyOtpRepository.dart';

const _TAG = "VerifyOtpBloc";
class VerifyOtpBloc extends Bloc {
  static const String VERIFY_OTP_EVENT = "verify_otp";
  static const String RESEND_OTP_EVENT = "resend_otp";

  final _repository = VerifyOtpRepository();

  final event = PublishSubject<EventModel>();
  final obsVerifyOtp = BehaviorSubject<ResultModel<bool>>();
  final obsResendOtp = BehaviorSubject<ResultModel<bool>>();

  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<bool> isResendOtpLoading = ValueNotifier(false);

  VerifyOtpBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case VERIFY_OTP_EVENT:
          _handleOtp(event.data);
          break;
        case RESEND_OTP_EVENT:
          _handleResendOtp(event.data);
          break;
      }
    });
  }

  _handleOtp(Map<String, dynamic> userData) async {
    LogManager().log(_TAG, "_handleOtp", "Call API for verify otp.");
    ResultModel resultModel = await _repository.verifyOtp(userData);
    obsVerifyOtp.sink.add(resultModel);
  }

  _handleResendOtp(Map<String, dynamic> userData) async {
    LogManager().log(_TAG, "_handleResendOtp", "Call API for resend otp.");
    isResendOtpLoading.value = true;
    ResultModel resultModel = await _repository.resendOtp(userData);

    obsResendOtp.sink.add(resultModel);
    isResendOtpLoading.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsVerifyOtp.close();
    isLoading.dispose();
    obsResendOtp.close();
    isResendOtpLoading.dispose();
  }
}
