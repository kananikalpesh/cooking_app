
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/stripe_payment/PaymentModel.dart';
import 'package:cooking_app/modules/stripe_payment/PaymentRepository.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class ActionableWidgetBloc extends Bloc {
  static const String TAG = "ActionableWidgetBloc";

  static const String CANCEL_LESSON_BOOKING_REQUEST = "cancel_lesson_booking";
  static const String LESSON_BOOKING_PAYMENT = "payment_for_lesson";

  final _repository = LessonDetailsRepository();
  final _paymentRepository = PaymentRepository();

  final event = PublishSubject<EventModel>();

  final obsCancelRequest = BehaviorSubject<ResultModel<bool>>();
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  final obsPaymentDetails = BehaviorSubject<ResultModel<PaymentModel>>();
  ValueNotifier<bool> isLoadingForPayment = ValueNotifier(false);

  ActionableWidgetBloc(bool isFromCook) {
    event.stream.listen((event) {
      switch (event.eventType) {
        case CANCEL_LESSON_BOOKING_REQUEST:
          _cancelBookingRequest(event.data, isFromCook);
          break;
        case LESSON_BOOKING_PAYMENT:
          _paymentRequest(event.data);
          break;
      }
    });
  }

  _cancelBookingRequest(Map<String, dynamic> requestData, bool isFromCook) async{
    LogManager().log(TAG, "_cancelBookingRequest", "Call API for cancel booking request.");
    isLoading.value = true;
    ResultModel resultModel = await _repository.cancelBookingRequest(requestData, isFromCook);
    obsCancelRequest.sink.add(resultModel);
    isLoading.value = false;
  }

  _paymentRequest(Map<String, dynamic> requestData) async{
    LogManager().log(TAG, "_paymentRequest", "Call API for payment request.");
    isLoadingForPayment.value = true;
    ResultModel resultModel = await _paymentRepository.getPaymentDetails(requestData);
    obsPaymentDetails.sink.add(resultModel);
    isLoadingForPayment.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsCancelRequest.close();
    obsPaymentDetails.close();
  }
}