
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/admin/payments/PaymentListModel.dart';
import 'package:cooking_app/modules/admin/payments/PaymentListRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AllPaymentsBloc extends Bloc{
  static const String TAG = "AllPaymentsBloc";

  static const String GET_PAYMENTS = "get_payments";

  final _repository = PaymentListRepository();
  final event = PublishSubject<EventModel>();
  final obsGetPaymentLists = BehaviorSubject<ResultModel<PaymentListModel>>();

  List<AdminPaymentDetailsModel> _paymentsList = <AdminPaymentDetailsModel>[];
  List<AdminPaymentDetailsModel> get paymentsList => _paymentsList;


  int _pageSize = 10;
  int _pageNumber = 0;
  int get getPageSize => _pageSize;
  int get getCurrentPageNumber => _pageNumber;

  ValueNotifier<int> _count = ValueNotifier(0);
  ValueNotifier<int> get getCount => _count;
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

  AllPaymentsBloc(){
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_PAYMENTS:
          _getPaymentsList();
          break;
      }
    });
  }

  _getPaymentsList() async{
    if (_pageNumber == 0) {
      isLoadingFirstPage.value = true;
    }
    _pageNumber += 1;
    Map<String, dynamic> data = <String, dynamic>{
      "page": _pageNumber,
      "per_page": _pageSize
    };

    LogManager().log(TAG, "_getPaymentsList", "Call API for getPaymentsList.");
    var result = await _repository.getPaymentsList(data);

    if (_pageNumber == 1) {
      _paymentsList.clear();
    }

    if (result.error == null) {
      listSizeOfCurrentFetch = result.data.payments.length;
      _paymentsList.addAll(result.data.payments);
      loadingNextPageData.value = false;
    } else {
      obsGetPaymentLists.addError(result.error);
      loadingNextPageData.value = false;
    }

    obsGetPaymentLists.sink.add(result);

    if (isLoadingFirstPage.value) {
      isLoadingFirstPage.value = false;
    }
  }

  reloadFromStart() {
    _pageNumber = 0;
    _count.value = 0;
    _paymentsList.clear();
  }

  @override
  void dispose() {
    event.close();
    obsGetPaymentLists.close();
  }

}