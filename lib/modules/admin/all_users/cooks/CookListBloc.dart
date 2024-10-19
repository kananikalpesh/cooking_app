
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/admin/all_users/AllUsersListModel.dart';
import 'package:cooking_app/modules/admin/all_users/AllUsersRepository.dart';
import 'package:cooking_app/modules/admin/all_users/FlaggedUsersListModel.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CookListBloc extends Bloc{
  static const String TAG = "CookListBloc";

  static const String GET_ALL_COOKS = "get_all_cooks";
  static const String GET_FLAGGED_COOKS = "get_flagged_cooks";
  static const String DELETE_COOK = "delete_cook";
  static const String IGNORE_COOK = "ignore_cook";
  static const String BLOCK_COOK = "block_cook";

  final _repository = AllUsersRepository();
  final event = PublishSubject<EventModel>();
  final obsGetCooksList = BehaviorSubject<ResultModel<AllUsersListModel>>();
  final obsGetFlaggedCooksList = BehaviorSubject<ResultModel<FlaggedUsersListModel>>();
  final obsDeleteCook = PublishSubject<ResultModel>();
  final obsIgnoreCook = PublishSubject<ResultModel>();
  final obsBlockCook = PublishSubject<ResultModel>();

  List<UserModel> _cooksList = <UserModel>[];
  List<UserModel> get cooksList => _cooksList;

  List<FlaggedUserDetailsModel> _flaggedCooksList = <FlaggedUserDetailsModel>[];
  List<FlaggedUserDetailsModel> get flaggedCooksList => _flaggedCooksList;
  
  int _pageSize = 10;
  int _pageNumber = 0;
  int get getPageSize => _pageSize;
  int get getCurrentPageNumber => _pageNumber;

  ValueNotifier<int> _count = ValueNotifier(0);
  ValueNotifier<int> get getCount => _count;
  ValueNotifier<int> indexProcessingCooks = ValueNotifier(-1);
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

  int deleteLoadingIndex = -1;
  int ignoreLoadingIndex = -1;
  int blockLoadingIndex = -1;

  ValueNotifier<bool> loadingNextPageData = ValueNotifier(false);

  int listSizeOfCurrentFetch = 0;

  final bool isFlaggedUsers;

  CookListBloc(this.isFlaggedUsers){

    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_ALL_COOKS:
          _getCooksList();
          break;
          case GET_FLAGGED_COOKS:
            _getFlaggedCooksList();
          break;
          case DELETE_COOK:
          _deleteCook(event.data);
          break;
        case IGNORE_COOK:
          _ignoreCook(event.data);
          break;
        case BLOCK_COOK:
          _blockCook(event.data);
          break;
      }
    });
  }

  _getCooksList() async{
    if (_pageNumber == 0) {
      isLoadingFirstPage.value = true;
    }
    _pageNumber += 1;
    Map<String, dynamic> data = <String, dynamic>{
      "t": "c",
      "page": _pageNumber,
      "per_page": _pageSize
    };

    LogManager().log(TAG, "_getCooksList", "Call API for getCooksList.");
    var result = await _repository.usersList(data);

    if (_pageNumber == 1) {
      _cooksList.clear();
    }

    if (result.error == null) {
      listSizeOfCurrentFetch = result.data.users.length;
      _cooksList.addAll(result.data.users);
      loadingNextPageData.value = false;
    } else {
      obsGetCooksList.addError(result.error);
      loadingNextPageData.value = false;
    }

    obsGetCooksList.sink.add(result);

    if (isLoadingFirstPage.value) {
      isLoadingFirstPage.value = false;
    }
  }

  _getFlaggedCooksList() async{
    if (_pageNumber == 0) {
      isLoadingFirstPage.value = true;
    }
    _pageNumber += 1;
    Map<String, dynamic> data = <String, dynamic>{
      "t": "c",
      "page": _pageNumber,
      "per_page": _pageSize
    };

    LogManager().log(TAG, "_getFlaggedCooksList", "Call API for _getFlaggedCooksList.");
    var result = await _repository.flaggedUsersList(data);

    if (_pageNumber == 1) {
      _cooksList.clear();
    }

    if (result.error == null) {
      listSizeOfCurrentFetch = result.data.flaggedUsers.length;
      _flaggedCooksList.addAll(result.data.flaggedUsers);
      loadingNextPageData.value = false;
    } else {
      obsGetFlaggedCooksList.addError(result.error);
      loadingNextPageData.value = false;
    }

    obsGetFlaggedCooksList.sink.add(result);

    if (isLoadingFirstPage.value) {
      isLoadingFirstPage.value = false;
    }
  }

  _deleteCook(int cookId) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": cookId
    };
    LogManager().log(TAG, "_deleteCook", "Call API for deleteCook.");
    ResultModel resultModel = await _repository.deleteUser(data);
    obsDeleteCook.sink.add(resultModel);
  }

  _ignoreCook(int recordId) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": recordId
    };
    LogManager().log(TAG, "_ignoreCook", "Call API for _ignoreCook.");

    ResultModel resultModel = await _repository.ignoreUser(data);
    obsIgnoreCook.sink.add(resultModel);
  }

  _blockCook(int recordId) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": recordId
    };
    LogManager().log(TAG, "_blockCook", "Call API for _blockCook.");

    ResultModel resultModel = await _repository.blockUser(data);
    obsBlockCook.sink.add(resultModel);
  }

  reloadFromStart() {
    _pageNumber = 0;
    _count.value = 0;
    _cooksList.clear();
    _flaggedCooksList.clear();
  }

  @override
  void dispose() {
    event.close();
    obsGetCooksList.close();
    obsDeleteCook.close();
    obsGetFlaggedCooksList.close();
    obsIgnoreCook.close();
    obsBlockCook.close();
  }

}