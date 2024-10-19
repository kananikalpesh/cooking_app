
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/my_bookings/MyBookingsListModel.dart';
import 'package:cooking_app/modules/my_bookings/my_requests/MyRequestsRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class MyRequestBloc extends Bloc{
  static const String TAG = "MyRequestBloc";

  static const String GET_MY_REQUESTS = "get_my_requests";
  static const String REJECT_BOOKING_REQUEST = "reject_booking_request";
  static const String APPROVE_BOOKING_REQUEST = "approve_booking_request";

  final _repository = MyRequestsRepository();
  final event = PublishSubject<EventModel>();
  final obsGetMyRequestsLists = BehaviorSubject<ResultModel<MyBookingsListModel>>();
  final obsRejectRequest = PublishSubject<ResultModel<bool>>();
  final obsApproveRequest = PublishSubject<ResultModel<bool>>();

  List<MyBookingDetailsModel> _requestsList = <MyBookingDetailsModel>[];
  List<MyBookingDetailsModel> get requestsList => _requestsList;
  
  int _pageSize = 10;
  int _pageNumber = 0;
  int get getPageSize => _pageSize;
  int get getCurrentPageNumber => _pageNumber;

  ValueNotifier<int> _count = ValueNotifier(0);
  ValueNotifier<int> get getCount => _count;
  ValueNotifier<int> indexProcessingLesson = ValueNotifier(-1);
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

  ValueNotifier<bool> isRejectRequestLoading = ValueNotifier(false);
  ValueNotifier<bool> isApproveRequestLoading = ValueNotifier(false);

  MyRequestBloc(){
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_MY_REQUESTS:
          _getMyRequestsList();
          break;
        case REJECT_BOOKING_REQUEST:
          _rejectBookingRequest(event.data);
          break;
        case APPROVE_BOOKING_REQUEST:
          _approveBookingRequest(event.data);
          break;
      }
    });
  }

  _getMyRequestsList() async{
    if (_pageNumber == 0) {
      isLoadingFirstPage.value = true;
    }
    _pageNumber += 1;
    Map<String, dynamic> data = <String, dynamic>{
      "b": BookingRequestEnum.PENDING_CONFIRMATION.enumValue,
      "t": TimelineStatusEnum.UPCOMING.enumValue,
      "page": _pageNumber,
      "per_page": _pageSize
    };

    LogManager().log(TAG, "_getMyRequestsList", "Call API for getMyRequestsList.");
    var result = await _repository.getMyRequests(data);

    if (_pageNumber == 1) {
      _requestsList.clear();
    }

    if (result.error == null) {
      listSizeOfCurrentFetch = result.data.lessons.length;
      _requestsList.addAll(result.data.lessons);
      loadingNextPageData.value = false;
    } else {
      obsGetMyRequestsLists.addError(result.error);
      loadingNextPageData.value = false;
    }

    obsGetMyRequestsLists.sink.add(result);

    if (isLoadingFirstPage.value) {
      isLoadingFirstPage.value = false;
    }
  }

  _rejectBookingRequest(Map<String, dynamic> requestData) async{
    LogManager().log(TAG, "_rejectBookingRequest", "Call API for reject booking request.");
    isRejectRequestLoading.value = true;
    ResultModel resultModel = await _repository.rejectBookingRequest(requestData);
    obsRejectRequest.sink.add(resultModel);
    isRejectRequestLoading.value = false;
  }

  _approveBookingRequest(Map<String, dynamic> requestData) async{
    LogManager().log(TAG, "_approveBookingRequest", "Call API for approve booking request.");
    isApproveRequestLoading.value = true;
    ResultModel resultModel = await _repository.approveBookingRequest(requestData);
    obsApproveRequest.sink.add(resultModel);
    isApproveRequestLoading.value = false;
  }

  reloadFromStart() {
    _pageNumber = 0;
    _count.value = 0;
    _requestsList.clear();
  }

  @override
  void dispose() {
    event.close();
    obsGetMyRequestsLists.close();
    obsRejectRequest.close();
    obsApproveRequest.close();
  }

}