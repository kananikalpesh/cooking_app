
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/my_bookings/MyBookingsListModel.dart';
import 'package:cooking_app/modules/my_bookings/MyBookingsRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PastBookingsBloc extends Bloc{
  static const String TAG = "PastBookingsBloc";

  static const String GET_MY_BOOKINGS = "get_my_bookings";
  static const String REPORT_USER_OR_COOK = "report_user_or_cook";

  final _repository = MyBookingsRepository();
  final event = PublishSubject<EventModel>();
  final obsGetMyBookingsLists = BehaviorSubject<ResultModel<MyBookingsListModel>>();
  final obsReportRequest = PublishSubject<ResultModel<bool>>();

  List<MyBookingDetailsModel> _bookingsList = <MyBookingDetailsModel>[];
  List<MyBookingDetailsModel> get bookingsList => _bookingsList;
  
  int _pageSize = 10;
  int _pageNumber = 0;
  int get getPageSize => _pageSize;
  int get getCurrentPageNumber => _pageNumber;

  ValueNotifier<int> _count = ValueNotifier(0);
  ValueNotifier<int> get getCount => _count;
  ValueNotifier<int> indexProcessingLesson = ValueNotifier(-1);
  ValueNotifier<bool> isReportLoading = ValueNotifier(false);

  set setCount(int value) {
    _count.value = value;
  }

  ValueNotifier<bool> isLoadingFirstPage = ValueNotifier(false);
  ValueNotifier<int> _currentLoadingIndex = ValueNotifier(-1);
  // ignore: unnecessary_getters_setters
  ValueNotifier<int> get currentLoadingIndex => _currentLoadingIndex;
  // ignore: unnecessary_getters_setters
  set currentLoadingIndex(ValueNotifier<int> value) {
    _currentLoadingIndex = value;
  }

  ValueNotifier<bool> loadingNextPageData = ValueNotifier(false);

  int listSizeOfCurrentFetch = 0;

  PastBookingsBloc(){
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_MY_BOOKINGS:
          _getMyBookingsList();
          break;

        case REPORT_USER_OR_COOK:
          _handleReportUserOrCook(event.data);
          break;
      }
    });
  }

  _getMyBookingsList() async{
    if (_pageNumber == 0) {
      isLoadingFirstPage.value = true;
    }
    _pageNumber += 1;
    Map<String, dynamic> data = <String, dynamic>{
      "b": (AppData.user.role == AppConstants.ROLE_COOK) ? BookingRequestEnum.PAID_AND_BOOKED.enumValue
          : UserBookingRequestEnum.BOOKED.enumValue,
      "t": TimelineStatusEnum.PAST.enumValue,
      "page": _pageNumber,
      "per_page": _pageSize
    };

    LogManager().log(TAG, "_getMyBookingsList", "Call API for getMyBookingsList.");
    var result = await _repository.getMyBookings(data);

    if (_pageNumber == 1) {
      _bookingsList.clear();
    }

    if (result.error == null) {
      listSizeOfCurrentFetch = result.data.lessons.length;
      _bookingsList.addAll(result.data.lessons);
      loadingNextPageData.value = false;
    } else {
      obsGetMyBookingsLists.addError(result.error);
      loadingNextPageData.value = false;
    }

    obsGetMyBookingsLists.sink.add(result);

    if (isLoadingFirstPage.value) {
      isLoadingFirstPage.value = false;
    }
  }

  reloadFromStart() {
    _pageNumber = 0;
    _count.value = 0;
    _bookingsList.clear();
  }

  _handleReportUserOrCook(Map<String,dynamic> data) async{
    isReportLoading.value = true;
    var result = await _repository.reportUserOrCook(data);
    obsReportRequest.add(result);
    isReportLoading.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsGetMyBookingsLists.close();
    obsReportRequest.close();
  }

}