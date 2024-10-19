
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/common/widgets/CustomSliverOverlapAbsorber.dart';
import 'package:cooking_app/modules/other_user/user_review/UserReviewsScreens.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:flutter/material.dart';
import 'OtherUserProfileBloc.dart';

class OtherUserProfileScreen extends StatefulWidget {

  final int userId;
  OtherUserProfileScreen({this.userId});

  @override
  _OtherUserProfileScreenState createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {

  OtherUserProfileBloc _bloc;
  UserModel profileModel;

  @override
  void initState() {
    _bloc = OtherUserProfileBloc();

    _bloc.event.add(EventModel(OtherUserProfileBloc.GET_PROFILE_EVENT, data: widget.userId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResultModel<UserModel>>(
      stream: _bloc.obsGetUserProfile.stream,
      builder: (context, AsyncSnapshot<ResultModel<UserModel>> snapshot) {

        return Scaffold(
          body: BaseFormBodyUnsafe(
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
                return <Widget>[
                  CustomSliverOverlapAbsorber(
                    parentContext: context,
                    expandedHeight: 220,
                    imagePath: (snapshot.data?.data?.userImage ?? ""),
                    title: (snapshot.data?.data?.firstName ?? ""),
                  )
                ];
              },
              body: _getBody(snapshot),
            ),
          ),
        );
      },
    );

  }

  Widget _getBody(AsyncSnapshot<ResultModel<UserModel>> snapshot){
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
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.generalPadding),
          child: Center(
            child: Text(snapshot.data?.error,
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } else if (snapshot.hasError) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.generalPadding),
        child: Center(
          child: Text(snapshot.error,
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator());
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

                personalInfoWidget(),
                SizedBox(height: AppDimensions.maxPadding,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget personalInfoWidget(){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppDimensions.generalTopPadding,),
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 5),
          child: Text(AppStrings.personalInfo, style: Theme.of(context).textTheme.headline5.apply(
            color: AppColors.sectionTitleColor,
          ),),
        ),
        Divider(),
        SizedBox(height: 10,),
        Row(children: [
          Expanded(child: Container()),
          GestureDetector(onTap: (){
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
        ],),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.emailId,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyText1.apply(fontSizeDelta: 1),
              ),
              SizedBox(height: 5,),
              Text(profileModel.email ??"-",
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle2
                    .apply(
                    color: AppColors.black, fontSizeDelta: 1,
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 20,),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.aboutMeTitle,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyText1.apply(fontSizeDelta: 1),
              ),
              SizedBox(height: 5,),
              Text(profileModel.aboutMe ?? "-",
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle2
                    .apply(
                    color: AppColors.black, fontSizeDelta: 1,
                ),
              )
            ],
          ),
        ),
        SizedBox(height: AppDimensions.generalPadding,),
      ],
    );
  }

}
