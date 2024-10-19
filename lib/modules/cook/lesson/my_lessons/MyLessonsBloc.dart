
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

class MyLessonsBloc extends Bloc{
  static const String TAG = "MyLessonsBloc";

  static const String GET_MY_LESSONS = "get_my_lessons";
  static const String DELETE_MY_LESSONS = "delete_my_lessons";

  final _repository = MyLessonRepository();
  final event = PublishSubject<EventModel>();
  final obsGetMyLessonsLists = BehaviorSubject<ResultModel<LessonListModel>>();
  final obsDeleteMyLessonsLists = PublishSubject<ResultModel<dynamic>>();

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

  MyLessonsBloc(){
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_MY_LESSONS:
          _getMyLessonsList();
          break;

        case DELETE_MY_LESSONS:
          _deleteMyLesson(event.data);
          break;
      }
    });
  }

  _getMyLessonsList() async{
    if (_pageNumber == 0) {
      isLoadingFirstPage.value = true;
    }
    _pageNumber += 1;
    Map<String, dynamic> data = <String, dynamic>{
      "c": [AppData.user.id],
      "page": _pageNumber,
      "per_page": _pageSize
    };

    LogManager().log(TAG, "_getMyLessonsList", "Call API for getMyLessonsList.");
    var result = await _repository.getMyLessons(data);

    if (_pageNumber == 1) {
      _lessonsList.clear();
    }

    if (result.error == null) {
      listSizeOfCurrentFetch = result.data.lessons.length;
      _lessonsList.addAll(result.data.lessons);
      loadingNextPageData.value = false;
    } else {
      obsGetMyLessonsLists.addError(result.error);
      loadingNextPageData.value = false;
    }

    obsGetMyLessonsLists.sink.add(result);

    if (isLoadingFirstPage.value) {
      isLoadingFirstPage.value = false;
    }
  }

  _deleteMyLesson(int lessonId) async{
    LogManager().log(TAG, "_deleteMyLesson", "Call API for delete lesson.");
    ResultModel resultModel = await _repository.deleteMyLesson(lessonId);
    obsDeleteMyLessonsLists.sink.add(resultModel);
  }

  reloadFromStart() {
    _pageNumber = 0;
    _count.value = 0;
    _lessonsList.clear();
  }

  @override
  void dispose() {
    event.close();
    obsGetMyLessonsLists.close();
    obsDeleteMyLessonsLists.close();
  }

}