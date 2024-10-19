import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/dashboard/DashboardScreen.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/AvailableSlotsListModel.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/BookLessonBloc.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/BookLessonErrorScreen.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/CalendarDateModel.dart';
import 'package:cooking_app/modules/user/profile/address/EditAddressScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDateUtils.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:cooking_app/utils/CalculationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class BookLessonScreen extends StatefulWidget {
  final LessonDetailsModel lessonModel;
  final int lessonRequestId;
  BookLessonScreen({this.lessonModel, this.lessonRequestId});

  @override
  _BookLessonScreenState createState() => _BookLessonScreenState();
}

class _BookLessonScreenState extends State<BookLessonScreen> with TickerProviderStateMixin {

  final PageController controller = new PageController();
  ValueNotifier<int> _currentIndex = ValueNotifier(0);
  CalendarController _calendarController;
  AnimationController _calendarAnimationController;
  DateTime _selectedDate;
  ValueNotifier<bool> _showSlots = ValueNotifier(false);
  ValueNotifier<bool> _showCalendar = ValueNotifier(false);
  AvailableSlotModel _selectedSlot;
  ValueNotifier<String> _validationError = ValueNotifier("");
  ValueNotifier<bool> _hideConfirmButton = ValueNotifier(true);
  ValueNotifier<DateTime> _changeDate;
  CalendarDateModel _calendarDateModel;

  BookLessonBloc _bloc;
  int _selectedSlotIndex = 0;

