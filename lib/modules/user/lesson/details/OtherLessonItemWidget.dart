import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:flutter/material.dart';

class OtherLessonItemWidget extends StatefulWidget {

  final LessonDetailsModel lessonModel;
  final int index;

  OtherLessonItemWidget({this.lessonModel, this.index});

  @override
  State<StatefulWidget> createState() => OtherLessonItemWidgetState();
}

class OtherLessonItemWidgetState extends State<OtherLessonItemWidget> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cardWidth = (MediaQuery.of(context).size.width/2.5);
    var cardHeight = (MediaQuery.of(context).size.width/2.5) + 10;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        child: SizedBox(
          height: cardHeight,
          width: cardWidth,
          child: Card(
            elevation: 0,
            child: Stack(
              children: [
                Positioned.fill(child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: (widget.lessonModel?.lessonImages != null && (widget.lessonModel?.lessonImages?.isNotEmpty == true))
                      ? widget.lessonModel?.lessonImages?.first?.filePath : "",
                  placeholder: (context, _) => Image.asset("assets/loading_image.png"),
                  errorWidget: (context, string, _) => Image.asset("assets/error_image.png", color: AppColors.grayColor,),
                ),),
                Positioned.directional(
                    bottom: 0,
                    end: 0,
                    start:0,
                    textDirection: TextDirection.ltr,
                    child:  ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: AppDimensions.blur_radius, sigmaY: AppDimensions.blur_radius),
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.transparent.withOpacity(0.1)),
                          child: Padding(
                            padding: EdgeInsets.all(AppDimensions.padding_large),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text(widget.lessonModel.name.toUpperCase() ?? "",
                                  style: Theme.of(context).textTheme.headline6.apply(
                                      color: AppColors.white,),
                                ),
                                SizedBox(height: AppDimensions.padding_medium),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
              builder: (context) => LessonDetailsScreen(id: widget.lessonModel.id, cookId: widget.lessonModel.creatorModel.id, isFromCook: false,)));
        },
      ),
    );
  }
}
