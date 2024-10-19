
import 'dart:async';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsBloc.dart';
import 'package:cooking_app/modules/user/lesson/result/ResultItemWidget.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtherLessonsScreen extends StatefulWidget {

  final int cookId;

  OtherLessonsScreen({this.cookId});

  @override
  _OtherLessonsScreenState createState() => _OtherLessonsScreenState();
}

class _OtherLessonsScreenState extends State<OtherLessonsScreen> {

  static const PAGE_SIZE = 10;

  LessonDetailsBloc _bloc;
  StreamSubscription _lessonListSubscription;
  ScrollController _listScrollController;

  @override
  void initState() {

    _bloc = LessonDetailsBloc(PAGE_SIZE);

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

    _lessonListSubscription = _bloc.obsGetLessonsLists.stream.listen((result) {
      _bloc.setCount = (_bloc.lessonsList.length);
      if (result?.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context, result);
      }
    });

    _loadNewData();

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.otherLessonTitle)),
      body: BaseFormBodyUnsafe(
        child: SingleChildScrollView(
          controller: _listScrollController,
          child: ValueListenableProvider<bool>.value(
            value: _bloc.isLoadingFirstPage,
            child: Consumer<bool>(
              builder: (context, isLoadingFirstPage, child) {
                return ValueListenableProvider<int>.value(
                  value: _bloc.getCount,
                  child: Consumer<int>(
                    builder: (context, valueListCount, child) {
                      return (isLoadingFirstPage)
                          ?  _getInitialLoaderWidget()
                          : (valueListCount == 0)
                          ? _getEmptyListWidget()
                          : _getLessonListBuilder(valueListCount);
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

  Widget _getEmptyListWidget() {
    var height = MediaQuery.of(context).size.height/2;
    return Container(
      height: height,
      child: Center(
        child: Text(AppStrings.emptyLessonData,
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _getInitialLoaderWidget() {
    var height = MediaQuery.of(context).size.height/2;
    return Container(
      height: height,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  _loadNewData() {
    var _otherLessonsData = <String, dynamic>{
      "c": [widget.cookId],
    };
    _bloc.obsGetLessonsLists.sink.add(null);
    _bloc.event.add(EventModel(LessonDetailsBloc.GET_OTHER_LESSONS_EVENT, data: _otherLessonsData));
  }

  Widget _getLessonListBuilder(int valueListCount) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: valueListCount + 1,
        padding: EdgeInsets.only(left: AppDimensions.generalPadding,
            right: AppDimensions.generalPadding),
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
            return ResultItemWidget(lessonModel: _bloc.lessonsList[index], index: index, isFromHomeScreen: false,);
          }
        });
  }

  @override
  void dispose() {
    if (_lessonListSubscription != null) {
      _lessonListSubscription.cancel();
      _bloc.dispose();
    }
    super.dispose();
  }

}
