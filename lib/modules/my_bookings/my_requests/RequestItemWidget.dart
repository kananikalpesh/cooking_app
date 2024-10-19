
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/modules/my_bookings/MyBookingsListModel.dart';
import 'package:cooking_app/modules/my_bookings/my_requests/ApproveBookingBottomSheet.dart';
import 'package:cooking_app/modules/my_bookings/my_requests/MyRequestBloc.dart';
import 'package:cooking_app/modules/my_bookings/my_requests/RejectBookingBottomSheet.dart';
import 'package:cooking_app/modules/other_user/OtherUserProfileScreen.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDateUtils.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/services.dart';

class RequestItemWidget extends StatefulWidget{

  final int index;
  final MyBookingDetailsModel myBookingDetailsModel;
  final  MyRequestBloc myRequestBloc;
  final BookingRequest onBookingRequest;

  RequestItemWidget(this.index, this.myBookingDetailsModel, this.myRequestBloc, this.onBookingRequest);

  @override
  State<StatefulWidget> createState() => RequestItemWidgetState();

}

typedef BookingRequest(bool isApprovedOrRejected);

class RequestItemWidgetState extends State<RequestItemWidget>{

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: (){
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
      SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
      Navigator.push(context, MaterialPageRoute(builder: (context) => LessonDetailsScreen(id: widget.myBookingDetailsModel.lessonModel.id,
        cookId: widget.myBookingDetailsModel.cook.id, isFromCook: (AppData.user.role == AppConstants.ROLE_COOK), lessonBookingId: widget.myBookingDetailsModel.id,))).then((value){
        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
        SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);
      });
    },
      child: Card(margin: EdgeInsets.only(top: AppDimensions.generalPadding),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.generalPadding),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
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
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _getStartEndTimeDisplayString(),
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),

                  GestureDetector(onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder:
                        (context) => OtherUserProfileScreen(userId: widget.myBookingDetailsModel.user.id,)));
                  },
                    child: Padding(
                      padding:
                      const EdgeInsets.only(top: 8),
                      child: Text(
                        "${widget.myBookingDetailsModel.user.firstName}",
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                  ),

                  Padding(
                    padding:
                    const EdgeInsets.only(top: 8),
                    child: Text(
                      "${widget.myBookingDetailsModel.age}",
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        "${AppStrings.bookingStatus} ${widget.myBookingDetailsModel.bookingStatusMsg}",
                        style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, color: Theme.of(context).accentColor)),
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: AppDimensions.generalPadding, right: AppDimensions.generalMinPadding),
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                children: [

                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.largeTopBottomPadding),
                  child: GestureDetector(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              width: 2, color: Theme.of(context).accentColor),
                          color: Theme.of(context).accentColor,
                        ),
                        child: Center(
                          child: Icon(Icons.check, color: AppColors.white, size: 20,),
                        ),
                      ),
                    ),
                    onTap: () {
                      ApproveBookingBottomSheet().showApproveBookingSheet(context, widget.myBookingDetailsModel.id, widget.myRequestBloc).then((value){
                        if(value ?? false){
                          widget.onBookingRequest(value);
                        }
                      });
                    },
                  ),
                ),

                GestureDetector(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            width: 2, color: Theme.of(context).accentColor),
                        color: Theme.of(context).accentColor,
                      ),
                      child: Center(
                        child: Icon(Icons.close, color: AppColors.white, size: 20,),
                      ),
                    ),
                  ),
                  onTap: () {
                    RejectBookingBottomSheet().showRejectBookingSheet(context, widget.myBookingDetailsModel.id, widget.myRequestBloc).then((value){
                      if(value ?? false){
                        widget.onBookingRequest(value);
                      }
                    });
                  },
                ),

              ],),
            )
          ],
      ),
        ),),
    );
  }

  _getStartEndTimeDisplayString() {
    String displayTime = "";

    displayTime =
        "${(widget.myBookingDetailsModel?.lessonStartTime == null) ? "" : AppDateUtils.timeOnlyFormatToString(widget.myBookingDetailsModel.lessonStartTime.toLocal())}" +
            " - " +
            "${(widget.myBookingDetailsModel?.lessonEndTime == null) ? "" : AppDateUtils.timeOnlyFormatToString(widget.myBookingDetailsModel.lessonEndTime.toLocal())}";

    return displayTime;
  }

}