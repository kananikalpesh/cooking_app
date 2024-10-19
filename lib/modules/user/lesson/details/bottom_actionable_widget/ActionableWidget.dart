
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/dashboard/DashboardScreen.dart';
import 'package:cooking_app/modules/stripe_payment/StripePaymentScreen.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/BookLessonScreen.dart';
import 'package:cooking_app/modules/user/lesson/details/BookingStatusModel.dart';
import 'package:cooking_app/modules/user/lesson/details/bottom_actionable_widget/ActionableWidgetBloc.dart';
import 'package:cooking_app/modules/user/lesson/details/bottom_actionable_widget/CancelBookingBottomSheet.dart';
import 'package:cooking_app/modules/video_chat/CallScreen.dart';
import 'package:cooking_app/utils/AppDateUtils.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ActionableWidget extends StatefulWidget{

  final bool isFromCook;
  final BookingStatusModel bookingStatusModel;
  final LessonDetailsModel lessonDetailsModel;

  ActionableWidget({this.isFromCook, this.bookingStatusModel, this.lessonDetailsModel});

  @override
  _ActionableWidgetState createState() => _ActionableWidgetState();

}

class _ActionableWidgetState extends State<ActionableWidget>{

  ActionableWidgetBloc _bloc;
  ValueNotifier<bool> showCallButton = ValueNotifier(false);
  DateTime startTime;
  DateTime endTime;
  DateTime currentTime;

