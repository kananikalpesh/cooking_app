
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/AvailableSlotsListModel.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/BookLessonRepository.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/CalendarDateModel.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class BookLessonBloc extends Bloc{
  static const String TAG = "BookLessonBloc";

  static const String GET_AVAILABLE_SLOTS_EVENT = "get_available_slots";
  static const String SEND_BOOKING_REQUEST_EVENT = "add_booking_request";
  static const String GET_CALENDER_DATES_EVENT = "get_calender_dates";


  final _repository = BookLessonRepository();
  final event = PublishSubject<EventModel>();
  final obsGetSlotsLists = BehaviorSubject<ResultModel<AvailableSlotsListModel>>();
  final obsGetCalenderDates = BehaviorSubject<ResultModel<CalendarDateModel>>();
  final obsRequestBooking = BehaviorSubject<ResultModel<bool>>();
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<bool> isLoadingForRequest = ValueNotifier(false);
  ValueNotifier<bool> isCalenderDatesLoading = ValueNotifier(false);

  BookLessonBloc(){
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_AVAILABLE_SLOTS_EVENT:
          _getAvailableSlotsList(event.data);
          break;
        case SEND_BOOKING_REQUEST_EVENT:
          _bookLessonRequest(event.data);
          break;
        case GET_CALENDER_DATES_EVENT:
          _getCalenderDates(event.data);
          break;
      }
    });
  }

  _getAvailableSlotsList(Map<String, dynamic> requestData) async{
    isLoading.value = true;
    LogManager().log(TAG, "_getAvailableSlotsList", "Call API for getAvailableSlotsList.");
    ResultModel resultModel = await _repository.getTimeSlots(requestData);
    obsGetSlotsLists.sink.add(resultModel);
    isLoading.value = false;
  }

  _bookLessonRequest(Map<String, dynamic> data) async {
    LogManager().log(TAG, "_bookLessonRequest", "Call API for bookLessonRequest.");
    isLoadingForRequest.value = true;
    ResultModel resultModel = await _repository.requestLessonBooking(data);
    obsRequestBooking.sink.add(resultModel);
    isLoadingForRequest.value = false;
  }

  _getCalenderDates(Map<String, dynamic> requestData) async{
    isCalenderDatesLoading.value = true;
    LogManager().log(TAG, "_getCalenderDates", "Call API for _getCalenderDates.");
    ResultModel resultModel = await _repository.getCalenderDates(requestData);
    obsGetCalenderDates.sink.add(resultModel);
    isCalenderDatesLoading.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsGetSlotsLists.close();
    obsRequestBooking.close();
    obsGetCalenderDates.close();
  }
}