
import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/logout/LogoutBloc.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class
LogoutBottomSheet{

  static void showLogoutSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.generalBottomSheetRadius),
                topRight: Radius.circular(AppDimensions.generalBottomSheetRadius),
              ),
              child: Container(
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: AppDimensions.generalPadding, right: AppDimensions.generalPadding, top: AppDimensions.generalPadding, bottom: AppDimensions.maxPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(AppStrings.logoutLabel, style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, fontSizeDelta: 4,),),
                    SizedBox(height: AppDimensions.maxPadding,),
                    Text(AppStrings.logoutConfirmationMessage, style: Theme.of(context).textTheme.bodyText1.apply(fontSizeDelta: 4),),
                    SizedBox(height: AppDimensions.maxPadding,),
                    LogoutBottomWidget(),
                  ],
                ),
              ),),
            ),
          );
        });
  }
}

class LogoutBottomWidget extends StatefulWidget {

  @override
  _LogoutBottomWidgetState createState() => _LogoutBottomWidgetState();
}

class _LogoutBottomWidgetState extends State<LogoutBottomWidget> {

  LogoutBloc _bloc;
  
  @override
  void initState() {
    _bloc = LogoutBloc();

    _bloc.obsLogout.stream.listen((result) {
      if (result.error != null) {
        Navigator.of(context).pop();
        CommonBottomSheet.showErrorBottomSheet(context, result);
      } else {
        Navigator.of(context).pop();
        ServerConnectionHelper.handleUnAuthorizedStatusCode(context);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Row(
        children: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(backgroundColor: AppColors.white, shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(AppDimensions.buttonRadius),),),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: AppDimensions.maxPadding,
                  right: AppDimensions.maxPadding,
                  top: AppDimensions.generalPadding,
                  bottom: AppDimensions.generalPadding),
              child: Text(
                AppStrings.cancelButtonName, style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ),
          Expanded(child: Container(),),
          ValueListenableProvider<bool>.value(
            value: _bloc.isLoading,
            child: Consumer<bool>(
              builder: (context, loading, child) {
                return (loading) ? CircularProgressIndicator() : ElevatedButton(
                  onPressed: (){
                    _bloc.event.add(EventModel(LogoutBloc.LOGOUT_EVENT));
                  },
                  child: Text(AppStrings.logoutLabel,),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}