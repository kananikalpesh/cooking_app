
import 'package:cooking_app/modules/admin/all_users/FlaggedUsersListModel.dart';
import 'package:cooking_app/modules/admin/all_users/users/UserListBloc.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/other_user/OtherUserProfileScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDateUtils.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

typedef _FlaggedUserCallback(bool isIgnored, bool isBlocked);

class FlaggedUserItem extends StatefulWidget{

  final FlaggedUserDetailsModel _flaggedUserDetailsModel;
  final _FlaggedUserCallback _onFlaggedUserCallback;
  final UserListBloc _bloc;
  final int index;
  FlaggedUserItem(this.index, this._flaggedUserDetailsModel, this._bloc, this._onFlaggedUserCallback);

  @override
  State<StatefulWidget> createState() => _FlaggedUserItemState();

}

class _FlaggedUserItemState extends State<FlaggedUserItem>{

  ValueNotifier<bool> isLoadingForIgnore = ValueNotifier(false);
  ValueNotifier<bool> isLoadingForBlock = ValueNotifier(false);

  @override
  void initState() {
    widget._bloc.obsIgnoreUser.listen((result) {
      if (widget.index == widget._bloc.ignoreLoadingIndex){
        isLoadingForIgnore.value = false;
        widget._bloc.ignoreLoadingIndex = -1;
        if (result.error != null) {
          CommonBottomSheet.showErrorBottomSheet(context, result);
        } else {
          widget._onFlaggedUserCallback(true, false);
        }
      }
    });

    widget._bloc.obsBlockUser.listen((result) {
      if (widget.index == widget._bloc.blockLoadingIndex){
        isLoadingForBlock.value = false;
        widget._bloc.blockLoadingIndex = -1;
        if (result.error != null) {
          CommonBottomSheet.showErrorBottomSheet(context, result);
        } else {
          widget._onFlaggedUserCallback(false, true);
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(top: AppDimensions.generalPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(top:AppDimensions.generalTopPadding, bottom: AppDimensions.generalTopPadding),
          child: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget._flaggedUserDetailsModel.user.name,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      SizedBox(height: 5,),
                      Text(widget._flaggedUserDetailsModel.user.email,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),

                      SizedBox(height: 6,),
                      Text("${AppDateUtils.dateOnlyFormatToString(widget._flaggedUserDetailsModel.reportedDate)}",
                        style: Theme.of(context).textTheme.bodyText2,
                      ),

                      SizedBox(height: 8,),
                      Text(widget._flaggedUserDetailsModel.reportedComment,
                        style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -2),
                      ),

                      SizedBox(height: 6,),
                      Text("${AppStrings.reportedBy}${widget._flaggedUserDetailsModel.reporter.name}",
                        style: Theme.of(context).textTheme.bodyText2,
                      ),

                    ],
                  ),
                ),
                SizedBox(width: 8,),
                Column(children: [
                  ValueListenableProvider<bool>.value(value: isLoadingForIgnore,
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
                                child: Icon(Icons.remove, color: AppColors.white, size: 20,),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          CommonBottomSheet.showConfirmationBottomSheet(
                            context,
                            AppStrings.ignoreButtonName,
                            AppStrings.ignoreUserMsg,
                            AppStrings.ignoreButtonName,
                            AppStrings.cancelButtonName,
                                () {
                              Navigator.of(context).pop();
                              isLoadingForIgnore.value = true;
                              widget._bloc.ignoreLoadingIndex = widget.index;
                              widget._bloc.event.sink.add(EventModel(
                                  UserListBloc.IGNORE_USER,
                                  data: widget._flaggedUserDetailsModel.id));
                            },
                          );
                        },
                      );
                    }),),
                  SizedBox(height: AppDimensions.largeTopBottomPadding,),
                  ValueListenableProvider<bool>.value(value: isLoadingForBlock,
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
                                  width: 0, color: AppColors.redBgButton),
                              color: AppColors.redBgButton,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Center(
                                child: Icon(Icons.block, color: AppColors.white, size: 20,),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          CommonBottomSheet.showConfirmationBottomSheet(
                            context,
                            AppStrings.blockButtonName,
                            AppStrings.blockUserMsg,
                            AppStrings.blockButtonName,
                            AppStrings.cancelButtonName,
                                () {
                              Navigator.of(context).pop();
                              isLoadingForBlock.value = true;
                              widget._bloc.blockLoadingIndex = widget.index;
                              widget._bloc.event.sink.add(EventModel(
                                  UserListBloc.BLOCK_USER,
                                  data: widget._flaggedUserDetailsModel.id));
                            },
                          );
                        },
                      );
                    }),),
                ],),
              ],
            ),
          ),
        ),
      ),
    );
  }

}