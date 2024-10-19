
import 'dart:async';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/my_bookings/my_requests/MyRequestBloc.dart';
import 'package:cooking_app/modules/my_bookings/my_requests/RequestItemWidget.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyRequestScreen extends StatefulWidget{
  
  @override
  State<StatefulWidget> createState() => MyRequestScreenState();

}

class MyRequestScreenState extends State<MyRequestScreen>{

  MyRequestBloc _bloc;

  StreamSubscription _myBookingsListSubscription;
  ScrollController _listScrollController;
  bool updateBookingsList = false;

  @override
  initState(){

    _bloc = MyRequestBloc();

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

    _myBookingsListSubscription = _bloc.obsGetMyRequestsLists.stream.listen((result) {
      _bloc.setCount = (_bloc.requestsList.length);
    });

    super.initState();

    _loadNewData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: _wilPop,
      child: Scaffold(
        appBar: AppBar(title: Text(AppStrings.myRequests),),
        body: SingleChildScrollView(controller: _listScrollController,
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
                          : _getBookingsListBuilder(valueListCount);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_myBookingsListSubscription != null) {
      _myBookingsListSubscription.cancel();
      _bloc.dispose();
    }
    super.dispose();
  }

  Future<bool> _wilPop() async{
    Navigator.of(context).pop(updateBookingsList);
    return false;
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
        child: Text(AppStrings.emptyMyRequestList,
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _getBookingsListBuilder(int valueListCount) {
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
                return RequestItemWidget(index, _bloc.requestsList[index], _bloc, (bool isApprovedOrRejected){
                   updateBookingsList = true;
                  _bloc.reloadFromStart();
                  _loadNewData();
                });
              }
            }),
      ],
    );
  }
  
  _loadNewData() {
    _bloc.obsGetMyRequestsLists.sink.add(null);
    _bloc.event.add(EventModel(MyRequestBloc.GET_MY_REQUESTS));
  }

}