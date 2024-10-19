import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/modules/common/widgets/CustomImageShapeWidget.dart';
import 'package:cooking_app/modules/dashboard/HomeNavigationsScreen.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:cooking_app/utils/CalculationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LessonItemWidget extends StatefulWidget {

  final LessonDetailsModel lessonModel;
  final int index;
  final ChangeWidget onChangeWidget;

  LessonItemWidget({this.lessonModel, this.index, this.onChangeWidget});

  @override
  State<StatefulWidget> createState() => LessonItemWidgetState();
}

class LessonItemWidgetState extends State<LessonItemWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        child: Row(
          children: [
            CustomImageShapeWidget(
              45,
              45,
              45 / 2,
              CachedNetworkImage(
                width: 45,
                height: 45,
                fit: BoxFit.fill,
                imageUrl: (widget.lessonModel?.lessonImages?.isNotEmpty == true) ? widget.lessonModel?.lessonImages?.first?.thumbnailPath : "",
                placeholder: (context, _) => Image.asset("assets/loading_image.png"),
                errorWidget:
                    (context, url, error) =>
                    Image.asset(
                      "assets/error_image.png",
                      fit: BoxFit.cover,
                      color: AppColors.grayColor,
                    ),
              ),
            ),
            SizedBox(
              width: AppDimensions.generalMinPadding,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(widget.lessonModel.name ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1,),
                      ),
                      SizedBox(width: 5,),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppColors.starRating, size: 20,),
                          SizedBox(width: 5,),
                          Text(double.parse(widget?.lessonModel?.lessonRatings?.toStringAsFixed(1))?.toString() ?? "0.0",
                            style: Theme.of(context).textTheme.bodyText2,),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget> [
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
                              ? CalculationUtils.calculateHours(widget.lessonModel.duration) : "0" + AppStrings.hour, style: Theme.of(context).textTheme.bodyText2,),
                          SizedBox(width: 10,),
                        ],
                      ),
                      /*Offstage(
                        offstage: false,//(widget.lessonModel.lessonRatings != null),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: AppColors.starRating, size: 20,),
                            SizedBox(width: 5,),
                            Text((widget.lessonModel.lessonRatings != null) ? (widget.lessonModel.lessonRatings).toString() : "4.2", style: Theme.of(context).textTheme.bodyText2,),
                          ],
                        ),
                      ),
                      SizedBox(width: AppDimensions.generalPadding,),
                      Offstage(
                        offstage: false,//(widget.lessonModel.duration != null),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_outlined, color: Theme.of(context).accentColor, size: 20,),
                            SizedBox(width: 5,),
                            Text((widget.lessonModel.duration != null) ? ((widget.lessonModel.duration)/60).toString() + AppStrings.hour : "2" + AppStrings.hour, style: Theme.of(context).textTheme.bodyText2,),
                          ],
                        ),
                      ),*/
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
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
        },
      ),
    );
  }
}