  @override
  void initState() {
    _bloc = BookLessonBloc();

    _bloc.obsRequestBooking.stream.listen((resultModel) {
      if(resultModel.errorCode == APIConstants.STATUS_CODE_ADDRESS_NEEDED){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditAddressScreen(isIncomplete: true, errorMsgFromBackend: resultModel.error,)));
      } else if(resultModel.errorCode == APIConstants.STATUS_CODE_ADDRESS_NEEDED){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BookLessonErrorScreen(resultModel.error)));
      } else if(resultModel.error != null){
        CommonBottomSheet.showErrorBottomSheet(context, resultModel);
      } else {
        CommonBottomSheet.showSuccessWithTimerBottomSheet(context, AppStrings.lessonBookingSuccessTitle,
            AppStrings.lessonBookingSuccessDesc, delayedTimeInSecond: 7).then((value){
          SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
          SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => DashboardScreen(selectedTabIndex: AppConstants.DASHBOARD_BOOKINGS,)),
              ModalRoute.withName(""));
        });
      }
    });

    _bloc.obsGetSlotsLists.stream.listen((resultModel) {
      if(resultModel != null){
        if(resultModel.error != null){
          _hideConfirmButton.value = true;
        } else {
          _hideConfirmButton.value = ((resultModel.data?.slotsList?.length ?? 0) == 0);
        }
      }
    });

    super.initState();
    _calendarController = CalendarController();
    _calendarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _calendarAnimationController.forward();
    _bloc.event.add(EventModel(BookLessonBloc.GET_CALENDER_DATES_EVENT, data: <String, dynamic>{
      "l": widget.lessonModel?.id ?? -1}
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseFormBodyUnsafe(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverSafeArea(top: false,
                  sliver: SliverAppBar(
                    //title: Text(lessonModel.name, style: Theme.of(context).textTheme.headline6.copyWith(color: AppColors.black, fontFamily: 'Custom', fontWeight: FontWeight.w600),),
                    pinned: true,
                    floating: false,
                    snap: false,
                    elevation: 0,
                    expandedHeight: 220,
                    backgroundColor: AppColors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      /*title: Text(lessonModel.name,
                              style: Theme.of(context).textTheme.headline6.copyWith(color: AppColors.black,),),*/
                      collapseMode: CollapseMode.parallax,
                      background: Stack(
                        children: [
                          PageView.builder(
                            onPageChanged: (index){
                              _currentIndex.value = index;
                            },
                            scrollDirection: Axis.horizontal,
                            controller: controller,
                            itemCount: widget.lessonModel?.lessonImages?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              return _imageWidget(index);
                            },
                          ),
                          Positioned(
                            right: 0,
                            left: 0,
                            bottom: 0,
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: AppDimensions.blur_radius, sigmaY: AppDimensions.blur_radius),
                                child: Container(
                                  decoration: BoxDecoration(color: AppColors.transparent.withOpacity(0.0)),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(width: AppDimensions.generalPadding,),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).accentColor,
                                                borderRadius: BorderRadius.all(Radius.circular(50)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 20, right: 20,
                                                    top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.monetization_on_outlined, color: AppColors.white, size: 20,),
                                                    SizedBox(width: 2,),
                                                    Text(AppStrings.dollar + widget.lessonModel.amount.toString() + AppStrings.usd,
                                                      style: Theme.of(context).textTheme.bodyText2.apply(
                                                        color: AppColors.white, fontWeightDelta: 2,
                                                      ),),
                                                    SizedBox(width: AppDimensions.generalPadding,),
                                                    Icon(Icons.access_time_outlined, color: AppColors.white, size: 20,),
                                                    SizedBox(width: 2,),
                                                    Text((widget.lessonModel.duration != null)
                                                        ? CalculationUtils.calculateHours(widget.lessonModel.duration) : "0" + AppStrings.hour,
                                                      style: Theme.of(context).textTheme.bodyText2.apply(color: AppColors.white),),
                                                    SizedBox(width: 10,),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: AppDimensions.generalPadding,),
                                          Offstage(
                                            offstage: true,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.white,
                                                borderRadius: BorderRadius.all(Radius.circular(50)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 20, right: 20,
                                                    top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                                                child: Text(AppStrings.buy.toUpperCase(),
                                                  style: Theme.of(context).textTheme.subtitle1.apply(color: Theme.of(context).accentColor),),
                                              ),
                                            ),
                                          ),
                                          Offstage(
                                            offstage: true,
                                            child: SizedBox(width: AppDimensions.generalPadding,),),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: ValueListenableProvider<int>.value(value: _currentIndex,
                                            child: Consumer<int>(builder: (context, currentIndex, child){
                                              return Offstage(
                                                offstage: (widget.lessonModel?.lessonImages != null && (widget.lessonModel?.lessonImages?.isEmpty == true)),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    SizedBox(
                                                      height: 25,
                                                      child: ListView.builder(
                                                        padding: EdgeInsets.only(top: AppDimensions.generalPadding,
                                                            right: AppDimensions.generalPadding),
                                                        scrollDirection: Axis.horizontal,
                                                        shrinkWrap: true,
                                                        itemCount: widget.lessonModel?.lessonImages?.length ?? 0,
                                                        itemBuilder: (context, index) {
                                                          return Padding(
                                                            padding: const EdgeInsets.only(right: AppDimensions.generalMinPadding),
                                                            child: Container(
                                                              height: 10,
                                                              width: 10,
                                                              decoration: BoxDecoration(
                                                                color: (currentIndex == index) ?  Theme.of(context).accentColor : AppColors.backgroundGrey300,
                                                                shape: BoxShape.circle,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),),
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(AppDimensions.cardRadius),
                                            topRight: Radius.circular(AppDimensions.cardRadius),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            SizedBox(height: 10,),
                                            Expanded(
                                              child: Text(AppStrings.bookLesson,
                                                style: Theme.of(context).textTheme.headline3.apply(
                                                  fontSizeDelta: -2,
                                                ),),
                                            ),
                                            Container(
                                              color: AppColors.black,
                                              height: 0.5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ];
          },
          body: StreamBuilder<ResultModel<CalendarDateModel>>(stream: _bloc.obsGetCalenderDates.stream,
              // ignore: missing_return
              builder: (context, snapshot){
                  if(snapshot?.data?.data != null){
                      _calendarDateModel = snapshot.data.data;
                      if(_selectedDate == null){
                      _selectedDate = _calendarDateModel.availableDays[0];
                      _changeDate = ValueNotifier(_selectedDate);
                      }
                  }
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if(snapshot.hasData){
                        if(snapshot.data.error != null){
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text("${snapshot?.data?.error ?? AppStrings.calenderDatesError}",
                              style: Theme.of(context).textTheme.bodyText1,
                              textAlign: TextAlign.center,)),
                          );
                        }else if(snapshot?.data?.data == null){
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text("${AppStrings.calenderDatesError}",
                              style: Theme.of(context).textTheme.bodyText1,
                              textAlign: TextAlign.center,)),
                          );
                        }else if ((snapshot?.data?.data?.availableDays?.length ?? 0) == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text("${AppStrings.noAvailabilities}",
                              style: Theme.of(context).textTheme.bodyText1,
                              textAlign: TextAlign.center,)),
                          );
                        }else{
                          return _mainCalendarParent();
                        }
                      }else{
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text("${snapshot?.error ?? AppStrings.calenderDatesError}",
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.center,)),
                        );
                      }

                  }
              }),
        ),
      ),
    );
  }

  Widget _mainCalendarParent(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: mainContainerWidget(),
          ),
        ),
        ValueListenableProvider<String>.value(
          value: _validationError,
          child: Consumer<String>(
            builder: (context, value, child) {
              return Offstage(
                offstage: ((value?.isEmpty ?? true)),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.generalPadding,
                    right: AppDimensions.generalPadding,
                    top: AppDimensions.maxPadding,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "$value",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.errorTextColor),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ValueListenableProvider<bool>.value(
          value: _hideConfirmButton,
          child: Consumer<bool>(
            builder: (context, hideButton, child){
              return Offstage(
                offstage: hideButton,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
                    right: AppDimensions.generalPadding, top: AppDimensions.generalPadding,
                    bottom: AppDimensions.maxPadding,),
                  child: Column(
                    children: [
                      ValueListenableProvider<bool>.value(
                          value: _bloc.isLoadingForRequest,
                          child: Consumer<bool>(
                              builder: (context, isLoading, child){
                                return isLoading ? _getLoaderWidget() : _getButton();
                              })
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _imageWidget(int index){
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: (widget.lessonModel?.lessonImages != null && (widget.lessonModel?.lessonImages?.isNotEmpty == true))
          ? widget.lessonModel.lessonImages[index].filePath : "",
      progressIndicatorBuilder: (context,
          url, downloadProgress) =>
          Image.asset(
            "assets/loading_image.png",
          ),
      errorWidget:
          (context, url, error) =>
          Image.asset(
            "assets/error_image.png",
            color: AppColors.grayColor,
          ),
    );
  }

  Widget _getButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_selectedSlot != null){
                _validationError.value = "";
                Map<String, dynamic> requestData = <String, dynamic>{
                  "l": widget.lessonModel?.id ?? -1,
                  "d": _selectedSlot.startTimeString,
                  if(widget.lessonRequestId != null) "b": widget.lessonRequestId,
                };

                _bloc.event.add(EventModel(BookLessonBloc.SEND_BOOKING_REQUEST_EVENT, data: requestData));
              } else {
                _validationError.value = AppStrings.bookLessonValidation;
              }
            },
            child: Text(AppStrings.confirmAndRequest),
          ),
        ),
      ],
    );
  }

  Widget _getLoaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator()],
      ),
    );
  }

  Widget mainContainerWidget(){
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: AppDimensions.generalPadding, bottom: AppDimensions.generalPadding),
      child: ValueListenableProvider<bool>.value(
        value: _showSlots,
        child: Consumer<bool>(
          builder: (context, shouldShowSlots, child){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.lessonModel?.name ?? "", style: Theme.of(context).textTheme.headline4,),
                SizedBox(height: AppDimensions.generalPadding,),
                ValueListenableProvider<bool>.value(
                  value: _showCalendar,
                  child: Consumer<bool>(
                    builder: (context, showCalendar, child){
                      return Offstage(
                        offstage: showCalendar,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /*Align(alignment: Alignment.center,
                                child: Text(widget.lessonModel?.creatorModel?.cookAvailabilityString ?? "",
                                  style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,)),*/
                            Padding(
                              padding: const EdgeInsets.all(AppDimensions.generalPadding),
                              child: Card(child: Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: _buildTableCalendarWithBuilders(),
                              )),
                            ),
                            SizedBox(height: AppDimensions.generalPadding,),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Offstage(
                  offstage: (!shouldShowSlots),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ValueListenableProvider<DateTime>.value(
                            value: _changeDate,
                            child: Consumer<DateTime>(
                              builder: (context, dateTime, child){
                                return Text(AppDateUtils.availableSlotsFormat(dateTime).toUpperCase(),
                                  style: Theme.of(context).textTheme.headline5,);
                              },
                            ),
                          ),
                          SizedBox(width: AppDimensions.generalPadding,),
                          GestureDetector(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      width: 0, color: Theme.of(context).accentColor),
                                  color: Theme.of(context).accentColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Center(
                                    child: Icon(Icons.edit, color: AppColors.white, size: 20,),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              _showCalendar.value = !_showCalendar.value;
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Align(
                        alignment: Alignment.center,
                        child: Text("${AppStrings.slotNote} ${CalculationUtils.calculateHours(widget.lessonModel?.duration)}",
                          style: Theme.of(context).textTheme.bodyText2.apply(
                              fontStyle: FontStyle.italic
                          ),),
                      ),
                    ],
                  ),
                ),
                Offstage(
                  offstage: (!shouldShowSlots),
                  child: StreamBuilder(
                      stream: _bloc.obsGetSlotsLists.stream,
                      builder: (BuildContext context, AsyncSnapshot<ResultModel<AvailableSlotsListModel>> snapshot) {
                        if(snapshot.hasData){
                          var _slotsList = snapshot.data?.data?.slotsList;
                          if(_selectedSlot == null) _selectedSlot = ((_slotsList?.length ?? 0) == 0) ? null : _slotsList[0];
                          return ((_slotsList?.length ?? 0) == 0) ?
                          Padding(
                            padding: const EdgeInsets.only(top: AppDimensions.generalPadding),
                            child: Center(
                              child: Text(AppStrings.emptySlotsData,
                                style: Theme.of(context).textTheme.bodyText1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ) :
                          Center(
                            child: Column(
                              children: [
                                Offstage(offstage: (snapshot?.data?.data?.warningMessage?.isEmpty ?? true),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(snapshot?.data?.data?.warningMessage ?? "",
                                      style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.errorTextColor),),
                                  ),
                                ),
                                GridView.builder(
                                    padding: EdgeInsets.only(top: AppDimensions.generalPadding, bottom: AppDimensions.generalPadding,
                                        left: AppDimensions.generalTopPadding, right: AppDimensions.generalTopPadding),
                                    itemCount: _slotsList.length,
                                    shrinkWrap: true,
                                    primary: false,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1, //(MediaQuery.of(context).size.width > 600) ? 3 : 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 20,
                                      childAspectRatio: 6.5, //3.5
                                    ),
                                    itemBuilder: (context, index) {
                                      return _SlotItem(_slotsList[index], index, _selectedSlotIndex, (AvailableSlotModel model, int slotIndex) {
                                        _selectedSlot = model;
                                        _selectedSlotIndex = slotIndex;
                                        setState(() {});
                                      });
                                    }),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError){
                          return Center(child: Text(snapshot.error,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.center,
                          ),);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AppDimensions.generalPadding),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      //locale: 'en_EN',
      calendarController: _calendarController,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats:  {
        CalendarFormat.month: "${AppStrings.labelMonth} ${new String.fromCharCodes(new Runes('\u25BC'))}",
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekdayStyle: Theme.of(context).textTheme.bodyText1,
        weekendStyle: Theme.of(context).textTheme.bodyText1,
        holidayStyle: Theme.of(context).textTheme.bodyText1,
        outsideHolidayStyle: Theme.of(context).textTheme.bodyText1.apply(color: AppColors.grayColor),
        outsideWeekendStyle: Theme.of(context).textTheme.bodyText1.apply(color: AppColors.grayColor),
        outsideStyle: Theme.of(context).textTheme.bodyText1.apply(color: AppColors.grayColor),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: Theme.of(context).textTheme.caption,
        weekdayStyle: Theme.of(context).textTheme.caption,
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
        titleTextStyle: Theme.of(context).textTheme.headline5.apply(color: Theme.of(context).buttonColor),
        leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).buttonColor,),
        rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).buttonColor,),
      ),
      rowHeight: 40,
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_calendarAnimationController),
            child: Container(
              margin: const EdgeInsets.all(1.0),
              padding: const EdgeInsets.only(top: 1.0, left: 1.0),
              decoration: BoxDecoration(color: Theme.of(context).accentColor,
                shape: BoxShape.circle,),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: Theme.of(context).textTheme.bodyText1.apply(color: AppColors.white),
                ),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(1.0),
            padding: const EdgeInsets.only(top: 1.0, left: 1.0),
            decoration: BoxDecoration(color: AppColors.backgroundGrey300,
              shape: BoxShape.circle,),
            child: Center(
              child: Text(
                '${date.day}',
                style: Theme.of(context).textTheme.bodyText1.apply(color: AppColors.grayColor),
              ),
            ),
          );
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events);
        _calendarAnimationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
      startDay: _calendarDateModel.calendarStarDate, //DateTime.now().add(Duration(days: START_DAY_ON_CALENDAR)),
      endDay: _calendarDateModel.calendarEndDate, //DateTime.now().add(Duration(days: END_DAY_ON_CALENDAR)),
      initialSelectedDay: _selectedDate,
      enabledDayPredicate: (date){
        return _isDayAvailable(date);
      },
    );
  }

  bool _isDayAvailable(DateTime date){
    bool isAvailable = false;

    for(int i = 0; i < (_calendarDateModel.availableDays?.length ?? 0); i++){
      DateTime availableDay = _calendarDateModel.availableDays[i];
      if(availableDay.day == date.day && availableDay.month == date.month && availableDay.year == date.year){
        isAvailable = true;
        break;
      }
    }

    return isAvailable;
  }

  void _onDaySelected(DateTime date, List events) {
    _showSlots.value = true;
    _showCalendar.value = true;

    _selectedDate = date;

    _changeDate.value = _selectedDate;
    Map<String, dynamic> requestData = <String, dynamic>{
      "l": widget.lessonModel?.id ?? -1,
      "d": date.toUtc().toIso8601String()
    };
    _bloc.obsGetSlotsLists.sink.add(null);
    _bloc.event.add(EventModel(BookLessonBloc.GET_AVAILABLE_SLOTS_EVENT, data: requestData));
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
  }

  void _onCalendarCreated(DateTime first, DateTime last, CalendarFormat format) {
  }

}

