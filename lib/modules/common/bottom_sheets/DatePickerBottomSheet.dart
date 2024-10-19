
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppDimensions.dart';

DateTime selectedDate;

typedef PickDateCallBack(DateTime selectedDate);

class DatePickerBottomSheet {

  static void datePickerSheet(BuildContext context, String bottomSheetTitle, onPickDate, {DateTime minDate, DateTime maxDate, DateTime initialDate, }) {

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
                  child: DatePickerDialog(bottomSheetTitle,onPickDate, initialDate, maxDate, minDate),
              ),
            ),
          );
        });
  }
}

class DatePickerDialog extends StatefulWidget {

  final String bottomSheetTitle;
  final PickDateCallBack onPickDate;
  final DateTime initialDate;
  final DateTime maxDate;
  final DateTime minDate;

  DatePickerDialog(this.bottomSheetTitle, this.onPickDate, this. initialDate, this. maxDate, this.minDate);

  @override

  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {

  @override
  void initState() {
    selectedDate = widget.initialDate ?? DateTime.now();
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
            mode: CupertinoDatePickerMode.date,
            initialDateTime: widget.initialDate,
            maximumDate: widget.maxDate,
            minimumDate: widget.minDate,
            onDateTimeChanged:(DateTime newDate) {
              setState(() {
                selectedDate = newDate;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top:AppDimensions.largeTopBottomPadding),
          child: RaisedButton(
            onPressed: () {
              widget.onPickDate(selectedDate);
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

