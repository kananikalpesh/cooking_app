import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/cook/profile/CookProfileBloc.dart';
import 'package:cooking_app/modules/stripe_payment/OnboardingModel.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectStripeBottomSheet{

  static Future<ResultModel<OnboardingModel>> connectStripSheet(
      BuildContext context, CookProfileBloc cookProfileBloc) async {

    ResultModel<OnboardingModel> result = await showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 26),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft:
                  Radius.circular(AppDimensions.generalBottomSheetRadius),
                  topRight:
                  Radius.circular(AppDimensions.generalBottomSheetRadius),
                ),
                child: Container(
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 30, right: 30, top: AppDimensions.generalPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppStrings.connectYourAccount,
                          style: Theme.of(context).textTheme.subtitle1.apply(
                            fontWeightDelta: -1,
                            fontSizeDelta: 4,
                          ),
                        ),
                        SizedBox(
                          height: AppDimensions.largeTopBottomPadding,
                        ),
                        ConnectStripeDialogWidget(cookProfileBloc),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });

    return result;
  }

}

class ConnectStripeDialogWidget extends StatefulWidget{

  final CookProfileBloc cookProfileBloc;


  ConnectStripeDialogWidget(this.cookProfileBloc);

  @override
  State<StatefulWidget> createState() => ConnectStripeDialogWidgetState();
}

class ConnectStripeDialogWidgetState extends State<ConnectStripeDialogWidget>{

  ValueNotifier<String> _apiResponseError = ValueNotifier("");

  String stripeErrorMessage = "";

  @override
  void initState() {
    AppData.user.pgStatus.errorMessages.forEach((element) {
      stripeErrorMessage += "\n${element.reason}";
    });

    widget.cookProfileBloc.obsOnBoardingDetails.stream.listen((result) async {
      Navigator.of(context).pop(result);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text("${AppData.pgStatus.displayMessage}", textAlign: TextAlign.center, style: Theme.of(context).textTheme.subtitle1,)),
            ],
          ),

          Offstage(offstage: (stripeErrorMessage?.isEmpty ?? true),
              child: SizedBox(height: AppDimensions.generalMinPadding,)),

          Offstage(offstage: (stripeErrorMessage?.isEmpty ?? true),
            child: Row(mainAxisAlignment: MainAxisAlignment.start,
              children: [
              Expanded(child: Text("${stripeErrorMessage ?? ""}", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText1.apply(color: AppColors.errorTextColor),)),
            ],),
          ),


          SizedBox(height: AppDimensions.generalPadding,),

          ValueListenableProvider<String>.value(
            value: _apiResponseError,
            child: Consumer<String>(
              builder: (context, value, child) {
                return Offstage(
                  offstage: ((value?.isEmpty ?? true)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,
                      top: AppDimensions.generalPadding,
                    ),
                    child: Text(
                      "$value",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.errorTextColor),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: AppDimensions.largeTopBottomPadding,
          ),
          ValueListenableProvider<bool>.value(
            value: widget.cookProfileBloc.isLoadingForOnBoarding,
            child: Consumer<bool>(
              builder: (context, loading, child) {
                return (loading) ? _getLoaderWidget() : _getConnectStripeButton();
              },
            ),
          ),
        ],),
    );
  }

  @override
  void dispose() {

    super.dispose();
  }

  Widget _getLoaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator()
        ],
      ),
    );
  }

  Widget _getConnectStripeButton() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.generalPadding,
      ),
      child: ElevatedButton(
        onPressed: () {
          widget.cookProfileBloc.event.add(EventModel(CookProfileBloc.ON_BOARDING_CREATE_ACCOUNT,));
        },
        child: Text(AppStrings.setupWithStripe),
      ),
    );
  }


}