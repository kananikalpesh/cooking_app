
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/cook/lesson/my_lessons/MyLessonRepository.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonListModel.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class OtherCookLessonsBloc extends Bloc{
  static const String TAG = "OtherCookLessonsBloc";

  static const String GET_OTHER_COOKS_LESSONS = "get_other_cooks_lessons";

  final _repository = MyLessonRepository();
  final event = PublishSubject<EventModel>();
  final obsGetOtherCooksLessonsLists = BehaviorSubject<ResultModel<LessonListModel>>();

  List<LessonDetailsModel> _lessonsList = <LessonDetailsModel>[];
  List<LessonDetailsModel> get lessonsList => _lessonsList;
  
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

  OtherCookLessonsBloc(){
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_OTHER_COOKS_LESSONS:
          _getOtherLessonsList(event.data);
          break;
      }
    });
  }

  _getOtherLessonsList(int cookId) async{
    if (_pageNumber == 0) {
      isLoadingFirstPage.value = true;
    }
    _pageNumber += 1;
    Map<String, dynamic> data = <String, dynamic>{
      "c": cookId,
      "page": _pageNumber,
      "per_page": _pageSize
    };

    LogManager().log(TAG, "_getOtherLessonsList", "Call API for getOtherLessonsList.");
    var result = await _repository.getMyLessons(data);

    if (_pageNumber == 1) {
      _lessonsList.clear();
    }

    if (result.error == null) {
      listSizeOfCurrentFetch = result.data.lessons.length;
      _lessonsList.addAll(result.data.lessons);
      loadingNextPageData.value = false;
    } else {
      obsGetOtherCooksLessonsLists.addError(result.error);
      loadingNextPageData.value = false;
    }

    obsGetOtherCooksLessonsLists.sink.add(result);

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
    obsGetOtherCooksLessonsLists.close();
  }

}