  @override
  void initState() {
    _bloc = ActionableWidgetBloc(widget.isFromCook);

    currentTime = DateTime.now();
    startTime = widget.bookingStatusModel?.lessonStartTimeUtc?.toLocal();
    endTime = widget.bookingStatusModel?.lessonEndTimeUtc?.toLocal();

    startTime = startTime?.subtract(Duration(seconds: widget.bookingStatusModel?.videoCallBufferInSec ?? 0));
    endTime = endTime?.subtract(Duration(seconds: widget.bookingStatusModel?.videoCallBufferInSec ?? 0));

    _bloc.obsCancelRequest.stream.listen((result) {
      if (result.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context, result);
      } else {
        CommonBottomSheet.showSuccessWithTimerBottomSheet(context,
            AppStrings.bookingCancelledTitle, AppStrings.bookingCancelledDesc).then((value){
          SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
          SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => DashboardScreen()),
              ModalRoute.withName(""));
        });
      }
    });

    _bloc.obsPaymentDetails.stream.listen((result) async {
      if (result.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context, result);
      } else {
        var paymentModel = result.data;
        var response = await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => StripePaymentScreen(sessionId: paymentModel.sessionId, apiKey: paymentModel.apiKey,
            clientId: paymentModel.clientRefId, successUrl: paymentModel.successUrl, failUrl: paymentModel.failureUrl,),
        ));

        if (response != null && (response is bool)){
          //Success
          CommonBottomSheet.showSuccessWithTimerBottomSheet(context, AppStrings.paymentSuccessTitle,
              AppStrings.paymentSuccessDesc, delayedTimeInSecond: 7).then((value){
            SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
            SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => DashboardScreen(selectedTabIndex: AppConstants.DASHBOARD_BOOKINGS,)),
                ModalRoute.withName(""));
          });
        } else if (response != null && !(response is bool)){
          //Failed
          CommonBottomSheet.showErrorBottomSheet(context, ResultModel(error: AppStrings.paymentFailedDesc,),
            title: AppStrings.paymentFailedTitle,);
        } else {
          //Cancelled
          CommonBottomSheet.showErrorBottomSheet(context, ResultModel(error: AppStrings.paymentCancelledDesc,),
            title: AppStrings.paymentCancelledTitle,);
        }
      }
    });

    super.initState();

    if (startTime != null && endTime != null){
      if(currentTime.compareTo(startTime) < 0){
        Future.delayed(startTime.difference(currentTime), (){
          if(startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now())){
            showCallButton.value = true;
            _hideCallButtonOnEndTime();
          }else {
            showCallButton.value = false;
          }
        });
      }else if(currentTime.compareTo(startTime) >= 0){
        showCallButton.value = true;
        _hideCallButtonOnEndTime();
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    Widget bottomWidget;
    if ((!widget.isFromCook) && (widget.bookingStatusModel != null)
        && (widget.bookingStatusModel.bookingStatus == BookingStatusEnum.NEW_REQUEST.enumValue)
        && (widget.bookingStatusModel.paymentStatus == PaymentStatusEnum.NONE.enumValue)) {
      //show msg that request sent
      bottomWidget = _showNewRequestMsg();
    } else if ((!widget.isFromCook) && (widget.bookingStatusModel != null)
        && (widget.bookingStatusModel.bookingStatus == BookingStatusEnum.COOK_ACCEPTED.enumValue)
        && ((widget.bookingStatusModel.paymentStatus == PaymentStatusEnum.NONE.enumValue)
            || (widget.bookingStatusModel.paymentStatus == PaymentStatusEnum.RETRY.enumValue)
            || (widget.bookingStatusModel.paymentStatus == PaymentStatusEnum.FAILED.enumValue))) {
      // Show proceed to pay button to user/payment not received msg to cook
      bottomWidget = _getProceedToPayButton();
    } else if ((widget.bookingStatusModel != null)
        && (widget.bookingStatusModel.bookingStatus == BookingStatusEnum.PAID_AND_BOOKED.enumValue)
        && (widget.bookingStatusModel.paymentStatus == PaymentStatusEnum.PAID.enumValue)) {
      //Payment done show cancel button/go live button
      bottomWidget = (!widget.isFromCook) ? _getButtonsAfterPaidForUser() : _getButtonsAfterPaidForCook();
    } else if(!widget.isFromCook && (widget.bookingStatusModel != null)
        && (widget.bookingStatusModel.bookingStatus == PaymentStatusEnum.REFUNDED.enumValue)) {
      //Refunded, show book button to user
      bottomWidget = Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: [_generalMsg(), _getBookButton(),],
      );
    } else if(!widget.isFromCook && widget.bookingStatusModel == null) {
      //If it is not already booked, show book button to user
      bottomWidget = _getBookButton();
    } else if (widget.isFromCook && widget.bookingStatusModel == null) {
      //If Cook wants to see his/her lessons details from my lesson section
      bottomWidget = Container();
    } else {
      bottomWidget = _generalMsg();
    }
    return bottomWidget;
  }

  Widget _getBookButton(){
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                    builder: (context) => BookLessonScreen(lessonModel: widget.lessonDetailsModel,)));
              },
              child: Text(AppStrings.bookLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showNewRequestMsg(){
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("${AppStrings.bookingRequestedFor} ${AppDateUtils.dateOnlyFormatToString(widget.bookingStatusModel.lessonStartTimeUtc.toLocal())}, ${AppDateUtils.timeOnlyFormatToString(widget.bookingStatusModel.lessonStartTimeUtc.toLocal())} - ${AppDateUtils.timeOnlyFormatToString(widget.bookingStatusModel.lessonEndTimeUtc.toLocal())}",
            style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
          SizedBox(height: 10,),
          Text("${AppStrings.bookingStatus} ${widget.bookingStatusModel.bookingStatusMsg}\n${AppStrings.paymentStatus} ${widget.bookingStatusModel.paymentStatusMsg}",
            style: Theme.of(context).textTheme.subtitle2,
            textAlign: TextAlign.center,),
          SizedBox(height: 10,),
          _getRescheduleButton(),
        ],
      ),
    );
  }

  Widget _generalMsg(){
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Center(
        child: Text("${AppStrings.bookingStatus} ${widget.bookingStatusModel.bookingStatusMsg}\n${AppStrings.paymentStatus} ${widget.bookingStatusModel.paymentStatusMsg}",
          style: Theme.of(context).textTheme.subtitle2,
          textAlign: TextAlign.center,),
      ),
    );
  }

  Widget _getProceedToPayButton(){
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: ValueListenableProvider<bool>.value(
        value: _bloc.isLoadingForPayment,
        child: Consumer<bool>(
          builder: (context, isLoading, child){
            return (isLoading) ? CircularProgressIndicator()
                : Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      var _requestData = <String, dynamic>{
                        "l": widget.lessonDetailsModel.id,
                        "lb": widget.bookingStatusModel.lessonBookingId,
                      };
                      _bloc.event.add(EventModel(ActionableWidgetBloc.LESSON_BOOKING_PAYMENT, data: _requestData));
                    },
                    child: Text(AppStrings.proceedToPay),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _getButtonsAfterPaidForUser(){
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("${AppStrings.bookedFor} ${AppDateUtils.dateOnlyFormatToString(widget.bookingStatusModel.lessonStartTimeUtc.toLocal())}, ${AppDateUtils.timeOnlyFormatToString(widget.bookingStatusModel.lessonStartTimeUtc.toLocal())} - ${AppDateUtils.timeOnlyFormatToString(widget.bookingStatusModel.lessonEndTimeUtc.toLocal())}",
            style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
          SizedBox(height: 10,),
          ValueListenableProvider<bool>.value(
            value: showCallButton,
            child: Consumer<bool>(
                builder: (context, showCallButton, child){
                  return showCallButton ? _getCallButton()
                      : _getCancelButton();
                }),
          ),
        ],
      ),
    );
  }

  Widget _getButtonsAfterPaidForCook(){
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("${AppStrings.bookedFor} ${AppDateUtils.dateOnlyFormatToString(widget.bookingStatusModel.lessonStartTimeUtc.toLocal())}, ${AppDateUtils.timeOnlyFormatToString(widget.bookingStatusModel.lessonStartTimeUtc.toLocal())} - ${AppDateUtils.timeOnlyFormatToString(widget.bookingStatusModel.lessonEndTimeUtc.toLocal())}",
            style: Theme.of(context).textTheme.subtitle1, textAlign: TextAlign.center,),
          SizedBox(height: 10,),
          ValueListenableProvider<bool>.value(
            value: showCallButton,
            child: Consumer<bool>(
                builder: (context, showCallButton, child){
                  return showCallButton ? _getCallButton()
                      : _getCancelButton();
                }),
          ),
        ],
      ),
    );
  }

  Widget _getCallButton(){
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              //Initiate call
              _startCall();
            },
            child: Text(AppStrings.callLabel),
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

  Widget _getCancelButton(){
    currentTime = DateTime.now();
    return (currentTime.isBefore(widget.bookingStatusModel?.cancellableBeforeUtc?.toLocal()))
        ? ValueListenableProvider<bool>.value(
      value: _bloc.isLoading,
      child: Consumer<bool>(
          builder: (context, isLoading, child){
            return isLoading ? _getLoaderWidget() : Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      var _lessonData = <String, dynamic>{
                        "lr": widget.bookingStatusModel.lessonBookingId,
                      };
                      (widget.isFromCook) ? CancelBookingBottomSheet.showCancelBookingSheet(context, widget.bookingStatusModel.lessonBookingId,
                        widget.isFromCook,).then((value){
                          if (value != null && (value is bool)){
                            CommonBottomSheet.showSuccessWithTimerBottomSheet(context,
                                AppStrings.cookBookingCancelledTitle, AppStrings.cookBookingCancelledDesc).then((value){
                              SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
                              SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => DashboardScreen()),
                                  ModalRoute.withName(""));
                            });
                          }
                      })
                          : _bloc.event.add(EventModel(ActionableWidgetBloc.CANCEL_LESSON_BOOKING_REQUEST, data: _lessonData));
                    },
                    child: Text(AppStrings.cancelBooking),
                  ),
                ),
              ],
            );
          }),
    ) 
        : Container();
  }

  Widget _getRescheduleButton(){
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                  builder: (context) => BookLessonScreen(lessonModel: widget.lessonDetailsModel, lessonRequestId: widget.bookingStatusModel.lessonBookingId,)));
            },
            child: Text(AppStrings.rescheduleLabel),
          ),
        ),
      ],
    );
  }

  _hideCallButtonOnEndTime(){
    Future.delayed(endTime.difference(DateTime.now()), (){
      if(startTime.isBefore(DateTime.now()) && endTime.isBefore(DateTime.now())){
        showCallButton.value = false;
      }else {
        showCallButton.value = true;
        _hideCallButtonOnEndTime();
      }
    });
  }

  //Ids for quick call test.
  //Test1 Id = 4441823
  //Test3 Id = 4441851
  // TestUser4 = 4459156

  void _startCall() {
    P2PSession callSession = AppData.callClient.createCallSession(
        CallType.VIDEO_CALL, Set.from([int.parse(widget.bookingStatusModel?.ccDetailsModel?.ccId ?? -1)
    ]));
    AppData.currentCall = callSession;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(callSession, false,
          calleeName: widget.bookingStatusModel?.ccDetailsModel?.name ?? "",
          calleeId: int.parse(widget.bookingStatusModel?.ccDetailsModel?.ccId ?? -1),
          cookId: widget.lessonDetailsModel.creatorModel.id, lessonId: widget.lessonDetailsModel.id,
            userId: widget.bookingStatusModel.user.id, lessonBookingId: widget.bookingStatusModel.lessonBookingId,
            hasCookReviewedTheUser: ((widget.bookingStatusModel?.hasCookReviewedTheUser ?? false) ? 1 : 0),
            hasUserReviewedTheCook: ((widget.bookingStatusModel?.hasUserReviewedTheCook ?? false) ? 1 : 0)),
      ),
    ).then((value){
      setState(() {});
    });
  }

}