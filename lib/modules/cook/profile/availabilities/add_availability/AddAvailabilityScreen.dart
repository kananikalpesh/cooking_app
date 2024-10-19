
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/cook/profile/CookAvailabilityModel.dart';
import 'package:cooking_app/modules/cook/profile/availabilities/DaysEnum.dart';
import 'package:cooking_app/modules/cook/profile/availabilities/ManageAvailabilityBloc.dart';
import 'package:cooking_app/modules/cook/profile/availabilities/add_availability/AddAvailabilityBloc.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDateUtils.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddAvailabilityScreen extends StatefulWidget {
  final ManageAvailabilityBloc manageBloc;
  final CookAvailabilityModel availabilityModel;
  
  AddAvailabilityScreen(this.manageBloc, {this.availabilityModel});

  @override
  _AddAvailabilityState createState() => _AddAvailabilityState();
}

class _AddAvailabilityState extends State<AddAvailabilityScreen> {

  AddAvailabilityBloc _bloc;

  int _selectedDayIndex;
  DateTime currentDateTime;
  DateTime selectedStartTime;
  DateTime selectedEndTime;
  ValueNotifier<String> _commonError = ValueNotifier("");

  @override
  void initState() {
    _bloc = AddAvailabilityBloc();

    _selectedDayIndex = (widget.availabilityModel != null) ? widget.availabilityModel.dayIndex : -100;
    currentDateTime = DateTime.now();
    selectedStartTime = (widget.availabilityModel != null)
        ? widget.availabilityModel.startDateTime.toLocal() : currentDateTime;
    selectedEndTime = (widget.availabilityModel != null)
        ? widget.availabilityModel.endDateTime.toLocal() : currentDateTime;

    _bloc.obsAddAvailability.stream.listen((result) {
      if (result.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context, result);
      } else {
        widget.manageBloc.event.add(EventModel(ManageAvailabilityBloc.GET_PROFILE_EVENT, data: AppData.user.id));
        CommonBottomSheet.showSuccessWithTimerBottomSheet(context,
            (widget.availabilityModel != null) ? AppStrings.availabilityUpdatedTitle : AppStrings.availabilityAddedTitle,
            (widget.availabilityModel != null) ? AppStrings.availabilityUpdatedDesc : AppStrings.availabilityAddedDesc).then((value){
          Navigator.pop(context);
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text((widget.availabilityModel != null) ? AppStrings.updateAvailability : AppStrings.addAvailability),),
      body: Padding(
        padding: const EdgeInsets.only(top: AppDimensions.maxPadding, left: AppDimensions.generalPadding,
            bottom: AppDimensions.maxPadding, right: AppDimensions.generalPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.selectDay,
                style: Theme.of(context).textTheme.headline5.apply(
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 10,),
              Wrap(children: daysChipList(),),
              SizedBox(height: AppDimensions.maxPadding,),
              Text(AppStrings.selectStartTime,
                style: Theme.of(context).textTheme.headline5.apply(
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 10,),
              SizedBox(
                height: 120,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selectedStartTime.toLocal(),
                  onDateTimeChanged:(DateTime newDate) {
                    setState(() {
                      selectedStartTime = newDate;
                    });
                  },
                ),
              ),
              SizedBox(height: AppDimensions.maxPadding,),
              Text(AppStrings.selectEndTime,
                style: Theme.of(context).textTheme.headline5.apply(
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(height: 10,),
              SizedBox(
                height: 120,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selectedEndTime,
                  onDateTimeChanged:(DateTime newDate) {
                    setState(() {
                      selectedEndTime = newDate;
                    });
                  },
                ),
              ),
              SizedBox(height: AppDimensions.generalPadding,),
              ValueListenableProvider<String>.value(
                value: _commonError,
                child: Consumer<String>(
                  builder: (context, value, child) {
                    return Offstage(
                      offstage: ((value?.isEmpty ?? true)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: AppDimensions.generalPadding,
                          right: AppDimensions.generalPadding,
                          top: AppDimensions.maxPadding,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "$value",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.errorTextColor),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.generalPadding,
                  bottom: AppDimensions.maxPadding,),
                child: Column(
                  children: [
                    ValueListenableProvider<bool>.value(
                        value: _bloc.isLoadingForAdd,
                        child: Consumer<bool>(
                            builder: (context, isLoading, child){
                              return isLoading ? _getLoaderWidget() : _getSubmitButton();
                            })
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> daysChipList() {
    List<Widget> chipsList = [];

    DaysEnum.values.asMap().forEach((index, model) {
      chipsList.add(dayChip(describeEnum(model.toString()), index, model.indexValue));
    });

    return chipsList;
  }

  Widget dayChip(String title, int index, int value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8,),
      child: ChoiceChip(
        selected: _selectedDayIndex == value,
        onSelected: (selected){
          if (selected) {
            setState(() {
              _selectedDayIndex = value;
            });
          }
        },
        selectedColor: Theme.of(context).accentColor,
        backgroundColor: AppColors.white,
        side: BorderSide(color: Theme.of(context).accentColor, style: BorderStyle.solid),
        label: Text(title,
          style: Theme.of(context).textTheme.subtitle2.apply(
            color: (_selectedDayIndex == value) ? AppColors.white : AppColors.black,
          ),
        ),
      ),
    );
  }

  Widget _getLoaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator()],
      ),
    );
  }

  Widget _getSubmitButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _processForm(),
            child: Text((widget.availabilityModel != null) ? AppStrings.updateLabel :AppStrings.addLabel,),
          ),
        ),
      ],
    );
  }

  _processForm(){
    var today = DateTime.now();
    var startTime = DateTime(today.year, today.month, today.day,
        selectedStartTime.hour, selectedStartTime.minute);
    var endTime = DateTime(today.year, today.month, today.day,
        selectedEndTime.hour, selectedEndTime.minute);

    if (_selectedDayIndex == -100){
      _commonError.value = AppStrings.selectDayError;
      return;
    } else if (startTime.isAtSameMomentAs(endTime)) {
      _commonError.value = AppStrings.startDateSameError;
      return;
    } else if (startTime.isAfter(endTime)) {
      _commonError.value = AppStrings.startDateLessError;
      return;
    } else {
      _commonError.value = "";
    }

    var userData = <String, dynamic>{
      "cook_id": AppData.user.id,
      "day_index": _selectedDayIndex,
      "from_time": startTime.toUtc().toIso8601String(),
      "to_time": endTime.toUtc().toIso8601String()
    };

    if(widget.availabilityModel != null) userData.putIfAbsent("id", () => widget.availabilityModel.id);

    _bloc.event.add(EventModel((widget.availabilityModel != null)
        ? AddAvailabilityBloc.UPDATE_AVAILABILITY : AddAvailabilityBloc.ADD_AVAILABILITY, data: userData));
  }

}
