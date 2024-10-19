import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:cooking_app/utils/CalculationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtherCookLessonItemWidget extends StatefulWidget {

  final LessonDetailsModel lessonModel;
  final int index;
  OtherCookLessonItemWidget({this.lessonModel, this.index});

  @override
  State<StatefulWidget> createState() => OtherCookLessonItemWidgetState();
}

class OtherCookLessonItemWidgetState extends State<OtherCookLessonItemWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16/6,
              child: Card(
                elevation: 0,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: (widget.lessonModel?.lessonImages != null && widget.lessonModel?.lessonImages?.isNotEmpty == true)
                      ? widget.lessonModel?.lessonImages?.first?.filePath : "",
                  placeholder: (context, _) => Image.asset("assets/loading_image.png"),
                  errorWidget: (context, string, _) => Image.asset("assets/error_image.png", color: AppColors.grayColor,),
                ),
              ),
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: AppDimensions.generalMinPadding, right: AppDimensions.generalMinPadding),
                    child: Row(
                      children: [
                        Expanded(child: Text(widget.lessonModel.name, overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline5,)),
                        SizedBox(width: 5,),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.generalPadding,left: AppDimensions.generalMinPadding, right: AppDimensions.generalMinPadding),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.monetization_on_outlined, color: Theme.of(context).accentColor, size: 20,),
                            SizedBox(width: 2,),
                            Text(AppStrings.dollar + widget.lessonModel.amount.toString() + AppStrings.usd,
                              style: Theme.of(context).textTheme.bodyText2,),
                            SizedBox(width: AppDimensions.generalMinPadding,),
                            Icon(Icons.access_time_outlined, color: Theme.of(context).accentColor, size: 20,),
                            SizedBox(width: 2,),
                            Text((widget.lessonModel.duration != null)
                                ? CalculationUtils.calculateHours(widget.lessonModel.duration) : "0" + AppStrings.hour,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyText2,),
                            SizedBox(width: 10,),
                          ],
                        ),
                      ],
                    ),
                  )
                ],),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey300,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: AppDimensions.generalPadding,
                      top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: AppColors.starRating, size: 20,),
                      SizedBox(width: 3,),
                      Text(widget.lessonModel?.lessonRatings?.toString() ?? "0.0", style: Theme.of(context).textTheme.subtitle2,),
                    ],
                  ),
                ),
              ),
            ],),
          ],
        ),
        onTap: () {
          
          if(AppData.user.role != AppConstants.ROLE_ADMIN){
            SystemChrome.setEnabledSystemUIOverlays(
                [SystemUiOverlay.bottom, SystemUiOverlay.top]);
            SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
            Navigator.of(context)
                .push(MaterialPageRoute(
                builder: (context) => LessonDetailsScreen(id: widget.lessonModel.id, cookId: widget.lessonModel.creatorModel.id, isFromCook: false,)))
                .then((value) {
              SystemChrome.setEnabledSystemUIOverlays(
                  [SystemUiOverlay.bottom, SystemUiOverlay.top]);
              SystemChrome.setSystemUIOverlayStyle(
                  AppTheme.overlayStyleBottomTabBar);
            });
          }

        },
      ),
    );
  }
}