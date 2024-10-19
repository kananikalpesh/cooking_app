
import 'dart:async';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/admin/all_users/cooks/CookItemWidget.dart';
import 'package:cooking_app/modules/admin/all_users/cooks/CookListBloc.dart';
import 'package:cooking_app/modules/admin/all_users/cooks/FlaggedCookItem.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CooksListScreen extends StatefulWidget{
  final bool isFlaggedUsers;

  CooksListScreen(this.isFlaggedUsers);
  
  @override
  State<StatefulWidget> createState() => _CooksListScreenState();

}

class _CooksListScreenState extends State<CooksListScreen>{

  CookListBloc _bloc;

  StreamSubscription _cooksListSubscription;
  StreamSubscription _flaggedCooksListSubscription;
  ScrollController _listScrollController;

  @override
  initState(){

    _bloc = CookListBloc(widget.isFlaggedUsers);

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
      _flaggedCooksListSubscription = _bloc.obsGetFlaggedCooksList.stream.listen((result) {
        _bloc.setCount = (_bloc.flaggedCooksList.length);
      });
    }else{
      _cooksListSubscription = _bloc.obsGetCooksList.stream.listen((result) {
        _bloc.setCount = (_bloc.cooksList.length);
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
    if (_cooksListSubscription != null) {
      _cooksListSubscription.cancel();
    }
    if(_flaggedCooksListSubscription != null){
      _flaggedCooksListSubscription.cancel();
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
        child: Text(AppStrings.emptyCookData,
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
                  return FlaggedCookItem(index, _bloc.flaggedCooksList[index], _bloc, (bool isIgnored, bool isBlocked){
                    if (isIgnored || isBlocked){
                      _bloc.reloadFromStart();
                      _loadNewData();
                    }
                  });
                } else return CookItemWidget(index, _bloc.cooksList[index], _bloc, (isDeleted){
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
      _bloc.obsGetFlaggedCooksList.sink.add(null);
      _bloc.event.add(EventModel(CookListBloc.GET_FLAGGED_COOKS));
    }else{
      _bloc.obsGetCooksList.sink.add(null);
      _bloc.event.add(EventModel(CookListBloc.GET_ALL_COOKS));
    }
  }

}