
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef CuisineFilterCallBack(bool callAPI);

class CuisineFilterBottomSheet{

  static Future<dynamic> showFiltersSheet(BuildContext context, CommonTagItemModel addedCuisine, List<CommonTagItemModel> cuisines,
  {CuisineFilterCallBack callback, String btnText = AppStrings.apply}) {
    var cuisine= showModalBottomSheet(
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
                child: _BottomWidget( addedCuisine, cuisines, btnText, callback),
              ),),
          );
        });
    return cuisine;
  }
}

class _BottomWidget extends StatefulWidget {
  final CommonTagItemModel addedCuisine;
  final List<CommonTagItemModel> cuisines;
  final String btnText;
  final CuisineFilterCallBack callback;

  _BottomWidget(this.addedCuisine, this.cuisines, this.btnText, this.callback);

  @override
  _BottomWidgetState createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<_BottomWidget> {

  ValueNotifier<String> _errorMessage = ValueNotifier("");
  CommonTagItemModel _selectedCuisine;

  @override
  void initState() {
    _selectedCuisine = widget.addedCuisine;

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
              setState(() {});
              _selectedCuisine = null;
              if (widget.callback != null) widget.callback(false);
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
                    padding: EdgeInsets.only(top: AppDimensions.generalPadding, right: AppDimensions.generalMinPadding),
                    itemCount: widget.cuisines.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          title: Text(widget.cuisines[index].name,
                            style:Theme.of(context).textTheme.subtitle1.apply(fontSizeDelta: 1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,),
                        selected: _selectedCuisine?.id == widget.cuisines[index].id,
                          trailing: Offstage(
                            offstage: _selectedCuisine?.id != widget.cuisines[index].id,
                            child: Icon(
                                Icons.done, color: Theme.of(context).accentColor),
                          ),
                        onTap: (){
                          setState(() {
                            _selectedCuisine = _selectedCuisine?.id == widget.cuisines[index].id ? null : widget.cuisines[index];
                          });
                        },
                      );
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
                if (widget.callback != null) widget.callback(true);
                Navigator.of(context).pop(_selectedCuisine);
              },
              child: Text(widget.btnText),
            ),
          ),
        ],
      ),
    );
  }
}