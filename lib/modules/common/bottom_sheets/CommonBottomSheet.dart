
import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/logout/LogoutBloc.dart';
import 'package:flutter/material.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:provider/provider.dart';

class CommonBottomSheet {
  static showErrorBottomSheet(context, ResultModel resultModel, {String title = AppStrings.errorText}) {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: ((resultModel?.errorCode ?? -1) != APIConstants.STATUS_CODE_API_UNAUTHORIZED),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.generalPadding),
                    child: Text(title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, fontSizeDelta: 4,),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: AppDimensions.largeTopBottomPadding,
                        bottom: AppDimensions.generalTopPadding,
                        right: AppDimensions.generalPadding,
                        left: AppDimensions.generalPadding),
                    child: Text( ((resultModel?.errorCode ?? 0) == APIConstants.STATUS_CODE_API_UNAUTHORIZED)
                        ? AppStrings.unauthorizedError : "${resultModel.error}",
                      style:  Theme.of(context).textTheme.bodyText1.apply(fontSizeDelta: 4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 22,
                      bottom: 20,
                    ),
                    child: ((resultModel?.errorCode ?? 0) ==
                        APIConstants.STATUS_CODE_API_UNAUTHORIZED) ? LogoutBottomWidget()
                    : ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppStrings.okText,),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> showSuccessBottomSheet(context, String message,
      {String title, Function positiveAction}) async {
    positiveAction = ((positiveAction == null)
        ? () {
            Navigator.of(context).pop();
          }
        : positiveAction);
    await showModalBottomSheet(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.generalPadding),
                    child: Text(title ?? AppStrings.successText,
                      textAlign: TextAlign.center,
                      style:Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, fontSizeDelta: 4,),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: AppDimensions.largeTopBottomPadding,
                        bottom: AppDimensions.generalTopPadding,
                        right: AppDimensions.generalPadding,
                        left: AppDimensions.generalPadding),
                    child: Text(
                      "$message",
                      style: Theme.of(context).textTheme.bodyText1.apply(fontSizeDelta: 4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 22,
                      bottom: 20,
                    ),
                    child: ElevatedButton(
                      onPressed: positiveAction,
                      child: Text(AppStrings.okText,),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> showConfirmationBottomSheet(
      context,  String title, String message, String positiveButtonText, String negativeButtonText,
      Function positiveAction, {Function negativeAction}) async {
    negativeAction = ((negativeAction == null)
        ? () {
            Navigator.of(context).pop();
          }
        : negativeAction);
    await showModalBottomSheet(
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
                padding: const EdgeInsets.only(
                    left: AppDimensions.generalPadding,
                    right: AppDimensions.generalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.generalPadding),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, fontSizeDelta: 4,),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: AppDimensions.largeTopBottomPadding,
                          bottom: AppDimensions.generalTopPadding,
                          right: AppDimensions.generalPadding,
                          left: AppDimensions.generalPadding),
                      child: Text(
                        "$message",
                        style:  Theme.of(context).textTheme.bodyText1.apply(fontSizeDelta: 4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 22,
                        bottom: 20,
                      ),
                      child: Row(
                        children: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(backgroundColor: AppColors.white, shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.all(Radius.circular(AppDimensions.buttonRadius),),),),
                            onPressed: negativeAction,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: AppDimensions.maxPadding,
                                  right: AppDimensions.maxPadding,
                                  top: AppDimensions.generalPadding,
                                  bottom: AppDimensions.generalPadding),
                              child: Text(
                                negativeButtonText, style: Theme.of(context).textTheme.subtitle1.apply(
                                color: Theme.of(context).accentColor),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(backgroundColor: AppColors.white, shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.all(Radius.circular(AppDimensions.buttonRadius),),),),
                            onPressed: positiveAction,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: AppDimensions.maxPadding,
                                  right: AppDimensions.maxPadding,
                                  top: AppDimensions.generalPadding,
                                  bottom: AppDimensions.generalPadding),
                              child: Text((positiveButtonText ?? AppStrings.okText), style: Theme.of(context).textTheme.subtitle1.apply(
                                  color: Theme.of(context).accentColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static invalidFileNameAlertBottomSheet(context) {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.generalPadding),
                    child: Text(AppStrings.errorText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: -1, fontSizeDelta: 4,),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: AppDimensions.largeTopBottomPadding,
                        bottom: AppDimensions.generalTopPadding,
                        right: AppDimensions.generalPadding,
                        left: AppDimensions.generalPadding),
                    child: Text(
                      AppStrings.fileNameError,
                      style:  Theme.of(context).textTheme.bodyText1.apply(fontSizeDelta: 4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 22,
                      bottom: 20,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppStrings.okText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> showSuccessWithLoaderBottomSheet(
      context,  String title, String message) async {

    await showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
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
                padding: const EdgeInsets.only(
                    left: AppDimensions.generalPadding,
                    right: AppDimensions.generalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.generalPadding),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: 1, fontSizeDelta: 5,),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: AppDimensions.largeTopBottomPadding,
                          bottom: AppDimensions.generalTopPadding,
                          right: AppDimensions.generalPadding,
                          left: AppDimensions.generalPadding),
                      child: Text(
                        "$message",
                        style:  Theme.of(context).textTheme.bodyText1.apply(fontSizeDelta: 4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 22,
                        bottom: 20,
                      ),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> showSuccessWithTimerBottomSheet(
      context, String title, String message, {int delayedTimeInSecond = 5}) async {

    await showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        Future.delayed(Duration(seconds: delayedTimeInSecond),() async {
          Navigator.pop(context);
        });
        return SingleChildScrollView(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.generalBottomSheetRadius),
              topRight: Radius.circular(AppDimensions.generalBottomSheetRadius),
            ),
            child: Container(
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppDimensions.generalPadding,
                    right: AppDimensions.generalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.generalPadding),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1.apply(fontWeightDelta: 1, fontSizeDelta: 5,),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: AppDimensions.generalPadding,
                          bottom: AppDimensions.maxPadding,
                          right: AppDimensions.generalPadding,
                          left: AppDimensions.generalPadding),
                      child: Text(message,
                        style:  Theme.of(context).textTheme.bodyText1.apply(fontSizeDelta: 4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
    return ValueListenableProvider<bool>.value(
      value: _bloc.isLoading,
      child: Consumer<bool>(
        builder: (context, loading, child) {
          return (loading) ? CircularProgressIndicator() : ElevatedButton(
            onPressed: () {
              _bloc.event.add(EventModel(LogoutBloc.LOGOUT_EVENT));
            },
            child: Text(
              AppStrings.okText,
            ),
          );
        },
      ),
    );
  }
}
