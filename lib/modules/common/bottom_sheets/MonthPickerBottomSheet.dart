import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppDimensions.dart';

typedef MonthPickerCallBack(String selectedMonth);

class MonthPickerBottomSheet {

  static void monthPickerSheet(BuildContext context, String bottomSheetTitle, MonthPickerCallBack onPickMonth, {String selectedMonth}) {

    var pickerList = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    // = List<String>(maxYear-minYear+1, (i) => minYear+i);
    var initialIndex = selectedMonth != null ? pickerList.indexOf(selectedMonth) : ((DateTime.now().month)-1);
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
                child: MonthPickerWidget(bottomSheetTitle,onPickMonth, initialIndex, pickerList),
              ),
            ),
          );
        });
  }
}

class MonthPickerWidget extends StatelessWidget {

  final String bottomSheetTitle;
  final MonthPickerCallBack onPickDate;
  final List<String> pickerlist;
  final int initialIndex;
  String selectedMonth;
  MonthPickerWidget(this.bottomSheetTitle, this.onPickDate, this.initialIndex, this.pickerlist);

  @override
  Widget build(BuildContext context) {
    selectedMonth = pickerlist.last;
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
              selectedMonth = pickerlist[i];
            },
            itemExtent: 30.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top:AppDimensions.largeTopBottomPadding),
          child: RaisedButton(
            onPressed: () {
              onPickDate(selectedMonth);
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

