
import 'dart:async';

import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/cook/lesson/create_lesson/CreateLessonScreen.dart';
import 'package:cooking_app/modules/cook/lesson/my_lessons/LessonItemWidget.dart';
import 'package:cooking_app/modules/cook/lesson/my_lessons/MyLessonsBloc.dart';
import 'package:cooking_app/modules/cook/profile/CookProfileBloc.dart';
import 'package:cooking_app/modules/cook/profile/availabilities/ManageAvailabilitiesScreen.dart';
import 'package:cooking_app/modules/cook/profile/edit_profile/EditProfileScreen.dart';
import 'package:cooking_app/modules/dashboard/ConnectStripeBottomSheet.dart';
import 'package:cooking_app/modules/dashboard/DashboardBloc.dart';
import 'package:cooking_app/modules/stripe_payment/OnboardingModel.dart';
import 'package:cooking_app/modules/stripe_payment/StripeOnboardingScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MyLessonsScreen extends StatefulWidget{

  final DashboardBloc dashBoardBloc;

  MyLessonsScreen(this.dashBoardBloc);

  @override
  State<StatefulWidget> createState() => MyLessonsScreenState();

}

class MyLessonsScreenState extends State<MyLessonsScreen>{

  MyLessonsBloc _bloc;

  StreamSubscription _myLessonListSubscription;
  ScrollController _listScrollController;
  //UserModel cookModel;
  CookProfileBloc cookBloc;

  @override
  initState(){
    cookBloc = CookProfileBloc();
    cookBloc.obsGetUserProfile.stream.listen((result) {
      if (result.error == null) {
        AppData.user = result.data;
        if(AppData.user.role == AppConstants.ROLE_COOK){
          widget.dashBoardBloc.updateCookDashBoardBottomBar.value = (!widget.dashBoardBloc.updateCookDashBoardBottomBar.value);
        }
      }
    });

    cookBloc.event.add(EventModel(CookProfileBloc.GET_PROFILE_EVENT, data: AppData.user.id));

    _bloc = MyLessonsBloc();

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

    _myLessonListSubscription = _bloc.obsGetMyLessonsLists.stream.listen((result) {
      _bloc.setCount = (_bloc.lessonsList.length);
    });

    _bloc.obsDeleteMyLessonsLists.stream.listen((resultModel) {
      if(resultModel.error != null){
        _bloc.indexProcessingLesson.value = -1;
        CommonBottomSheet.showErrorBottomSheet(context, resultModel);
      }else{
        _bloc.lessonsList.removeAt(_bloc.indexProcessingLesson.value);
        _bloc.indexProcessingLesson.value = -1;
        _bloc.setCount = (_bloc.lessonsList.length);
      }
    });

    super.initState();

    _loadNewData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(controller: _listScrollController,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.generalPadding),
          child: Row(children: [
            Expanded(child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 8.0),
              child: Text(AppStrings.myLessons, style: Theme.of(context).textTheme.headline5),
            )),
            IconButton(icon: Icon(Icons.add_circle, color: AppColors.colorAccent, size: 30,), onPressed: () async {
              if ((AppData.user.aboutMe?.isEmpty ?? true) || (AppData.user.cooksCuisines?.isEmpty ?? true)) {

                SystemChrome.setEnabledSystemUIOverlays(
                    [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(AppData.user, cookBloc, isInComplete: true))).then((value){
                  SystemChrome.setEnabledSystemUIOverlays(
                      [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);
                  cookBloc.event.add(EventModel(CookProfileBloc.GET_PROFILE_EVENT, data: AppData.user.id));
                });
              } else if (AppData.user.cookAvailabilities?.isEmpty ?? true) {

                SystemChrome.setEnabledSystemUIOverlays(
                    [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
                Navigator.push(context, MaterialPageRoute(builder: (context) => ManageAvailabilitiesScreen(cookBloc: cookBloc, isInComplete: true))).then((value){
                  SystemChrome.setEnabledSystemUIOverlays(
                      [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);
                  cookBloc.event.add(EventModel(CookProfileBloc.GET_PROFILE_EVENT, data: AppData.user.id));
                });
              } else if(AppData.user.pgStatus.block == true){

                ResultModel<OnboardingModel> result = await ConnectStripeBottomSheet.connectStripSheet(context, cookBloc);
                ///Handle result after connectStripSheet returns result.
                if(result != null){
                _handleOnBoardingResult(result);
                }
              }else {
                SystemChrome.setEnabledSystemUIOverlays(
                    [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateLessonScreen())).then((value){
                  SystemChrome.setEnabledSystemUIOverlays(
                      [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);

                  _bloc.reloadFromStart();
                  _loadNewData();

                });
              }
            }),
          ],),
        ),
        ValueListenableProvider<bool>.value(
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
        SizedBox(height: AppDimensions.maxPadding,),
      ],
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
    var height = MediaQuery.of(context).size.height/1.5;
    return Container(
      height: height,
      child: Center(
        child: Text(AppStrings.emptyMyLessonList,
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _getLessonListBuilder(int valueListCount) {
    return Column(
      children: [
        ListView.builder(
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
                return LessonItemWidget(lessonModel: _bloc.lessonsList[index], index: index, isFromHomeScreen: true, myLessonsBloc: _bloc, onLessonUpdate: (bool isCreatedOrUpdated){
                  _bloc.reloadFromStart();
                  _loadNewData();
                },);
              }
            }),
      ],
    );
  }

  _handleOnBoardingResult(ResultModel<OnboardingModel> result) async {

    if (result.error != null) {
      CommonBottomSheet.showErrorBottomSheet(context, result);
    } else {
      var paymentModel = result.data;

      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
      SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
      var response = await Navigator.of(context)
          .push(MaterialPageRoute(
          builder: (context) => StripeOnboardingScreen(url: paymentModel.link,
            refreshUrl: paymentModel.refreshUrl, returnUrl: paymentModel.returnUrl,)));
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
      SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);

      if (response != null && !(response is bool)){
        //Failed
        CommonBottomSheet.showErrorBottomSheet(context, ResultModel(error: AppStrings.accFailedDesc,),
          title: AppStrings.accFailedTitle,);
      }

      cookBloc.event.add(EventModel(CookProfileBloc.GET_PROFILE_EVENT, data: AppData.user.id));
    }

  }

  _loadNewData() {
    _bloc.obsGetMyLessonsLists.sink.add(null);
    _bloc.event.add(EventModel(MyLessonsBloc.GET_MY_LESSONS));
  }

}