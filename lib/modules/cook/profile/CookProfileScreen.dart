
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/common/widgets/CustomImageShapeWidget.dart';
import 'package:cooking_app/modules/common/widgets/WebScreen.dart';
import 'package:cooking_app/modules/cook/profile/CookProfileBloc.dart';
import 'package:cooking_app/modules/cook/profile/availabilities/ManageAvailabilitiesScreen.dart';
import 'package:cooking_app/modules/cook/profile/edit_profile/EditProfileScreen.dart';
import 'package:cooking_app/modules/dashboard/DashboardBloc.dart';
import 'package:cooking_app/modules/other_user/user_review/UserReviewsScreens.dart';
import 'package:cooking_app/modules/stripe_payment/StripeOnboardingScreen.dart';
import 'package:cooking_app/modules/logout/LogoutBottomSheet.dart';
import 'package:cooking_app/modules/user/profile/change_password/ChangePasswordBottomSheet.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CookProfileScreen extends StatefulWidget {

  final DashboardBloc dashBoardBloc;

  CookProfileScreen(this.dashBoardBloc);

  @override
  _CookProfileScreenState createState() => _CookProfileScreenState();
}

class _CookProfileScreenState extends State<CookProfileScreen> {

  CookProfileBloc _bloc;
  UserModel profileModel;
  ValueNotifier<bool> _showStripeSetupMessage = ValueNotifier(false);

  @override
  void initState() {
    _bloc = CookProfileBloc();
      
    _bloc.obsGetUserProfile.stream.listen((result) {

      if (result.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context,result);
      }else{

          widget.dashBoardBloc.updateCookDashBoardBottomBar.value = (!widget.dashBoardBloc.updateCookDashBoardBottomBar.value);

        if((AppData.pgStatus?.block ?? false) == false && (AppData.pgStatus?.flashMessage ?? false) == true){
          _showStripeSetupMessage.value = true;
        }
      }
    });
    _bloc.event.add(EventModel(CookProfileBloc.GET_PROFILE_EVENT, data: AppData.user.id));

