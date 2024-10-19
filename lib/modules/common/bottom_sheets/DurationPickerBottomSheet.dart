
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:provider/provider.dart';

typedef PickDurationCallBack(int hours, int minutes);

class DurationPickerBottomSheet {

  static void durationPickerSheet(BuildContext context, String bottomSheetTitle, onPickDuration, {int initialTimeInMinutes,}) {

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
                child: DurationPickerDialog(bottomSheetTitle, onPickDuration, initialTimeInMinutes),
              ),
            ),
          );
        });
  }
}

class DurationPickerDialog extends StatefulWidget {

  final String bottomSheetTitle;
  final PickDurationCallBack onPickDate;
  final int initialTimeInMinutes;

  DurationPickerDialog(this.bottomSheetTitle, this.onPickDate, this.initialTimeInMinutes);

  @override

  _DurationPickerDialogState createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {

  int selectedHour = 0;
  int selectedMinute = 0;
  ValueNotifier<String> error = ValueNotifier("");

  @override
  void initState() {
    if(widget.initialTimeInMinutes != null){
      selectedHour = (widget.initialTimeInMinutes/60).floor();
      double hoursDecimal = (widget.initialTimeInMinutes/60) - selectedHour;
      selectedMinute = (hoursDecimal * 60).floor();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(widget.bottomSheetTitle,
          style: Theme.of(context).textTheme.headline6.apply(color: AppColors.colorAccent),
        ),
        SizedBox(height: AppDimensions.largeTopBottomPadding,),
        SizedBox(
          height: 150,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(AppStrings.hourLabel, style: Theme.of(context).textTheme.subtitle1,),
                  SizedBox(height: 6),
                  Expanded(
                    child: CupertinoPicker.builder(
                      childCount: 13,
                      onSelectedItemChanged: (int index) {
                        selectedHour = (index);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Text("${index}");
                      }, itemExtent: 32.0,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: SizedBox(width: 20, child: Center(child: Text(":")),),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(AppStrings.minuteLabel, style: Theme.of(context).textTheme.subtitle1),
                  SizedBox(height: 6),
                  Expanded(
                    child: CupertinoPicker.builder(
                      childCount: 2,
                      onSelectedItemChanged: (int index) {
                        selectedMinute = ((index == 0) ? 00 : 30);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Text("${(index == 0) ? 00 : 30}");
                      }, itemExtent: 32.0,
                    ),
                  ),
                ],
              ),
            )
          ],),
        ),

          ValueListenableProvider<String>.value(value: error,
          child: Consumer<String>(builder: (context, errorMessage, child){
            return (errorMessage.isEmpty) ? Container() :
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 8, right: 8),
              child: Text(errorMessage, style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.errorTextColor),),
            );
          }),),

        Padding(
          padding: const EdgeInsets.only(top:AppDimensions.generalPadding),
          child: RaisedButton(
            onPressed: () {
              if(selectedHour == 0 && selectedMinute == 0){
                error.value = AppStrings.selectedProperHourAndMinute;
                return;
              }
              error.value = "";
              widget.onPickDate(selectedHour, selectedMinute);
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

