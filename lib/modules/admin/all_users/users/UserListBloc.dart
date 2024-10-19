
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

class UserListBloc extends Bloc{
  static const String TAG = "UserListBloc";

  static const String GET_ALL_USERS = "get_all_users";
  static const String GET_FLAGGED_USERS = "get_flagged_users";
  static const String DELETE_USER = "delete_user";
  static const String IGNORE_USER = "ignore_user";
  static const String BLOCK_USER = "block_user";

  final _repository = AllUsersRepository();
  final event = PublishSubject<EventModel>();
  final obsGetUsersList = BehaviorSubject<ResultModel<AllUsersListModel>>();
  final obsGetFlaggedUsersList = BehaviorSubject<ResultModel<FlaggedUsersListModel>>();
  final obsDeleteUser = PublishSubject<ResultModel>();
  final obsIgnoreUser = PublishSubject<ResultModel>();
  final obsBlockUser = PublishSubject<ResultModel>();

  List<UserModel> _usersList = <UserModel>[];
  List<UserModel> get usersList => _usersList;

  List<FlaggedUserDetailsModel> _flaggedUsersList = <FlaggedUserDetailsModel>[];
  List<FlaggedUserDetailsModel> get flaggedUsersList => _flaggedUsersList;
  
  int _pageSize = 10;
  int _pageNumber = 0;
  int get getPageSize => _pageSize;
  int get getCurrentPageNumber => _pageNumber;

  ValueNotifier<int> _count = ValueNotifier(0);
  ValueNotifier<int> get getCount => _count;
  ValueNotifier<int> indexProcessingUser = ValueNotifier(-1);
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

  UserListBloc(this.isFlaggedUsers){

    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_ALL_USERS:
          _getCooksList();
          break;
          case GET_FLAGGED_USERS:
            _getFlaggedCooksList();
          break;
        case DELETE_USER:
          _deleteUser(event.data);
          break;
        case IGNORE_USER:
          _ignoreUser(event.data);
          break;
        case BLOCK_USER:
          _blockUser(event.data);
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
      "t": "u",
      "page": _pageNumber,
      "per_page": _pageSize
    };

    LogManager().log(TAG, "_getCooksList", "Call API for getCooksList.");
    var result =  await _repository.usersList(data);

    if (_pageNumber == 1) {
      _usersList.clear();
    }

    if (result.error == null) {
      listSizeOfCurrentFetch = result.data.users.length;
      _usersList.addAll(result.data.users);
      loadingNextPageData.value = false;
    } else {
      obsGetUsersList.addError(result.error);
      loadingNextPageData.value = false;
    }

    obsGetUsersList.sink.add(result);

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
      "t": "u",
      "page": _pageNumber,
      "per_page": _pageSize
    };

    LogManager().log(TAG, "_getCooksList", "Call API for getCooksList.");
    var result =  await _repository.flaggedUsersList(data);

    if (_pageNumber == 1) {
      _usersList.clear();
    }

    if (result.error == null) {
      listSizeOfCurrentFetch = result.data.flaggedUsers.length;
      _flaggedUsersList.addAll(result.data.flaggedUsers);
      loadingNextPageData.value = false;
    } else {
      obsGetUsersList.addError(result.error);
      loadingNextPageData.value = false;
    }

    obsGetFlaggedUsersList.sink.add(result);

    if (isLoadingFirstPage.value) {
      isLoadingFirstPage.value = false;
    }
  }

  _deleteUser(int cookId) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": cookId
    };
    LogManager().log(TAG, "_deleteUser", "Call API for deleteUser.");
    ResultModel resultModel = await _repository.deleteUser(data);
    obsDeleteUser.sink.add(resultModel);
  }

  _ignoreUser(int recordId) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": recordId
    };
    LogManager().log(TAG, "_ignoreUser", "Call API for _ignoreUser.");
    ResultModel resultModel = await _repository.ignoreUser(data);
    obsIgnoreUser.sink.add(resultModel);
  }

  _blockUser(int recordId) async {
    Map<String, dynamic> data = <String, dynamic>{
      "id": recordId
    };
    LogManager().log(TAG, "_blockUser", "Call API for _blockUser.");
    ResultModel resultModel = await _repository.blockUser(data);
    obsBlockUser.sink.add(resultModel);
  }

  reloadFromStart() {
    _pageNumber = 0;
    _count.value = 0;
    _usersList.clear();
    _flaggedUsersList.clear();
  }

  @override
  void dispose() {
    event.close();
    obsGetUsersList.close();
    obsDeleteUser.close();
    obsIgnoreUser.close();
    obsBlockUser.close();
    obsGetFlaggedUsersList.close();
  }

}