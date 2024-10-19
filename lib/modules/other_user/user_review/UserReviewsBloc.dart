
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/cook/profile/other_user/other_cook_reviews/ReviewListModel.dart';
import 'package:cooking_app/modules/other_user/user_review/UserReviewsRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class UserReviewsBloc extends Bloc{
  static const String TAG = "UserReviewsBloc";

  static const String GET_OTHER_USER_REVIEWS = "get_other_user_reviews";

  final _repository = UserReviewsRepository();
  final event = PublishSubject<EventModel>();
  final obsGetReviewsLists = BehaviorSubject<ResultModel<ReviewListModel>>();

  List<ReviewModel> _reviewsList = <ReviewModel>[];
  List<ReviewModel> get reviewsList => _reviewsList;

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

  final isCook;
  
  UserReviewsBloc(this.isCook){
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_OTHER_USER_REVIEWS:
          _getOtherReviewsList(event.data);
          break;
      }
    });
  }

  _getOtherReviewsList(int userId) async{

    if (_pageNumber == 0) {
      isLoadingFirstPage.value = true;
    }
    _pageNumber += 1;
    Map<String, dynamic> data = <String, dynamic>{
      "page": _pageNumber,
      "per_page": _pageSize
    };

    if(isCook){
      data.putIfAbsent("k", () => userId);
    } else{
      data.putIfAbsent("k", () => userId);
    }

    LogManager().log(TAG, "_getOtherReviewsList", "Call API for getOtherReviewsList.");
    var result = await _repository.getUserCookReviews(data, isCook);

    if (_pageNumber == 1) {
      _reviewsList.clear();
    }

    if (result.error == null) {
      listSizeOfCurrentFetch = result.data.reviews.length;
      _reviewsList.addAll(result.data.reviews);
      loadingNextPageData.value = false;
    } else {
      obsGetReviewsLists.addError(result.error);
      loadingNextPageData.value = false;
    }

    obsGetReviewsLists.sink.add(result);

    if (isLoadingFirstPage.value) {
      isLoadingFirstPage.value = false;
    }
  }

  reloadFromStart() {
    _pageNumber = 0;
    _count.value = 0;
    _reviewsList.clear();
  }

  @override
  void dispose() {
    event.close();
    obsGetReviewsLists.close();
  }

}