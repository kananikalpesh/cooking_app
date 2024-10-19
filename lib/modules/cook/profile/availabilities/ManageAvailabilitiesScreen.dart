
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/cook/profile/CookAvailabilityModel.dart';
import 'package:cooking_app/modules/cook/profile/CookProfileBloc.dart';
import 'package:cooking_app/modules/cook/profile/availabilities/DaysEnum.dart';
import 'package:cooking_app/modules/cook/profile/availabilities/ManageAvailabilityBloc.dart';
import 'package:cooking_app/modules/cook/profile/availabilities/add_availability/AddAvailabilityScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDateUtils.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageAvailabilitiesScreen extends StatefulWidget {
  final CookProfileBloc cookBloc;
  final bool isInComplete;

  ManageAvailabilitiesScreen({this.cookBloc, this.isInComplete = false});

  @override
  _ManageAvailabilitiesState createState() => _ManageAvailabilitiesState();
}

class _ManageAvailabilitiesState extends State<ManageAvailabilitiesScreen> {

  ManageAvailabilityBloc _bloc;

  @override
  void initState() {
    _bloc = ManageAvailabilityBloc();
    _bloc.event.add(EventModel(ManageAvailabilityBloc.GET_PROFILE_EVENT, data: AppData.user.id));
    super.initState();
    if(widget.isInComplete){
      Future.delayed(Duration(microseconds: 100), (){
        CommonBottomSheet.showSuccessBottomSheet(context, AppStrings.redirectedToCompleteAvailability, title: AppStrings.updateAvailability);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.mySchedule),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: AppDimensions.generalPadding),
              child: IconButton(icon: Icon(Icons.add_circle), color: Theme.of(context).accentColor, iconSize: 30,
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                      builder: (context) => AddAvailabilityScreen(_bloc)));
                },),
          ),
        ],
      ),
      body: StreamBuilder<ResultModel<UserModel>>(
        stream: _bloc.obsGetUserProfile.stream,
        builder: (context, AsyncSnapshot<ResultModel<UserModel>> snapshot) {
          if(snapshot?.data?.data != null) AppData.user = snapshot.data.data;
          if (widget.cookBloc != null) widget.cookBloc.event.add(EventModel(ManageAvailabilityBloc.GET_PROFILE_EVENT, data: AppData.user.id)); //This is to update availabilities on my lesson
          if (snapshot.hasData) {
            if (snapshot.data?.data != null){
              return ((snapshot.data?.data?.cookAvailabilities?.length) == 0) ?
              Padding(
                padding: const EdgeInsets.all(AppDimensions.generalPadding),
                child: Center(
                  child: Text(AppStrings.emptyAvailabilities,
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ) : ListView.builder(
                padding: EdgeInsets.only(top: AppDimensions.maxPadding, left: AppDimensions.generalPadding,
                    right: AppDimensions.generalPadding),
                itemCount: snapshot.data?.data?.cookAvailabilities?.length,
                itemBuilder: (context, index) {
                  return _AvailabilityItem(index, snapshot.data?.data?.cookAvailabilities[index],
                      _bloc, (isDeleted){
                    if (isDeleted){
                      snapshot.data?.data?.cookAvailabilities?.removeAt(index);
                      setState(() {});
                      _bloc.event.add(EventModel(ManageAvailabilityBloc.GET_PROFILE_EVENT, data: AppData.user.id));
                    }
                  });
                },
              );
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.generalPadding),
                  child: Text(snapshot.data?.error,
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.generalPadding),
                child: Text(snapshot.error,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}

typedef _AvailabilityDeleted(bool isDeleted);

class _AvailabilityItem extends StatefulWidget{

  final CookAvailabilityModel _availabilityModel;
  final _AvailabilityDeleted _onAvailabilityDeleted;
  final ManageAvailabilityBloc _bloc;
  final int index;
  _AvailabilityItem(this.index, this._availabilityModel, this._bloc, this._onAvailabilityDeleted);

  @override
  _AvailabilityItemState createState() => _AvailabilityItemState();
}

class _AvailabilityItemState extends State<_AvailabilityItem>{

  ValueNotifier<bool> isLoadingForDelete = ValueNotifier(false);

  @override
  void initState() {

    widget._bloc.obsDeleteAvailability.listen((result) {
      if (widget.index == widget._bloc.deleteLoadingIndex){
        isLoadingForDelete.value = false;
        widget._bloc.deleteLoadingIndex = -1;
        if (result.error != null) {
          CommonBottomSheet.showErrorBottomSheet(context, result);
        } else {
          widget._onAvailabilityDeleted(true);
        }
      }
    });
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(bottom: AppDimensions.generalPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(top:AppDimensions.generalTopPadding, bottom: AppDimensions.generalTopPadding),
          child: ListTile(
            onTap: (){
              Navigator.of(context)
                  .push(MaterialPageRoute(
                  builder: (context) => AddAvailabilityScreen(widget._bloc, availabilityModel: widget._availabilityModel,)));
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AvailabilityDays.getDayValue(widget._availabilityModel.dayIndex),
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: 5,),
                Text("${AppDateUtils.timeOnlyFormatToString(widget._availabilityModel.startDateTime.toLocal())} to ${AppDateUtils.timeOnlyFormatToString(widget._availabilityModel.endDateTime.toLocal())}",
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
            trailing: ValueListenableProvider<bool>.value(value: isLoadingForDelete,
              child: Consumer<bool>(builder: (context, isLoading, child){
                return isLoading
                    ? SizedBox(width: 25, height: 25, child: CircularProgressIndicator())
                    : GestureDetector(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            width: 0, color: Theme.of(context).accentColor),
                        color: Theme.of(context).accentColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Center(
                          child: Icon(Icons.delete, color: AppColors.white, size: 20,),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    CommonBottomSheet.showConfirmationBottomSheet(
                      context,
                      AppStrings.deleteButtonName,
                      AppStrings.deleteAvailabilityMsg,
                      AppStrings.deleteButtonName,
                      AppStrings.cancelButtonName,
                          () {
                        Navigator.of(context).pop();
                        isLoadingForDelete.value = true;
                        widget._bloc.deleteLoadingIndex = widget.index;
                        widget._bloc.event.sink.add(EventModel(
                            ManageAvailabilityBloc.DELETE_AVAILABILITY,
                            data: widget._availabilityModel.id));
                      },
                    );
                  },
                );
              }),),
          ),
        ),
      ),
    );
  }

}
