
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppDimensions.dart';

DateTime selectedTime;

typedef PickTimeCallBack(DateTime selectedTime);

class TimePickerBottomSheet {

  static void timePickerSheet(BuildContext context, String bottomSheetTitle, onPickDate, {DateTime initialTime,}) {

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
                  child: TimePickerDialog(bottomSheetTitle, onPickDate, initialTime),
              ),
            ),
          );
        });
  }
}

class TimePickerDialog extends StatefulWidget {

  final String bottomSheetTitle;
  final PickTimeCallBack onPickDate;
  final DateTime initialTime;

  TimePickerDialog(this.bottomSheetTitle, this.onPickDate, this. initialTime);

  @override

  _TimePickerDialogState createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {

  @override
  void initState() {
    selectedTime = widget.initialTime ?? DateTime.now();
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
          height: 120,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime: widget.initialTime,
            //maximumDate: widget.maxDate,
            //minimumDate: widget.minDate,
            onDateTimeChanged:(DateTime newDate) {
              setState(() {
                selectedTime = newDate;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top:AppDimensions.largeTopBottomPadding),
          child: RaisedButton(
            onPressed: () {
              widget.onPickDate(selectedTime);
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

