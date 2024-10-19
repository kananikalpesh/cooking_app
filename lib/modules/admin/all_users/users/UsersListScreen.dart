
import 'dart:async';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/admin/all_users/users/FlaggedUserItem.dart';
import 'package:cooking_app/modules/admin/all_users/users/UserItemWidget.dart';
import 'package:cooking_app/modules/admin/all_users/users/UserListBloc.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UsersListScreen extends StatefulWidget{
  final bool isFlaggedUsers;

  UsersListScreen(this.isFlaggedUsers);
  
  @override
  State<StatefulWidget> createState() => _UsersListScreenState();

}

class _UsersListScreenState extends State<UsersListScreen>{

  UserListBloc _bloc;

  StreamSubscription _usersListSubscription;
  StreamSubscription _flaggedUsersListSubscription;
  ScrollController _listScrollController;

  @override
  initState(){

    _bloc = UserListBloc(widget.isFlaggedUsers);

    _listScrollController = ScrollController();
    _listScrollController.addListener(() {
      if (_listScrollController.offset >=
          _listScrollController.position.maxScrollExtent &&
          !_listScrollController.position.outOfRange) {
        if (!_bloc.loadingNextPageData.value) {
          if (_bloc.listSizeOfCurrentFetch >= _bloc.getPageSize) {
            _bloc.loadingNextPageData.value = true;
            _loadNewData();
          }
        }
      }
    });

    if(widget.isFlaggedUsers){
      _flaggedUsersListSubscription = _bloc.obsGetFlaggedUsersList.stream.listen((result) {
        _bloc.setCount = (_bloc.flaggedUsersList.length);
      });
    }else{
      _usersListSubscription = _bloc.obsGetUsersList.stream.listen((result) {
        _bloc.setCount = (_bloc.usersList.length);
      });
    }

    super.initState();

    _loadNewData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(controller: _listScrollController,
      child: ValueListenableProvider<bool>.value(
        value: _bloc.isLoadingFirstPage,
        child: Consumer<bool>(
          builder: (context, isLoadingFirstPage, child) {
            return ValueListenableProvider<int>.value(
              value: _bloc.getCount,
              child: Consumer<int>(
                builder: (context, valueListCount, child) {
                  return (isLoadingFirstPage)
                      ? _getListLoader()
                      : (valueListCount == 0)
                      ? _getEmptyListWidget()
                      : _getCooksListBuilder(valueListCount);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_usersListSubscription != null) {
      _usersListSubscription.cancel();
    }
    if (_flaggedUsersListSubscription != null) {
      _flaggedUsersListSubscription.cancel();
    }
      _bloc.dispose();
    super.dispose();
  }

  Widget _getListLoader(){
    var height = MediaQuery.of(context).size.height/2;
    return Container(
        height: height,
        child: Center(child: CircularProgressIndicator())
    );
  }

  Widget _getEmptyListWidget() {
    var height = MediaQuery.of(context).size.height/1.5;
    return Container(
      height: height,
      child: Center(
        child: Text(AppStrings.emptyUserData,
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _getCooksListBuilder(int valueListCount) {
    return Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: valueListCount + 1,
            padding: EdgeInsets.only(left: AppDimensions.generalPadding,
                right: AppDimensions.generalPadding, bottom: AppDimensions.generalPadding),
            itemBuilder: (context, index) {
              if (index == (valueListCount)) {
                return ValueListenableProvider<bool>.value(
                  value: _bloc.loadingNextPageData,
                  child: Consumer<bool>(
                    builder: (context, value, child) {
                      Future.delayed(
                          Duration(
                            milliseconds: 10,
                          ), () {
                        if (value && (index == (valueListCount))) {
                          _listScrollController.jumpTo(
                              _listScrollController.position.maxScrollExtent);
                        }
                      });
                      return Offstage(
                        offstage: (!value),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10,
                              bottom: AppDimensions.generalPadding),
                          child: Center(
                            child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator()),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                if(widget.isFlaggedUsers){
                  return FlaggedUserItem(index, _bloc.flaggedUsersList[index], _bloc, (bool isIgnored, bool isBlocked){
                    if (isIgnored || isBlocked){
                      _bloc.reloadFromStart();
                      _loadNewData();
                    }
                  }); /*Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(height: 100, color: Colors.greenAccent, child: Center(child: Text("$index"),),),
                  );*/
                }else return UserItemWidget(index, _bloc.usersList[index], _bloc, (isDeleted){
                  if (isDeleted){
                    _bloc.reloadFromStart();
                    _loadNewData();
                  }
                });
              }
            }),
      ],
    );
  }
  
  _loadNewData() {
    if(widget.isFlaggedUsers){
      _bloc.obsGetFlaggedUsersList.sink.add(null);
      _bloc.event.add(EventModel(UserListBloc.GET_FLAGGED_USERS));
    }else{
      _bloc.obsGetUsersList.sink.add(null);
      _bloc.event.add(EventModel(UserListBloc.GET_ALL_USERS));
    }
  }

}