typedef _UpdateSelectedCallback(AvailableSlotModel model, int selectedIndex);

class _SlotItem extends StatefulWidget{

  final AvailableSlotModel _slotModel;
  final int index;
  final _UpdateSelectedCallback _callback;
  int _selectedSlotIndex;
  _SlotItem(this._slotModel, this.index, this._selectedSlotIndex, this._callback);

  @override
  _SlotItemState createState() => _SlotItemState();
}

class _SlotItemState extends State<_SlotItem>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
          widget._selectedSlotIndex = widget.index;
          widget._callback(widget._slotModel, widget._selectedSlotIndex);
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.generalRadius)),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Theme.of(context).accentColor,
              ),
              color: (widget._selectedSlotIndex == widget.index) ? Theme.of(context).accentColor : AppColors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.generalRadius))
          ),
          child: Center(
            child: Text("${AppDateUtils.timeOnlyFormatToString(widget._slotModel?.startTimeUtc?.toLocal())} - ${AppDateUtils.timeOnlyFormatToString(widget._slotModel?.endTimeUtc?.toLocal())}",
              style: Theme.of(context).textTheme.subtitle1.apply(
                color: (widget._selectedSlotIndex == widget.index) ? AppColors.white : Theme.of(context).accentColor,
              ), textScaleFactor: 1.0,
            ),
          ),
        ),
      ),
    );
  }

}
