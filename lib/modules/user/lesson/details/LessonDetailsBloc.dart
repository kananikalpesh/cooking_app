
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonListModel.dart';
import 'package:cooking_app/modules/user/lesson/details/BookingStatusModel.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class LessonDetailsBloc extends Bloc {
  static const String TAG = "LessonDetailsBloc";

  static const String GET_LESSON_DETAILS = "get_lesson_details";
  static const String GET_OTHER_LESSONS_EVENT = "get_other_lessons";
  static const String GET_BOOKING_DETAILS = "get_booking_details";

  final _repository = LessonDetailsRepository();

  final event = PublishSubject<EventModel>();

  final obsGetLessonDetails = BehaviorSubject<ResultModel<LessonDetailsModel>>();
  ValueNotifier<bool> isDetailsLoading = ValueNotifier(false);

  final obsGetLessonsLists = BehaviorSubject<ResultModel<LessonListModel>>();
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  final obsGetBookingDetails = BehaviorSubject<ResultModel<BookingStatusModel>>();
  ValueNotifier<bool> isBookingLoading = ValueNotifier(false);

  List<LessonDetailsModel> _lessonsList = <LessonDetailsModel>[];
  List<LessonDetailsModel> get lessonsList => _lessonsList;

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

  LessonDetailsBloc(int pageSize) {
    _pageSize = pageSize;
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_LESSON_DETAILS:
          _getLessonDetails(event.data);
          break;
        case GET_OTHER_LESSONS_EVENT:
          _getOtherLessonsList(event.data);
          break;
        case GET_BOOKING_DETAILS:
          _getBookingDetails(event.data);
          break;
      }
    });
  }

  _getLessonDetails(int lessonId) async{
    var _lessonData = <String, dynamic>{
      "l": lessonId,
    };
    isDetailsLoading.value = true;
    LogManager().log(TAG, "_getLessonDetails", "Call API for getLessonDetails.");
    ResultModel resultModel = await _repository.getLessonDetails(_lessonData);
    obsGetLessonDetails.sink.add(resultModel);
    isDetailsLoading.value = false;
  }

  _getBookingDetails(Map<String, dynamic> data) async{
   /* var _lessonData = <String, dynamic>{
      "l": lessonId,
    };*/
    isBookingLoading.value = true;
    LogManager().log(TAG, "_getBookingDetails", "Call API for getBookingDetails.");
    ResultModel resultModel = await _repository.getBookingDetails(data);
    obsGetBookingDetails.sink.add(resultModel);
    isBookingLoading.value = false;
  }

  _getOtherLessonsList(Map<String, dynamic> data) async{
    if (_pageNumber == 0) {
      isLoadingFirstPage.value = true;
    }
    _pageNumber += 1;

    data.putIfAbsent("page", () => _pageNumber);
    data.putIfAbsent("per_page", () => _pageSize);

    LogManager().log(TAG, "_getOtherLessonsList", "Call API for getOtherLessonsList.");
    var result = await _repository.getOtherLessonsList(data);

    if (_pageNumber == 1) {
      _lessonsList.clear();
    }

    if (result.error == null) {
      listSizeOfCurrentFetch = result.data.lessons.length;
      _lessonsList.addAll(result.data.lessons);
      loadingNextPageData.value = false;
    } else {
      obsGetLessonsLists.addError(result.error);
      loadingNextPageData.value = false;
    }

    obsGetLessonsLists.sink.add(result);

    if (isLoadingFirstPage.value) {
      isLoadingFirstPage.value = false;
    }
  }

  reloadFromStart() {
    _pageNumber = 0;
    _count.value = 0;
    _lessonsList.clear();
  }

  @override
  void dispose() {
    event.close();
    obsGetLessonsLists.close();
    obsGetLessonDetails.close();
    obsGetBookingDetails.close();
  }
}