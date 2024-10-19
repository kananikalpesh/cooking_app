
import 'package:cooking_app/modules/admin/analytics/AnalyticsModel.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';

class TopCookItemWidget extends StatefulWidget {
  final TopCookModel cookModel;
  TopCookItemWidget(this.cookModel);

  @override
  State<StatefulWidget> createState() => TopCookItemWidgetState();
}

class TopCookItemWidgetState extends State<TopCookItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(margin: EdgeInsets.only(top: AppDimensions.generalPadding),
      child: Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(widget.cookModel?.name ?? "-", style: Theme.of(context).textTheme.headline5,)),
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
                      Text(double.parse(widget?.cookModel?.rating?.toStringAsFixed(1)).toString() ?? "0.0", style: Theme.of(context).textTheme.subtitle2,),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding:
            const EdgeInsets.only(top: AppDimensions.generalMinPadding),
            child: Text(widget.cookModel?.email ?? "-",
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text((widget.cookModel?.totalLessons != null) ? "${AppStrings.totalLessons}${widget.cookModel.totalLessons}" : "-",
              style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding),
            child: Text((widget.cookModel?.totalBookings != null) ? "${AppStrings.totalBookings}${widget.cookModel.totalBookings}" : "-",
              style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding),
            child: Text((widget.cookModel?.totalAmount != null) ? "${AppStrings.totalAmount}${widget.cookModel.totalAmount}" : "-",
              style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding),
            child: Text((widget.cookModel?.totalTransFee != null) ? "${AppStrings.totalTransAmount}${widget.cookModel.totalTransFee.toStringAsFixed(2)}" : "-",
              style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -2),
            ),
          ),
        ],
      ),
    ),);
  }
}
