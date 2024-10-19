import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/modules/common/widgets/CustomImageShapeWidget.dart';
import 'package:cooking_app/modules/cook/profile/other_user/other_cook_reviews/ReviewListModel.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDateUtils.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:flutter/material.dart';

class OtherCookReviewItemWidget extends StatefulWidget {

  final ReviewModel reviewModel;
  final int index;
  OtherCookReviewItemWidget({this.reviewModel, this.index});

  @override
  State<StatefulWidget> createState() => OtherCookReviewItemWidgetState();
}

class OtherCookReviewItemWidgetState extends State<OtherCookReviewItemWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomImageShapeWidget(
                  50,
                  50,
                  50 / 2,
                  CachedNetworkImage(
                    key: GlobalKey(),
                    width: 50,
                    height: 50,
                    fit: BoxFit.fill,
                    imageUrl: (widget.reviewModel?.reviewerModel?.userImageThumbnail != null) ? widget.reviewModel?.reviewerModel?.userImageThumbnail : "",
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
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.reviewModel?.reviewerModel?.firstName ?? "",
                        style: Theme.of(context).textTheme.subtitle1,),
                      SizedBox(height: 3,),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey300,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: AppDimensions.generalPadding,
                              top: 5, bottom: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: AppColors.starRating, size: 15,),
                              SizedBox(width: 3,),
                              Text(widget.reviewModel?.rating?.toString() ?? "0.0",
                                style: Theme.of(context).textTheme.bodyText2,),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5,),
                Text(AppDateUtils.dateOnlyFormatToString(widget.reviewModel?.reviewDate),
                  style: Theme.of(context).textTheme.overline.apply(color: AppColors.grayColor, fontSizeDelta: 2),),
              ],
            ),
            SizedBox(height: 10,),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 58),
          child: Text(widget.reviewModel?.comment ?? "",
            style: Theme.of(context).textTheme.bodyText2.apply(fontWeightDelta: 1),),
        ),
      ),
    );
  }
}