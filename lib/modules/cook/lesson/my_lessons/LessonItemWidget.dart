import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/common/widgets/CustomImageShapeWidget.dart';
import 'package:cooking_app/modules/cook/lesson/create_lesson/CreateLessonScreen.dart';
import 'package:cooking_app/modules/cook/lesson/my_lessons/MyLessonsBloc.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:cooking_app/utils/CalculationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

typedef LessonUpdateCallBack(bool updated);

class LessonItemWidget extends StatefulWidget {

  final LessonDetailsModel lessonModel;
  final int index;
  final bool isFromHomeScreen;
  final MyLessonsBloc myLessonsBloc;
  final LessonUpdateCallBack onLessonUpdate;
  LessonItemWidget({this.lessonModel, this.index, this.isFromHomeScreen, this.myLessonsBloc, this.onLessonUpdate});

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
                        Expanded(
                          child: Offstage(offstage: true,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  CustomImageShapeWidget(
                                    40,
                                    40,
                                    40 / 2,
                                    CachedNetworkImage(
                                      key: GlobalKey(),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.fill,
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
                                  ),
                                  SizedBox(
                                    width: AppDimensions.generalMinPadding,
                                  ),
                                  Expanded(
                                    child: Text(widget?.lessonModel?.creatorModel?.firstName ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1,),
                                  ),
                                  SizedBox(
                                    height: AppDimensions.generalPadding,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            width: 2, color: Theme.of(context).accentColor),
                        color: Theme.of(context).accentColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Center(
                          child: Icon(Icons.edit, color: AppColors.white, size: 16,),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    if(widget.index == widget.myLessonsBloc.indexProcessingLesson.value){
                      return;
                    }
                    SystemChrome.setEnabledSystemUIOverlays(
                        [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                    SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                        builder: (context) => CreateLessonScreen(lessonDetailsModel: widget.lessonModel,)))
                        .then((value) {
                      SystemChrome.setEnabledSystemUIOverlays(
                          [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                      SystemChrome.setSystemUIOverlayStyle(
                          AppTheme.overlayStyleBottomTabBar);
                      widget.onLessonUpdate(value ?? false);
                    });
                  },
                ),
              ),

              ValueListenableProvider<int>.value(value: widget.myLessonsBloc.indexProcessingLesson,
              child: Consumer<int>(builder: (context, value, child){
                if(value == widget.index){
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircularProgressIndicator(),
                  );
                }else{
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                width: 2, color: Theme.of(context).accentColor),
                            color: Theme.of(context).accentColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Center(
                              child: Icon(Icons.delete, color: AppColors.white, size: 16,),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        if(widget.index == widget.myLessonsBloc.indexProcessingLesson.value){
                          return;
                        }
                        CommonBottomSheet.showConfirmationBottomSheet(context,
                            AppStrings.deleteLesson,
                            AppStrings.wantToDeleteLesson,
                            AppStrings.yes,
                            AppStrings.no,
                                (){
                                Navigator.pop(context);
                              widget.myLessonsBloc.indexProcessingLesson.value = widget.index;
                              widget.myLessonsBloc.event.add(EventModel(MyLessonsBloc.DELETE_MY_LESSONS, data: widget.lessonModel.id));
                            });
                      },
                    ),
                  );
                }
              }),),
            ],),

          ],
        ),
        onTap: () {
            SystemChrome.setEnabledSystemUIOverlays(
                [SystemUiOverlay.bottom, SystemUiOverlay.top]);
            SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
            Navigator.of(context)
                .push(MaterialPageRoute(
                builder: (context) => LessonDetailsScreen(id: widget.lessonModel.id, cookId: widget.lessonModel.creatorModel.id, isFromCook: true,)))
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