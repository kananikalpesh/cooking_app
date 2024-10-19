
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CuisineMultiSelectBottomSheet{

  static Future<dynamic> showFiltersSheet(BuildContext context,
      Map<int, CommonTagItemModel> addedCuisinesMap, List<CommonTagItemModel> cuisines, {String btnText = AppStrings.apply}) {

    cuisines.forEach((element) {
      element.isSelected = addedCuisinesMap.containsKey(element.id);
    });
    var cuisinesMap = showModalBottomSheet(
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
                child: _BottomWidget(cuisines, btnText),
              ),),
          );
        });
    return cuisinesMap;
  }
}

class _BottomWidget extends StatefulWidget {
  final List<CommonTagItemModel> cuisines;
  final String btnText;

  _BottomWidget(this.cuisines, this.btnText);

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
                child: Text(AppStrings.cuisine, textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headline5.apply(fontSizeDelta: 4),),
              ),
            ),
            GestureDetector(child: Text(AppStrings.clear,
              style: Theme.of(context).textTheme.subtitle2.apply(fontWeightDelta: 2,
                  color: Theme.of(context).accentColor),), onTap: (){
              widget.cuisines.forEach((element) {element.isSelected = false;});
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
                    itemCount: widget.cuisines.length,
                    //shrinkWrap: true,
                    itemBuilder: (context, index) {
                      CommonTagItemModel cuisineModel = widget.cuisines[index];
                      return _CuisineItem(cuisineModel, (CommonTagItemModel clickedFilter){
                            widget.cuisines[index].isSelected = !widget.cuisines[index].isSelected;
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
      padding: const EdgeInsets.only(top: AppDimensions.generalPadding),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                var map = Map<int, CommonTagItemModel>();
                widget.cuisines.forEach((element) {
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

  final CommonTagItemModel _cuisineModel;
  final _UpdateSelectedListCallBack _onSelectedListUpdate;
  _CuisineItem(this._cuisineModel, this._onSelectedListUpdate);

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
      title: Text(widget._cuisineModel.name, style:Theme.of(context).textTheme.subtitle1.apply(fontSizeDelta: 1),
        maxLines: 1, overflow: TextOverflow.ellipsis,),
      trailing: Offstage(
        offstage: !(widget._cuisineModel?.isSelected == true),
        child: Icon(
            Icons.done, color: Theme.of(context).accentColor),
      ),
      onTap: (){
        widget._onSelectedListUpdate(widget._cuisineModel);
      },
    );
  }

}