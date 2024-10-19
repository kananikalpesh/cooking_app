import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/common/gallery/MediaPageViewScreen.dart';
import 'package:cooking_app/modules/cook/profile/other_user/OtherCookProfileBloc.dart';
import 'package:cooking_app/modules/cook/profile/other_user/lesson/OtherCooksLessonsScreen.dart';
import 'package:cooking_app/modules/cook/profile/other_user/other_cook_reviews/OtherCooksReviewsScreen.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtherCookProfileScreen extends StatefulWidget {

  final int cookId;
  OtherCookProfileScreen({this.cookId});

  @override
  _OtherCookProfileScreenState createState() => _OtherCookProfileScreenState();
}

class _OtherCookProfileScreenState extends State<OtherCookProfileScreen> {

  OtherCookProfileBloc _bloc;
  UserModel cookModel;

  ValueNotifier<int> _currentIndex = ValueNotifier(0);
  final PageController controller = new PageController();
  List<CommonTagItemModel> tagsList = [];
  TabController _tabController;

  @override
  void initState() {
    _tabController = DefaultTabController.of(context);
    _bloc = OtherCookProfileBloc();
    _bloc.event.add(EventModel(OtherCookProfileBloc.GET_PROFILE_EVENT, data: widget.cookId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: DefaultTabController(
        length: 3,
        child: StreamBuilder<ResultModel<UserModel>>(
          stream: _bloc.obsGetUserProfile.stream,
          builder: (context, AsyncSnapshot<ResultModel<UserModel>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data?.data != null){
                cookModel = snapshot.data?.data;

                return BaseFormBodyUnsafe(
                  child: NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
                      return <Widget>[
                        SliverOverlapAbsorber(
                          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                          sliver: SliverSafeArea(top: false,
                            sliver: SliverAppBar(
                              pinned: true,
                              floating: false,
                              elevation: 0,
                              expandedHeight: AppConstants.SLIVER_EXPANDED_HEIGHT,
                              backgroundColor: AppColors.white,
                              flexibleSpace: FlexibleSpaceBar(
                                /*title: Text(cookModel.firstName,
                                style: Theme.of(context).textTheme.headline6.copyWith(color: AppColors.black,),),*/
                                collapseMode: CollapseMode.parallax,
                                background: Stack(
                                  children: [
                                    (((cookModel?.cookImages?.length) ?? 0) == 0)
                                        ? Container(child: Center(child: Text(AppStrings.noMediaAvailable)),)
                                        : PageView.builder(
                                      onPageChanged: (index){
                                        _currentIndex.value = index;
                                      },
                                      scrollDirection: Axis.horizontal,
                                      controller: controller,
                                      itemCount: (cookModel?.cookImages?.length) ?? 0,
                                      itemBuilder: (BuildContext context, int index) {
                                        return _showMediaWidget(index);
                                      },
                                    ),
                                    Positioned(
                                      right: 0,
                                      left: 0,
                                      bottom: 0,
                                      child: ClipRect(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: AppDimensions.blur_radius, sigmaY: AppDimensions.blur_radius),
                                          child: Container(
                                            decoration: BoxDecoration(color: AppColors.transparent.withOpacity(0.0)),
                                            child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5),
                                            child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: ValueListenableProvider<int>.value(value: _currentIndex,
                                              child: Consumer<int>(builder: (context, currentIndex, child){
                                                return Offstage(
                                                  offstage: (cookModel?.cookImages != null && (cookModel?.cookImages?.isEmpty == true)),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 25,
                                                        child: ListView.builder(
                                                          padding: EdgeInsets.only(top: AppDimensions.generalPadding,
                                                              right: AppDimensions.generalPadding),
                                                          scrollDirection: Axis.horizontal,
                                                          shrinkWrap: true,
                                                          itemCount: cookModel?.cookImages ?.length ?? 0,
                                                          itemBuilder: (context, index) {
                                                            return Padding(
                                                              padding: const EdgeInsets.only(right: AppDimensions.generalMinPadding),
                                                              child: Container(
                                                                height: 10,
                                                                width: 10,
                                                                decoration: BoxDecoration(
                                                                  color: (currentIndex == index) ?  Theme.of(context).accentColor : AppColors.backgroundGrey300,
                                                                  shape: BoxShape.circle,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),),
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Container(
                                            height: 20,
                                            decoration: BoxDecoration(
                                            color: AppColors.white,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(AppDimensions.cardRadius),
                                              topRight: Radius.circular(AppDimensions.cardRadius),
                                            ),
                                            ),
                                          ),
                                        ],
                                      ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPersistentHeader(
                          delegate: _SliverAppBarDelegate(
                            TabBar(
                              controller: _tabController,
                              indicatorColor: Theme.of(context).accentColor,
                              indicatorSize: TabBarIndicatorSize.label,
                              labelColor: Theme.of(context).accentColor,
                              indicatorWeight: 4,
                              labelStyle: Theme.of(context).textTheme.subtitle1.apply(
                                  fontWeightDelta: 1,
                                  fontSizeDelta: 1
                              ),
                              unselectedLabelColor: AppColors.black,
                              unselectedLabelStyle: Theme.of(context).textTheme.subtitle2.apply(
                                  fontSizeDelta: 1
                              ),
                              tabs: [
                                Tab(text: AppStrings.aboutLabel,),
                                Tab(text: AppStrings.lessonsLabel,),
                                Tab(text: AppStrings.reviewsLabel,),
                              ],
                            ),
                          ),
                          pinned: true,
                        ),
                      ];
                    },
                    body: TabBarView(children: [
                      SingleChildScrollView(child: aboutWidget(),),
                      SingleChildScrollView(child: OtherCooksLessonsScreen(widget.cookId),),
                      SingleChildScrollView(child: OtherCooksReviewsScreen(widget.cookId),)
                    ]),
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
        ),
      ),
    );
  }

  Widget _showMediaWidget(int index){

    return GestureDetector(onTap: (){
      Navigator.push(context, MaterialPageRoute(builder:
          (context) => MediaPageViewScreen(cookModel.cookImages, index)));
    },
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: _getUrl(index),
        progressIndicatorBuilder: (context,
            url, downloadProgress) =>
            Image.asset(
              "assets/loading_image.png",
            ),
        errorWidget:
            (context, url, error) =>
            Image.asset(
              "assets/error_image.png",
              color: AppColors.grayColor,
            ),
      ),
    );
  }

  Widget aboutWidget(){
    tagsList.clear();
    tagsList = [...cookModel.cooksCuisines, ...cookModel.cooksDiets];
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(cookModel?.firstName ?? "", style: Theme.of(context).textTheme.headline3.apply(
                fontSizeDelta: -2,
              ),)),
              SizedBox(width: 5,),
              Container(
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
                      Text(double.parse(cookModel?.cookRating?.toStringAsFixed(1))?.toString() ?? "0.0", style: Theme.of(context).textTheme.subtitle2,),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          (cookModel.isProfessionalChef) ? Row(
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: Image.asset(
                  "assets/dashboard_cook_profile.png",
                  color: Theme.of(context).accentColor,
                ),
              ),
              SizedBox(width: 5,),
              Text(AppStrings.professionalChef.toUpperCase(), style: Theme.of(context).textTheme.headline5.apply(
                color: Theme.of(context).accentColor,
                fontSizeDelta: -1,
              ),),
            ],
          )
              : Container(),
          SizedBox(height: 10,),
          Text(AppStrings.speciality ?? "", style: Theme.of(context).textTheme.headline6.apply(
            color: AppColors.grayColor,
          ),),
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tagsList.length ?? 0,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Chip(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    backgroundColor: AppColors.backgroundGrey300,
                    label: Text(tagsList[index].name,
                      style: Theme.of(context).textTheme.subtitle2,),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: AppDimensions.maxPadding, bottom: AppDimensions.maxPadding),
            child: Container(
              color: AppColors.black,
              height: 0.2,
            ),
          ),
          Text(AppStrings.aboutCook, style: Theme.of(context).textTheme.headline4.apply(fontSizeDelta: 1),),
          SizedBox(height: 10,),
          Text(cookModel?.aboutMe ?? "",
            style: Theme.of(context).textTheme.subtitle2.apply(fontSizeDelta: 2),
          ),
          SizedBox(height: AppDimensions.generalPadding,),
        ],
      ),
    );
  }

 String  _getUrl(int index){
    if((cookModel?.cookImages?.isNotEmpty ?? false) == true){
      if(cookModel.cookImages[index].fileType == AppConstants.IMAGE){
        return cookModel.cookImages[index].filePath;
      }else{
        return cookModel.cookImages[index].thumbnailPath;
      }
    }else return "";
  }

}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.white,
      child: Stack(children: [
        Positioned(left: 0, bottom: 1, child: Container(color: AppColors.grayColor, height: 0.5, width: MediaQuery.of(context).size.width)),
        _tabBar,
      ],),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
