
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/modules/cook/profile/other_user/OtherCookProfileScreen.dart';
import 'package:cooking_app/modules/my_bookings/MyBookingsListModel.dart';
import 'package:cooking_app/modules/my_bookings/past/PastBookingsBloc.dart';
import 'package:cooking_app/modules/my_bookings/past/ReportUserBottomSheet.dart';
import 'package:cooking_app/modules/other_user/OtherUserProfileScreen.dart';
import 'package:cooking_app/modules/user/lesson/details/BookingStatusModel.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsScreen.dart';
import 'package:cooking_app/modules/video_chat/ReviewBottomSheet.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDateUtils.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BookingItemWidget extends StatefulWidget {
  final int index;
  final MyBookingDetailsModel myBookingDetailsModel;
  final bool isPastBooking;
  final PastBookingsBloc pastBookingsBloc;
  BookingItemWidget(this.index, this.myBookingDetailsModel, {this.isPastBooking = false,  this.pastBookingsBloc});

  @override
  State<StatefulWidget> createState() => BookingItemWidgetState();
}

class BookingItemWidgetState extends State<BookingItemWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: (){
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
      SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);

      Navigator.push(context, MaterialPageRoute(builder: (context) => LessonDetailsScreen(id: widget.myBookingDetailsModel.lessonModel.id,
        cookId: widget.myBookingDetailsModel.cook.id, isFromCook: (AppData.user.role == AppConstants.ROLE_COOK), lessonBookingId: widget.myBookingDetailsModel.id))).then((value){
        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
        SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);
      });
    },
      child: Card(margin: EdgeInsets.only(top: AppDimensions.generalPadding),
        child: Padding(
        padding: const EdgeInsets.all(AppDimensions.generalPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              widget.myBookingDetailsModel?.lessonModel?.name ?? "-",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.headline5,
            ),

            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "${(widget.myBookingDetailsModel?.lessonStartTime == null) ? "-" : AppDateUtils.dateOnlyFormatToString(widget.myBookingDetailsModel.lessonStartTime.toLocal())}",
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding),
              child: Text(
                _getStartEndTimeDisplayString(),
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),

            GestureDetector(onTap: (){
              if(AppData.user.role == AppConstants.ROLE_COOK){
                SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
                SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
                Navigator.push(context, MaterialPageRoute(builder:
                    (context) => OtherUserProfileScreen(userId: widget.myBookingDetailsModel.user.id,))).then((value){
                  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
                  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);
                });
              }else{
                SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
                SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
                Navigator.push(context, MaterialPageRoute(builder:
                    (context) => OtherCookProfileScreen(cookId: widget.myBookingDetailsModel.cook.id,))).then((value){
                  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
                  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);
                });
              }

            },
              child: Padding(
                padding:
                const EdgeInsets.only(top: 8),
                child: Text(
                  "${_getName() ?? ""}",
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
            ),

            _getStatusWidget(),

            Offstage(
              offstage: (!((widget.isPastBooking))),
              child: Padding(
                padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding),
                child: Row(
                  children: [

                    _canShowReviewButton() ? ActionChip(label: Text(
                        AppStrings.addReviewLabel,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.subtitle1.apply(color: AppColors.white),
                      ), backgroundColor: Theme.of(context).accentColor, onPressed: (){
                        ReviewBottomSheet.reviewSheet(
                            context,
                            widget.myBookingDetailsModel.cook.id,
                            widget.myBookingDetailsModel.lessonModel.id,
                            widget.myBookingDetailsModel.id,
                            widget.myBookingDetailsModel.user.id,
                            isOpenedFromCookSide: (AppData.user.role == AppConstants.ROLE_COOK));
                      }) : Container(),

                  Expanded(child: Container()),

                    _canShowReportButton() ? ActionChip(label: Text(((AppData.user.role == AppConstants.ROLE_USER) ? AppStrings.reportCookLabel : AppStrings.reportUserLabel),
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.subtitle1.apply(color: AppColors.white),
                    ), backgroundColor: Theme.of(context).accentColor, onPressed: (){
                      ReportUserBottomSheet().showReportUserBookingSheet(context,
                          ((AppData.user.role == AppConstants.ROLE_USER) ? widget.myBookingDetailsModel.cook.id : widget.myBookingDetailsModel.user.id),
                          widget.pastBookingsBloc, widget.myBookingDetailsModel.id);
                    }) : Container(),
                  ],
                ),
              ),
            ),



          ],
        ),
      ),),
    );
  }


  bool _canShowReportButton(){
    if(AppData.user.role == AppConstants.ROLE_USER){
      return !widget.myBookingDetailsModel.hasUserReportedTheCook;
    }else {
      return !widget.myBookingDetailsModel.hasCookReportedTheUser;
    }
  }

  bool _canShowReviewButton(){
    if(AppData.user.role == AppConstants.ROLE_USER){
      return !widget.myBookingDetailsModel.hasUserReviewedTheCook;
    }else {
      return !widget.myBookingDetailsModel.hasCookReviewedTheUser;
    }
  }

 String _getName(){
    if(AppData.user.role == AppConstants.ROLE_COOK){
      return widget.myBookingDetailsModel.user.firstName;
    }else{
      return widget.myBookingDetailsModel.cook.firstName;
    }
  }

  _getStartEndTimeDisplayString() {
    String displayTime = "";

    displayTime =
        "${(widget.myBookingDetailsModel?.lessonStartTime == null) ? "" : AppDateUtils.timeOnlyFormatToString(widget.myBookingDetailsModel.lessonStartTime.toLocal())}" +
            "-" +
            "${(widget.myBookingDetailsModel?.lessonEndTime == null) ? "" : AppDateUtils.timeOnlyFormatToString(widget.myBookingDetailsModel.lessonEndTime.toLocal())}";

    return displayTime;
  }

  Widget _getStatusWidget() {
    if (widget.myBookingDetailsModel.bookingStatus ==
            BookingStatusEnum.NEW_REQUEST.enumValue &&
        widget.myBookingDetailsModel.paymentStatus ==
            PaymentStatusEnum.NONE.enumValue) {

      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
            "${AppStrings.bookingStatus} ${widget.myBookingDetailsModel.bookingStatusMsg}",
            style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, color: Theme.of(context).accentColor)),
      );
    } else if (widget.myBookingDetailsModel.bookingStatus ==
            BookingStatusEnum.COOK_ACCEPTED.enumValue &&
        widget.myBookingDetailsModel.paymentStatus ==
            PaymentStatusEnum.NONE.enumValue) {

      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
            "${AppStrings.paymentStatus} ${widget.myBookingDetailsModel.paymentStatusMsg}",
            style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, color: Theme.of(context).accentColor)),
      );
    } else if (widget.myBookingDetailsModel.bookingStatus ==
            BookingStatusEnum.PAID_AND_BOOKED.enumValue &&
        widget.myBookingDetailsModel.paymentStatus ==
            PaymentStatusEnum.PAID.enumValue) {

      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
            "${AppStrings.bookingStatus} ${widget.myBookingDetailsModel.bookingStatusMsg}",
            style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, color: Theme.of(context).accentColor)),
      );
    } else {

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
                "${AppStrings.bookingStatus} ${widget.myBookingDetailsModel.bookingStatusMsg}",
                style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, color: Theme.of(context).accentColor)),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: AppDimensions.generalMinPadding),
            child: Text(
                "${AppStrings.paymentStatus} ${widget.myBookingDetailsModel.paymentStatusMsg}",
                style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, color: Theme.of(context).accentColor)),
          ),
        ],
      );
    }
  }
}
