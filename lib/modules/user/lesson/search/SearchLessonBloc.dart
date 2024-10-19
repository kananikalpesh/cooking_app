
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonListModel.dart';
import 'package:cooking_app/modules/user/lesson/search/SearchLessonRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class SearchLessonBloc extends Bloc {
  static const String TAG = "SearchLessonBloc";

  static const String GET_SEARCH_RESULT_EVENT = "get_lessons_lists";

  final _repository = SearchLessonRepository();
  final event = PublishSubject<EventModel>();
  final obsGetLessonsLists = BehaviorSubject<ResultModel<LessonListModel>>();

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
  
  SearchLessonBloc(int pageSize) {
    _pageSize = pageSize;
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_SEARCH_RESULT_EVENT:
          _getLessonsList(event.data);
          break;
      }
    });
  }

  _getLessonsList(Map<String, dynamic> searchData) async{
    if (_pageNumber == 0) {
      isLoadingFirstPage.value = true;
    }
    _pageNumber += 1;

    searchData.putIfAbsent("page", () => _pageNumber);
    searchData.putIfAbsent("per_page", () => _pageSize);

    LogManager().log(TAG, "_getLessonsList", "Call API for getLessonsList.");
    var result = await _repository.getLessonsList(searchData);

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
  }
}