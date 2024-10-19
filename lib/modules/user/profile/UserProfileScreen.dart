import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/constants/APIConstants.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/common/widgets/CustomImageShapeWidget.dart';
import 'package:cooking_app/modules/common/widgets/WebScreen.dart';
import 'package:cooking_app/modules/logout/LogoutBottomSheet.dart';
import 'package:cooking_app/modules/other_user/OtherUserProfileScreen.dart';
import 'package:cooking_app/modules/other_user/user_review/UserReviewsScreens.dart';
import 'package:cooking_app/modules/user/profile/UserProfileBloc.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'change_password/ChangePasswordBottomSheet.dart';
import 'edit_profile/EditProfileScreen.dart';


//This screen is used for User and Admin
class UserProfileScreen extends StatefulWidget {

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  UserProfileBloc _bloc;
  UserModel profileModel;

  @override
  void initState() {
    _bloc = UserProfileBloc();
    _bloc.obsGetUserProfile.stream.listen((result) {
      if (result.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context,result);
      }
    });
    _bloc.event.add(EventModel(UserProfileBloc.GET_PROFILE_EVENT, data: AppData.user.id));
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
                            imageUrl: (profileModel?.userImage != null) ? profileModel.userImage : "",
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
                        Offstage(offstage: (AppData.user.role != AppConstants.ROLE_USER),
                          child: SizedBox(
                            width: AppDimensions.generalMinPadding,),
                        ),
                        Offstage(offstage: (AppData.user.role != AppConstants.ROLE_USER),
                          child: GestureDetector(onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => UserReviewsScreens(profileModel.id, profileModel.firstName)));
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
          changePasswordWidget(),
          SizedBox(height: AppDimensions.maxPadding,),
          privacyPolicyWidget(),
          SizedBox(height: AppDimensions.maxPadding,),
          tncWidget(),
          //SizedBox(height: AppDimensions.maxPadding,),
          //paymentMethodWidget(),
          SizedBox(height: AppDimensions.maxPadding,),
          logoutWidget(),
          SizedBox(height: AppDimensions.maxPadding,),
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
          Offstage(offstage: (AppData.user.role == AppConstants.ROLE_USER), child: SizedBox(height: 8,)),
          Row(
            children: [
              SizedBox(width: 10,),
              Expanded(
                child: Text(AppStrings.personalInfo, style: Theme.of(context).textTheme.headline5.apply(
                  color: AppColors.sectionTitleColor,
                ),),
              ),
              Offstage(
                offstage: (AppData.user.role == AppConstants.ROLE_ADMIN),
                child: Padding(
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
                          builder: (context) => EditProfileScreen(profileModel)))
                          .then((value) {
                        _bloc.event.add(EventModel(UserProfileBloc.GET_PROFILE_EVENT, data: AppData.user.id));
                        SystemChrome.setEnabledSystemUIOverlays(
                            [SystemUiOverlay.bottom, SystemUiOverlay.top]);
                        SystemChrome.setSystemUIOverlayStyle(
                            AppTheme.overlayStyleBottomTabBar);
                      });
                    },
                  ),
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
                Text(profileModel.aboutMe ?? "-",
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

  Widget paymentMethodWidget(){
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
                  child: Text(AppStrings.paymentMethod, style: Theme.of(context).textTheme.headline5.apply(
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
            builder: (context) => OtherUserProfileScreen()))
            .then((value) {
          SystemChrome.setEnabledSystemUIOverlays(
              [SystemUiOverlay.bottom, SystemUiOverlay.top]);
          SystemChrome.setSystemUIOverlayStyle(
              AppTheme.overlayStyleBottomTabBar);
        });
      },
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
