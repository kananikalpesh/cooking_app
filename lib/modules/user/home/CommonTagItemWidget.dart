import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/modules/dashboard/HomeNavigationsScreen.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/modules/user/lesson/ScreenOpenedFrom.dart';
import 'package:cooking_app/modules/user/lesson/result/SearchResultScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:flutter/material.dart';

class CommonTagItemWidget extends StatefulWidget {

  final CommonTagItemModel cuisineModel;
  final int index;
  final List<CommonTagItemModel> cuisines;
  final List<CommonTagItemModel> diets;
  final CommonTagItemModel selectedCuisine;
  final Map<int, CommonTagItemModel> selectedDietsMap;
  final bool isCuisine;
  final ChangeWidget onChangeWidget;

  CommonTagItemWidget({this.cuisineModel, this.index, this.cuisines, this.diets, this.selectedCuisine,
    this.selectedDietsMap, this.isCuisine, this.onChangeWidget});

  @override
  State<StatefulWidget> createState() => CommonTagItemWidgetState();
}

class CommonTagItemWidgetState extends State<CommonTagItemWidget> {
  
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
                  imageUrl: widget.cuisineModel.imagePath,
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
                                Text(widget.cuisineModel.name ?? "", //.toUpperCase()
                                  style: Theme.of(context).textTheme.headline6.apply(
                                      color: AppColors.white, ), textScaleFactor: 1.0, //fontSizeDelta: -1,
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
          if(widget.isCuisine) {
            widget.onChangeWidget(SearchResultScreen(cuisines: widget.cuisines, diets: widget.diets, searchQuery: "",
              openedFrom: ScreenOpenedFrom.HOME.index, selectedCuisine: widget.cuisineModel,
              onChangeWidget: widget.onChangeWidget,));
          } else {
            widget.cuisineModel.isSelected = true;
            widget.selectedDietsMap
                .putIfAbsent(widget.cuisineModel.id, () => widget.cuisineModel);
            widget.onChangeWidget(SearchResultScreen(cuisines: widget.cuisines, diets: widget.diets, searchQuery: "",
              openedFrom: ScreenOpenedFrom.HOME.index, selectedDietsMap: widget.selectedDietsMap,
              onChangeWidget: widget.onChangeWidget,));
          }
        },
      ),
    );
  }
}
