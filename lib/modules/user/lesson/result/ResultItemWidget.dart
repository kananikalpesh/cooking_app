import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/modules/common/widgets/CustomImageShapeWidget.dart';
import 'package:cooking_app/modules/cook/profile/other_user/OtherCookProfileScreen.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:cooking_app/utils/CalculationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ResultItemWidget extends StatefulWidget {

  final LessonDetailsModel lessonModel;
  final int index;
  final bool isFromHomeScreen;

  ResultItemWidget({this.lessonModel, this.index, this.isFromHomeScreen});

  @override
  State<StatefulWidget> createState() => ResultItemWidgetState();
}

class ResultItemWidgetState extends State<ResultItemWidget> {

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
                  //imageUrl: widget.lessonModel.imagePath,
                  imageUrl: (widget.lessonModel?.lessonImages != null && widget.lessonModel?.lessonImages?.isNotEmpty == true)
                      ? widget.lessonModel?.lessonImages?.first?.filePath : "",
                  placeholder: (context, _) => Image.asset("assets/loading_image.png"),
                  errorWidget: (context, string, _) => Image.asset("assets/error_image.png", color: AppColors.grayColor,),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: AppDimensions.generalMinPadding, right: AppDimensions.generalMinPadding),
              child: Row(
                children: [
                  Expanded(child: Text(widget.lessonModel.name, style: Theme.of(context).textTheme.headline5,)),
                  SizedBox(width: 5,),
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
                          Text(double.parse(widget?.lessonModel?.lessonRatings?.toStringAsFixed(1)).toString() ?? "0.0", style: Theme.of(context).textTheme.subtitle2,),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: AppDimensions.generalMinPadding, right: AppDimensions.generalMinPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  SizedBox(height: 2),
                  Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: GestureDetector(
                        onTap: (){
                          if (widget.isFromHomeScreen) {
                            SystemChrome.setEnabledSystemUIOverlays(
                                [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                            SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                builder: (context) => OtherCookProfileScreen(cookId: widget.lessonModel.creatorModel.id,)))
                                .then((value) {
                              SystemChrome.setEnabledSystemUIOverlays(
                                  [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                              SystemChrome.setSystemUIOverlayStyle(
                                  AppTheme.overlayStyleBottomTabBar);
                            });
                          } else {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                builder: (context) => OtherCookProfileScreen(cookId: widget.lessonModel.creatorModel.id,)));
                          }
                        },
                        child: RichText(
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                  alignment: ui.PlaceholderAlignment.middle,
                                  child: CustomImageShapeWidget(
                                40,
                                40,
                                40 / 2,
                                CachedNetworkImage(
                                  key: GlobalKey(),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.fill,
                                  //imageUrl: widget.lessonModel.userImage,
                                  imageUrl: (widget.lessonModel?.creatorModel?.userImage != null) ? widget.lessonModel?.creatorModel?.userImage : "",
                                  progressIndicatorBuilder: (context,
                                      url, downloadProgress) =>
                                      Image.asset(
                                        "assets/loading_image.png",
                                        fit: BoxFit.cover,
                                      ),
                                  errorWidget:
                                      (context, url, error) =>
                                      Image.asset(
                                        "assets/profile_user_default_icon.png",
                                        fit: BoxFit.cover,
                                      ),
                                ),
                              )),
                              WidgetSpan(child: SizedBox(width: 6)),
                              TextSpan(text: widget?.lessonModel?.creatorModel?.firstName ?? "",
                                  style: Theme.of(context).textTheme.subtitle1),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
        onTap: () {
          if (widget.isFromHomeScreen){
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
          } else {
            Navigator.of(context)
                .push(MaterialPageRoute(
                builder: (context) => LessonDetailsScreen(id: widget.lessonModel.id, cookId: widget.lessonModel.creatorModel.id, isFromCook: false,)));
          }
        },
      ),
    );
  }
}
