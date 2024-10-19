
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DietaryFilterBottomSheet{

  static Future<dynamic> showFiltersSheet(BuildContext context,
      Map<int, CommonTagItemModel> addedDietsMap, List<CommonTagItemModel> diets, {String btnText= AppStrings.apply}) {

    diets.forEach((element) {
        element.isSelected = addedDietsMap.containsKey(element.id);
    });
    var dietsMap = showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.generalBottomSheetRadius),
              topRight: Radius.circular(AppDimensions.generalBottomSheetRadius),
            ),
            child: Container(
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: AppDimensions.generalMinPadding, right: AppDimensions.generalPadding, top: 20, bottom: 20),
              child: _BottomWidget(diets, btnText),
            ),),
          );
        });
    return dietsMap;
  }
}

class _BottomWidget extends StatefulWidget {
  final List<CommonTagItemModel> diets;
  final String btnText;

  _BottomWidget(this.diets, this.btnText);

  @override
  _BottomWidgetState createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<_BottomWidget> {

  ValueNotifier<String> _errorMessage = ValueNotifier("");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: AppDimensions.generalPadding),
                child: Text(AppStrings.dietary, textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headline5.apply(fontSizeDelta: 4),),
              ),
            ),
            GestureDetector(child: Text(AppStrings.clear,
              style: Theme.of(context).textTheme.subtitle2.apply(fontWeightDelta: 2,
                  color: Theme.of(context).accentColor),), onTap: (){
              widget.diets.forEach((element) {element.isSelected = false;});
              setState(() {});
            },)
          ],
        ),
        SizedBox(height: AppDimensions.generalPadding,),
        Container(height: 0.5, color: Theme.of(context).dividerColor,),
        Expanded(
          child: Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              //mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: AppDimensions.generalPadding,
                        right: AppDimensions.generalMinPadding),
                    itemCount: widget.diets.length,
                    //shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return _CuisineItem(widget.diets[index], (CommonTagItemModel clickedFilter){
                                widget.diets[index].isSelected = !widget.diets[index].isSelected;
                                setState(() {});
                          });
                    },
                  ),
                ),
                ValueListenableProvider<String>.value(
                  value: _errorMessage,
                  child: Consumer<String>(
                    builder: (context, value, child) {
                      return Offstage(
                        offstage: ((value?.isEmpty ?? true)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: AppDimensions.generalPadding,
                            right: AppDimensions.generalPadding,
                            top: AppDimensions.generalPadding,
                          ),
                          child: Text(
                            "$value",
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyText1.apply(
                                fontStyle: FontStyle.italic,
                                color: AppColors.errorTextColor),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _getButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _getButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.generalPadding, left: AppDimensions.generalPadding),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                var map = Map<int, CommonTagItemModel>();
                widget.diets.forEach((element) {
                  if(element.isSelected){
                    map[element.id] = element;
                  }
                });
                Navigator.of(context).pop(map);
              },
              child: Text(widget.btnText),
            ),
          ),
        ],
      ),
    );
  }
  
}

typedef _UpdateSelectedListCallBack(CommonTagItemModel model);

class _CuisineItem extends StatefulWidget{

  final CommonTagItemModel _dietModel;
  final _UpdateSelectedListCallBack _onSelectedListUpdate;
  _CuisineItem(this._dietModel, this._onSelectedListUpdate);

  @override
  _CuisineItemState createState() => _CuisineItemState();
}

class _CuisineItemState extends State<_CuisineItem>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CachedNetworkImage(
            width: AppDimensions.generalIconSize,
            height: AppDimensions.generalIconSize,
            fit: BoxFit.fill,
            imageUrl: (widget._dietModel.iconsPath?.greenColor ?? ""),
            color: Theme.of(context).accentColor,
            progressIndicatorBuilder:
                (context, url, downloadProgress) =>
                Image.asset(
                  "assets/loading_image.png",
                  fit: BoxFit.cover,
                ),
            errorWidget: (context, url, error) => ClipRRect(
              borderRadius:
              BorderRadius.all(Radius.circular((AppDimensions.generalIconSize/2),),),
              child: Image.asset(
                "assets/dashboard_diet.png",
                fit: BoxFit.cover,
                color: Theme.of(context).accentColor,
              ),),),
          SizedBox(width: 8,),
          Text(widget._dietModel.name, style:Theme.of(context).textTheme.subtitle1.apply(fontSizeDelta: 1),
            maxLines: 1, overflow: TextOverflow.ellipsis,),
        ],
      ),
      trailing: Offstage(
        offstage: !(widget._dietModel?.isSelected == true),
        child: Icon(
          Icons.done, color: Theme.of(context).accentColor),
      ),
      onTap: (){
            // setState(() {
              widget._onSelectedListUpdate(widget._dietModel);
            // });
      },
    );
  }

}