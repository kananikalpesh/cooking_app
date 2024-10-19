
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';

class GeneralFilterBottomSheet{

  static Future<dynamic> showFiltersSheet(BuildContext context, int selectedFilter) {
    var filter= showModalBottomSheet(
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
                child: _BottomWidget(selectedFilter),
              ),),
          );
        });
    return filter;
  }
}

class _BottomWidget extends StatefulWidget {
  final int selectedFilter;

  _BottomWidget(this.selectedFilter);

  @override
  _BottomWidgetState createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<_BottomWidget> {

  int _selectedIndex;
  List<String> filtersList;

  @override
  void initState() {
    filtersList = [AppStrings.priceLowest, AppStrings.priceHighest, AppStrings.ratingsHighest, AppStrings.ratingsLowest];
    _selectedIndex = widget.selectedFilter;

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
                child: Text(AppStrings.sortBy, textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.headline5.apply(fontSizeDelta: 4),),
              ),
            ),
            GestureDetector(child: Text(AppStrings.clear,
              style: Theme.of(context).textTheme.subtitle2.apply(fontWeightDelta: 2,
                  color: Theme.of(context).accentColor),), onTap: (){
              setState(() {});
              _selectedIndex = -1;
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
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: AppDimensions.generalPadding, right: AppDimensions.generalMinPadding),
                    itemCount: filtersList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          title: Text(filtersList[index],
                            style:Theme.of(context).textTheme.subtitle1.apply(fontSizeDelta: 1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,),
                        selected: index == _selectedIndex,
                          trailing: Offstage(
                            offstage: index != _selectedIndex,
                            child: Icon(
                                Icons.done, color: Theme.of(context).accentColor),
                          ),
                        onTap: (){
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
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
                Navigator.of(context).pop(_selectedIndex);
              },
              child: Text(AppStrings.apply),
            ),
          ),
        ],
      ),
    );
  }
}