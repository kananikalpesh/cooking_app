
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppDimensions.dart';

typedef YearPickerCallBack(int selectedYear);

class YearPickerBottomSheet {

  static void yearPickerSheet(BuildContext context, String bottomSheetTitle,YearPickerCallBack onPickYear, {int minYear, int maxYear, int selectedYear}) {
    if(minYear == null || maxYear == null) {
      minYear = DateTime.now().year - 100;
      maxYear = DateTime.now().year;
    }
    var pickerList = List<int>.generate(maxYear-minYear+1, (i) => minYear+i);
    var initialIndex = selectedYear != null ? pickerList.indexOf(selectedYear) : pickerList.length-1;
    showModalBottomSheet(
        context: context,
        enableDrag: true,
        isDismissible: true,
        isScrollControlled: true,
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
                  padding: const EdgeInsets.only(left: AppDimensions.maxPadding,
                      right: AppDimensions.maxPadding,
                      top: AppDimensions.generalPadding,
                      bottom: AppDimensions.generalTopPadding,),
                  child: YearPickerWidget(bottomSheetTitle,onPickYear, initialIndex, pickerList),
              ),
            ),
          );
        });
  }
}

class YearPickerWidget extends StatelessWidget {

  final String bottomSheetTitle;
  final YearPickerCallBack onPickDate;
  final List<int> pickerlist;
  final int initialIndex;
  int selectedYear;
  YearPickerWidget(this.bottomSheetTitle, this.onPickDate, this.initialIndex, this.pickerlist);

  @override
  Widget build(BuildContext context) {
    selectedYear ??= pickerlist[initialIndex];
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(bottomSheetTitle,
          style: Theme.of(context).textTheme.headline6.apply(color: Theme.of(context).accentColor),
          ),
        SizedBox(height: AppDimensions.largeTopBottomPadding,),
        SizedBox(
          height: 120,
          child: CupertinoPicker(
            children:  pickerlist.map((e) => Text("$e")).toList(growable: false),
            scrollController: FixedExtentScrollController(initialItem: initialIndex ),
            onSelectedItemChanged: (i){
              selectedYear = pickerlist[i];
            },
            itemExtent: 30.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top:AppDimensions.largeTopBottomPadding),
          child: RaisedButton(
            onPressed: () {
              onPickDate(selectedYear);
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  left: AppDimensions.maxPadding,
                  right: AppDimensions.maxPadding,
                  top: AppDimensions.generalPadding,
                  bottom: AppDimensions.generalPadding),
              child: Text(AppStrings.doneLabel),
            ),
          ),
        ),
        SizedBox(height:  max<double>(MediaQuery.of(context).padding.bottom, AppDimensions.padding_large)),
      ],
    );
  }
}

