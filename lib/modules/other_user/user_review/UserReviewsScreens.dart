import 'dart:async';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/cook/profile/other_user/other_cook_reviews/OtherCookReviewItemWidget.dart';
import 'package:cooking_app/modules/other_user/user_review/UserReviewsBloc.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserReviewsScreens extends StatefulWidget{
  final int userId;
  final String userName;
  final bool isCook;

  UserReviewsScreens(this.userId, this.userName, {this.isCook = false});

  @override
  State<StatefulWidget> createState() => UserReviewsScreensState();

}

class UserReviewsScreensState extends State<UserReviewsScreens>{

  UserReviewsBloc _bloc;

  StreamSubscription _myLessonListSubscription;
  ScrollController _listScrollController;

  @override
  initState(){
    _bloc = UserReviewsBloc(widget.isCook);

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

    _myLessonListSubscription = _bloc.obsGetReviewsLists.stream.listen((result) {
      _bloc.setCount = (_bloc.reviewsList.length);
    });

    super.initState();

    _loadNewData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.userName} ${AppStrings.reviewsLabel}")),
      body: BaseFormBodyUnsafe(
        child: SingleChildScrollView(
          controller: _listScrollController,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.generalPadding),
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
                            : _getLessonListBuilder(valueListCount);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_myLessonListSubscription != null) {
      _myLessonListSubscription.cancel();
      _bloc.dispose();
    }
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
    var height = MediaQuery.of(context).size.height/2;
    return Container(
      height: height,
      child: Center(
        child: Text(AppStrings.emptyReviewData,
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _getLessonListBuilder(int valueListCount) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          primary: false,
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: valueListCount + 1,
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
              return OtherCookReviewItemWidget(reviewModel: _bloc.reviewsList[index], index: index);
            }
          },
        ),
      ],
    );
  }

  _loadNewData() {
    _bloc.obsGetReviewsLists.sink.add(null);
    _bloc.event.add(EventModel(UserReviewsBloc.GET_OTHER_USER_REVIEWS, data: widget.userId));
  }

}