
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/admin/analytics/AnalyticsBloc.dart';
import 'package:cooking_app/modules/admin/analytics/AnalyticsModel.dart';
import 'package:cooking_app/modules/admin/analytics/TopCookItemWidget.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';


class AnalyticsScreen extends StatefulWidget {

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  AnalyticsBloc _bloc;
  AnalyticsModel analyticsModel;
  double cardHeight;

  @override
  void initState() {
    _bloc = AnalyticsBloc();
    _bloc.obsGetAnalytics.stream.listen((result) {
      if (result.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context,result);
      }
    });
    _bloc.event.add(EventModel(AnalyticsBloc.GET_ANALYTICS_EVENT));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    cardHeight = (MediaQuery.of(context).size.height - 58) / 6;

    return StreamBuilder<ResultModel<AnalyticsModel>>(
      stream: _bloc.obsGetAnalytics.stream,
      builder: (context, AsyncSnapshot<ResultModel<AnalyticsModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data?.data != null){
            analyticsModel = snapshot.data?.data;
            return SingleChildScrollView(
              child: mainContainerWidget(),
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.generalPadding),
                child: Text(snapshot.data?.error,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.generalPadding),
              child: Text(snapshot.error,
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget mainContainerWidget(){
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 50,),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.adminCardBgColor,
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grayColor.withOpacity(.5),
                              blurRadius: 4.0, // soften the shadow
                              spreadRadius: 0.0, //extend the shadow
                              offset: Offset(
                                5.0, // Move to right 10  horizontally
                                8.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),
                        height: cardHeight,
                        //MediaQuery.of(context).size.height / 5.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Text(analyticsModel?.totalCooks ?? "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                        textAlign: TextAlign.center, textScaleFactor: 1.0, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: AppDimensions.generalPadding, right: AppDimensions.generalPadding),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 2, color: Theme.of(context).buttonColor),
                            color: Theme.of(context).buttonColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(AppStrings.cooks,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5.apply(color: AppColors.white),
                                textAlign: TextAlign.center, textScaleFactor: 1.0, maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: AppDimensions.generalPadding,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 50,),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.adminCardBgColor,
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grayColor.withOpacity(.5),
                              blurRadius: 4.0, // soften the shadow
                              spreadRadius: 0.0, //extend the shadow
                              offset: Offset(
                                5.0, // Move to right 10  horizontally
                                8.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),
                        height: cardHeight,
                        //MediaQuery.of(context).size.height / 5.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Text(analyticsModel?.totalUsers ?? "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                        textAlign: TextAlign.center, textScaleFactor: 1.0, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: AppDimensions.generalPadding, right: AppDimensions.generalPadding),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 2, color: Theme.of(context).buttonColor),
                            color: Theme.of(context).buttonColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(AppStrings.users,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5.apply(color: AppColors.white),
                                textAlign: TextAlign.center, textScaleFactor: 1.0, maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 50,),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.adminCardBgColor,
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grayColor.withOpacity(.5),
                              blurRadius: 4.0, // soften the shadow
                              spreadRadius: 0.0, //extend the shadow
                              offset: Offset(
                                5.0, // Move to right 10  horizontally
                                8.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),
                        height: cardHeight,
                        //MediaQuery.of(context).size.height / 5.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Text("\$${analyticsModel?.totalBookingAmount ?? ""}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                        textAlign: TextAlign.center, textScaleFactor: 1.0, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: AppDimensions.generalPadding, right: AppDimensions.generalPadding),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 2, color: Theme.of(context).buttonColor),
                            color: Theme.of(context).buttonColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(AppStrings.bookingAmount,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5.apply(color: AppColors.white),
                                textAlign: TextAlign.center, textScaleFactor: 1.0, maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: AppDimensions.generalPadding,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 50,),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.adminCardBgColor,
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grayColor.withOpacity(.5),
                              blurRadius: 4.0, // soften the shadow
                              spreadRadius: 0.0, //extend the shadow
                              offset: Offset(
                                5.0, // Move to right 10  horizontally
                                8.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),
                        height: cardHeight,
                        //MediaQuery.of(context).size.height / 5.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Text("\$${analyticsModel?.totalTransFee ?? ""}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                        textAlign: TextAlign.center, textScaleFactor: 1.0, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: AppDimensions.generalPadding, right: AppDimensions.generalPadding),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 2, color: Theme.of(context).buttonColor),
                            color: Theme.of(context).buttonColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(AppStrings.transFee,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5.apply(color: AppColors.white),
                                textAlign: TextAlign.center, textScaleFactor: 1.0, maxLines: 2, overflow: TextOverflow.ellipsis,
                              ), /*Text(AppStrings.transFee,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5.apply(color: AppColors.white),
                                textAlign: TextAlign.center,
                              ),*/
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Offstage(
            offstage: ((analyticsModel?.topCooks?.length ?? 0) == 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.topCooks,
                  style: Theme.of(context).textTheme.headline4.apply(color: Theme.of(context).accentColor),),
                ListView.builder(
                  padding: EdgeInsets.only(top: 0,),
                  shrinkWrap: true,
                  primary: false,
                  itemCount: analyticsModel?.topCooks?.length ?? 0,
                  itemBuilder: (context, index) {
                    return TopCookItemWidget(analyticsModel.topCooks[index]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