    _bloc.obsOnBoardingDetails.stream.listen((result) async {

      if (result.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context, result);
      } else {
        var paymentModel = result.data;

        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
        SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
        var response = await Navigator.of(context)
            .push(MaterialPageRoute(
            builder: (context) => StripeOnboardingScreen(url: paymentModel.link,
              refreshUrl: paymentModel.refreshUrl, returnUrl: paymentModel.returnUrl,)));
        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
        SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleBottomTabBar);

        if (response != null && !(response is bool)){
          //Failed
          CommonBottomSheet.showErrorBottomSheet(context, ResultModel(error: AppStrings.accFailedDesc,),
            title: AppStrings.accFailedTitle,);
        }
      }
    });

    if((AppData.pgStatus?.block ?? false) == false && (AppData.pgStatus?.flashMessage ?? false) == true){
      _showStripeSetupMessage.value = true;
    }
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResultModel<UserModel>>(
      stream: _bloc.obsGetUserProfile.stream,
      builder: (context, AsyncSnapshot<ResultModel<UserModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data?.data != null){
            profileModel = snapshot.data?.data;
            AppData.user = snapshot.data?.data;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  mainContainerWidget(),
                ],
              ),
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
    );
  }

  Widget mainContainerWidget(){
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 50), //180
                        child: Container(
                          height: 95,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(AppDimensions.cardRadius),
                              topRight: Radius.circular(AppDimensions.cardRadius),),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0), //120
                      child: Column(mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              CustomImageShapeWidget(
                                100,
                                100,
                                100 / 2,
                                CachedNetworkImage(
                                  key: GlobalKey(),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fill,
                                  imageUrl: (profileModel.userImage == null) ? "" : profileModel.userImage,
                                  progressIndicatorBuilder: (context,
                                      url, downloadProgress) =>
                                      Image.asset(
                                        "assets/loading_image.png",
                                        fit: BoxFit.cover,
                                      ),
                                  errorWidget:
                                      (context, url, error) =>
                                      Image.asset(
                                        "assets/profile_user_default_icon.png",
                                        fit: BoxFit.cover,
                                      ),
                                ),
                              ),
                              SizedBox(
                                width: AppDimensions.generalPadding,
                              ),
                              Expanded(
                                child: Text(profileModel.firstName ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4,),
                              ),
                              SizedBox(
                                width: AppDimensions.generalMinPadding,),
                              GestureDetector(onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => UserReviewsScreens(profileModel.id, profileModel.firstName, isCook: true,)));
                              },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundGrey300,
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10, right: AppDimensions.generalPadding,
                                        top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                                    child: Row(
                                      children: [
                                        Icon(Icons.star, color: AppColors.starRating, size: 20,),
                                        SizedBox(width: 3,),
                                        Text(double.parse(profileModel?.cookRating?.toStringAsFixed(1))?.toString() ?? "0.0", style: Theme.of(context).textTheme.subtitle2,),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: AppDimensions.generalPadding,),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                personalInfoWidget(),
                SizedBox(height: AppDimensions.maxPadding,),
                manageAvailabilityWidget(),
                SizedBox(height: AppDimensions.maxPadding,),
                addBankAccWidget(),
                SizedBox(height: AppDimensions.generalMinPadding,),
                ValueListenableProvider<bool>.value(value: _showStripeSetupMessage,
                child: Consumer<bool>(builder: (context, value, child){
                  return Offstage(offstage: (!value),
                    child: Row(
                      children: [
                        Expanded(child: Text(AppData.pgStatus?.displayMessage ?? "",
                          textAlign: TextAlign.start,)),
                      ],
                    ),
                  );
                }),),
                SizedBox(height: AppDimensions.maxPadding,),
                privacyPolicyWidget(),
                SizedBox(height: AppDimensions.maxPadding,),
                tncWidget(),
                SizedBox(height: AppDimensions.maxPadding,),
                changePasswordWidget(),
                SizedBox(height: AppDimensions.maxPadding,),
                logoutWidget(),
                SizedBox(height: AppDimensions.maxPadding,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget personalInfoWidget(){
    return Container(
      decoration: BoxDecoration(
        color: AppColors.profileSectionsBg,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.generalRadius)),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGray,
            offset: Offset(0.0, 1.0),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 10,),
              Expanded(
                child: Text(AppStrings.personalInfo, style: Theme.of(context).textTheme.headline5.apply(
                  color: AppColors.sectionTitleColor,
                ),),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding),
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          width: 2, color: Theme.of(context).accentColor),
                      color: Theme.of(context).accentColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: Center(
                          child: Icon(Icons.edit, color: AppColors.white, size: 20,),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    SystemChrome.setEnabledSystemUIOverlays(
                        [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                    SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                        builder: (context) => EditProfileScreen(profileModel, _bloc)))
                        .then((value) {
                      SystemChrome.setEnabledSystemUIOverlays(
                          [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                      SystemChrome.setSystemUIOverlayStyle(
                          AppTheme.overlayStyleBottomTabBar);
                    });
                  },
                ),
              ),
              SizedBox(width: 10,),
            ],
          ),
          Divider(),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.emailId,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText1,
                ),
                SizedBox(height: 3,),
                Text(profileModel.email ?? "-",
                  style: Theme
                      .of(context)
                      .textTheme
                      .subtitle2
                      .apply(
                      color: AppColors.black
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.aboutMeTitle,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText1,
                ),
                SizedBox(height: 3,),
                Text((profileModel.aboutMe?.isNotEmpty ?? false) ? profileModel.aboutMe : "-" ,
                  style: Theme
                      .of(context)
                      .textTheme
                      .subtitle2
                      .apply(
                      color: AppColors.black
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.cuisine,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText1,
                ),
                SizedBox(height: 3,),
                (profileModel.cooksCuisines != null && profileModel.cooksCuisines.isNotEmpty) ?
                Wrap(children: cuisineChipList(),)
                    : Text("-", style: Theme
                    .of(context)
                    .textTheme
                    .subtitle2
                    .apply(
                    color: AppColors.black
                ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.dietary,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText1,
                ),
                SizedBox(height: 3,),
                (profileModel.cooksDiets != null && profileModel.cooksDiets.isNotEmpty) ?
                Wrap(children: dietaryChipList(),)
                    : Text("-", style: Theme
                      .of(context)
                      .textTheme
                      .subtitle2
                      .apply(
                      color: AppColors.black
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.generalPadding,),
        ],
      ),
    );
  }

  Widget changePasswordWidget(){
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.profileSectionsBg,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.generalRadius)),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGray,
              offset: Offset(0.0, 1.0),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppDimensions.generalPadding,),
            Row(
              children: [
                SizedBox(width: 10,),
                Expanded(
                  child: Text(AppStrings.changePass, style: Theme.of(context).textTheme.headline5.apply(
                    color: AppColors.sectionTitleColor,
                  ),),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.generalPadding,),
          ],
        ),
      ),
      onTap: (){
        ChangePasswordBottomSheet.showChangePassSheet(context);
      },
    );
  }

  Widget privacyPolicyWidget(){
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.profileSectionsBg,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.generalRadius)),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGray,
              offset: Offset(0.0, 1.0),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppDimensions.generalPadding,),
            Row(
              children: [
                SizedBox(width: 10,),
                Expanded(
                  child: Text(AppStrings.privacyPolicyLabel, style: Theme.of(context).textTheme.headline5.apply(
                    color: AppColors.sectionTitleColor,
                  ),),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.generalPadding,),
          ],
        ),
      ),
      onTap: (){
        var link = APIConstants.PRIVACY_POLICY;
        if (link != null) {
          if (Platform.isIOS) {
            launch(link.startsWith("http") ? link : "https://" + link);
          } else {
            SystemChrome.setEnabledSystemUIOverlays(
                [SystemUiOverlay.bottom, SystemUiOverlay.top]);
            SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
            Navigator.of(context)
                .push(MaterialPageRoute(
                builder: (context) => WebScreen(AppStrings.privacyPolicyLabel, link)))
                .then((value) {
              SystemChrome.setEnabledSystemUIOverlays(
                  [SystemUiOverlay.bottom, SystemUiOverlay.top]);
              SystemChrome.setSystemUIOverlayStyle(
                  AppTheme.overlayStyleBottomTabBar);
            });
          }
        }
      },
    );
  }

  Widget tncWidget(){
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.profileSectionsBg,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.generalRadius)),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGray,
              offset: Offset(0.0, 1.0),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppDimensions.generalPadding,),
            Row(
              children: [
                SizedBox(width: 10,),
                Expanded(
                  child: Text(AppStrings.tncLabel, style: Theme.of(context).textTheme.headline5.apply(
                    color: AppColors.sectionTitleColor,
                  ),),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.generalPadding,),
          ],
        ),
      ),
      onTap: (){
        var link = APIConstants.TERMS_AND_CONDITIONS;
        if (link != null) {
          if (Platform.isIOS) {
            launch(link.startsWith("http") ? link : "https://" + link);
          } else {
            SystemChrome.setEnabledSystemUIOverlays(
                [SystemUiOverlay.bottom, SystemUiOverlay.top]);
            SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
            Navigator.of(context)
                .push(MaterialPageRoute(
                builder: (context) => WebScreen(AppStrings.tncLabel, link)))
                .then((value) {
              SystemChrome.setEnabledSystemUIOverlays(
                  [SystemUiOverlay.bottom, SystemUiOverlay.top]);
              SystemChrome.setSystemUIOverlayStyle(
                  AppTheme.overlayStyleBottomTabBar);
            });
          }
        }
      },
    );
  }

  Widget manageAvailabilityWidget(){
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.profileSectionsBg,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.generalRadius)),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGray,
              offset: Offset(0.0, 1.0),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppDimensions.generalPadding,),
            Row(
              children: [
                SizedBox(width: 10,),
                Expanded(
                  child: Text(AppStrings.manageMySchedule, style: Theme.of(context).textTheme.headline5.apply(
                    color: AppColors.sectionTitleColor,
                  ),),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.generalPadding,),
          ],
        ),
      ),
      onTap: (){
        SystemChrome.setEnabledSystemUIOverlays(
            [SystemUiOverlay.bottom, SystemUiOverlay.top]);
        SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyleDefault);
        Navigator.of(context)
            .push(MaterialPageRoute(
            builder: (context) => ManageAvailabilitiesScreen()))
            .then((value) {
          SystemChrome.setEnabledSystemUIOverlays(
              [SystemUiOverlay.bottom, SystemUiOverlay.top]);
          SystemChrome.setSystemUIOverlayStyle(
              AppTheme.overlayStyleBottomTabBar);
        });
      },
    );
  }

  Widget addBankAccWidget(){
    return ValueListenableProvider<bool>.value(
      value: _bloc.isLoadingForOnBoarding,
      child: Consumer<bool>(
        builder: (context, isLoading, child){
          return GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.profileSectionsBg,
                borderRadius: BorderRadius.all(Radius.circular(AppDimensions.generalRadius)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lightGray,
                    offset: Offset(0.0, 1.0),
                    blurRadius: 4.0,
                  ),
                ],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.generalPadding,),
                  Row(
                    children: [
                      SizedBox(width: 10,),
                      Expanded(
                        child: Text(AppStrings.setupWithStripe, style: Theme.of(context).textTheme.headline5.apply(
                          color: AppColors.sectionTitleColor,
                        ),),
                      ),
                      (isLoading) ? SizedBox(child: CircularProgressIndicator(strokeWidth: 2,), width: 25, height: 25,)
                          : Container(),
                      SizedBox(width: 10,),
                    ],
                  ),
                  SizedBox(height: AppDimensions.generalPadding,),
                ],
              ),
            ),
            onTap: (){
              _bloc.event.add(EventModel(CookProfileBloc.ON_BOARDING_CREATE_ACCOUNT,));
            },
          );
        },
      ),
    );
  }

  List<Widget> cuisineChipList() {
    List<Widget> chipsList = [];

    if(profileModel.cooksCuisines != null && profileModel.cooksCuisines.isNotEmpty) {
      profileModel.cooksCuisines.asMap().forEach((index, model) {
        chipsList.add(tagChip(model.name, index));
      });
    }

    return chipsList;
  }

  List<Widget> dietaryChipList() {
    List<Widget> chipsList = [];

    if(profileModel.cooksDiets != null && profileModel.cooksDiets.isNotEmpty) {
      profileModel.cooksDiets.asMap().forEach((index, model) {
        chipsList.add(tagChip(model.name, index));
      });
    }

    return chipsList;
  }

  Widget tagChip(String title, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8,),
      child: Chip(
        backgroundColor: AppColors.white,
        side: BorderSide(color: Theme.of(context).accentColor, style: BorderStyle.solid),
        label: Text(title,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ),
    );
  }

  Widget logoutWidget(){
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.profileSectionsBg,
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.generalRadius)),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGray,
              offset: Offset(0.0, 1.0),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.generalPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 25, color: AppColors.sectionTitleColor,),
              SizedBox(width: 10,),
              Text(AppStrings.logoutLabel, style: Theme.of(context).textTheme.headline5.apply(
                color: AppColors.sectionTitleColor,
              ),),
            ],
          ),
        ),
      ),
      onTap: (){
        LogoutBottomSheet.showLogoutSheet(context);
      },
    );
  }

}
