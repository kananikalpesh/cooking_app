import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/common/gallery/MediaPageViewScreen.dart';
import 'package:cooking_app/modules/common/widgets/CustomImageShapeWidget.dart';
import 'package:cooking_app/modules/cook/profile/other_user/OtherCookProfileScreen.dart';
import 'package:cooking_app/modules/review/lesson_review/LessonReviewsScreen.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonListModel.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/BookLessonScreen.dart';
import 'package:cooking_app/modules/user/lesson/details/BookingStatusModel.dart';
import 'package:cooking_app/modules/user/lesson/details/bottom_actionable_widget/ActionableWidget.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsBloc.dart';
import 'package:cooking_app/modules/user/lesson/details/OtherLessonItemWidget.dart';
import 'package:cooking_app/modules/user/lesson/details/other_lessons/OtherLessonsScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:cooking_app/utils/CalculationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class LessonDetailsScreen extends StatefulWidget {
  final int id;
  final int cookId;
  final bool isFromCook;
  final int lessonBookingId;

  LessonDetailsScreen({this.id, this.cookId, this.isFromCook, this.lessonBookingId});

  @override
  _LessonDetailsScreenState createState() => _LessonDetailsScreenState();
}

class _LessonDetailsScreenState extends State<LessonDetailsScreen> {
  static const PAGE_SIZE = 7;
  static const PAGE_VIEWER_LENGTH = 3;

  LessonDetailsBloc _bloc;
  LessonDetailsModel lessonModel;
  final PageController controller = new PageController();
  ValueNotifier<int> _currentIndex = ValueNotifier(0);
  List<CommonTagItemModel> tagsList = [];
  ValueNotifier<bool> _hideBuyButton = ValueNotifier(false);

  @override
  void initState() {
    _bloc = LessonDetailsBloc(PAGE_SIZE);

    _bloc.obsGetBookingDetails.stream.listen((resultModel) {
      if(resultModel != null){
        if(resultModel.error != null){
          _hideBuyButton.value = false;
        } else {
          _hideBuyButton.value = true;
        }
      }
    });

    _bloc.event.add(EventModel(LessonDetailsBloc.GET_LESSON_DETAILS, data: widget.id));

    var _lessonData = <String, dynamic>{
      "l": widget.id,
    };
    if(widget.lessonBookingId != null || widget.lessonBookingId != -1 || widget.lessonBookingId != 0){
      _lessonData.putIfAbsent("lb", () => widget.lessonBookingId);
    }
    _bloc.event.add(EventModel(LessonDetailsBloc.GET_BOOKING_DETAILS, data: _lessonData));

    var _otherLessonsData = <String, dynamic>{
      "c": [widget.cookId],
    };
    _bloc.event.add(EventModel(LessonDetailsBloc.GET_OTHER_LESSONS_EVENT, data: _otherLessonsData));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<ResultModel<LessonDetailsModel>>(
        stream: _bloc.obsGetLessonDetails.stream,
        builder: (context, AsyncSnapshot<ResultModel<LessonDetailsModel>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data?.data != null){
              lessonModel = snapshot.data?.data;
              return BaseFormBodyUnsafe(
                child: NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
                    return <Widget>[
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                        sliver: SliverSafeArea(top: false,
                          sliver: SliverAppBar(
                            //title: Text(lessonModel.name, style: Theme.of(context).textTheme.headline6.copyWith(color: AppColors.black, fontFamily: 'Custom', fontWeight: FontWeight.w600),),
                            pinned: true,
                            floating: false,
                            snap: false,
                            elevation: 0,
                            expandedHeight: AppConstants.SLIVER_EXPANDED_HEIGHT,
                            backgroundColor: AppColors.white,
                            flexibleSpace: FlexibleSpaceBar(
                              /*title: Text(lessonModel.name,
                              style: Theme.of(context).textTheme.headline6.copyWith(color: AppColors.black,),),*/
                              collapseMode: CollapseMode.parallax,
                              background: Stack(
                                children: [
                                  PageView.builder(
                                    onPageChanged: (index){
                                      _currentIndex.value = index;
                                    },
                                    scrollDirection: Axis.horizontal,
                                    controller: controller,
                                    itemCount: (lessonModel?.lessonImages != null && (lessonModel?.lessonImages?.isNotEmpty == true))
                                        ? ((lessonModel.lessonImages.length > PAGE_VIEWER_LENGTH) ? PAGE_VIEWER_LENGTH : lessonModel.lessonImages.length) : 0,
                                    itemBuilder: (BuildContext context, int index) {
                                      return _imageWidget(index);
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
                                        Row(
                                          children: [
                                          SizedBox(width: AppDimensions.generalPadding,),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).accentColor,
                                                borderRadius: BorderRadius.all(Radius.circular(50)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 20, right: 20,
                                                    top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.monetization_on_outlined, color: AppColors.white, size: 20,),
                                                    SizedBox(width: 2,),
                                                    Text(AppStrings.dollar + lessonModel.amount.toString() + AppStrings.usd,
                                                      style: Theme.of(context).textTheme.bodyText2.apply(
                                                        color: AppColors.white, fontWeightDelta: 2,
                                                      ), textScaleFactor: 1.0,),
                                                    SizedBox(width: AppDimensions.generalPadding,),
                                                    Icon(Icons.access_time_outlined, color: AppColors.white, size: 20,),
                                                    SizedBox(width: 2,),
                                                    Text((lessonModel.duration != null)
                                                        ? CalculationUtils.calculateHours(lessonModel.duration) : "0" + AppStrings.hour,
                                                      style: Theme.of(context).textTheme.bodyText2.apply(color: AppColors.white), textScaleFactor: 1.0,),
                                                    SizedBox(width: 10,),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: AppDimensions.generalPadding,),
                                          ValueListenableProvider<bool>.value(
                                            value: _hideBuyButton,
                                            child: Consumer<bool>(
                                              builder: (context, _shouldHide, child){
                                                return Offstage(
                                                  offstage: widget.isFromCook || (_shouldHide),
                                                  child: GestureDetector(
                                                    onTap: (){
                                                      Navigator.of(context)
                                                          .push(MaterialPageRoute(
                                                          builder: (context) => BookLessonScreen(lessonModel: lessonModel,)));
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: AppColors.white,
                                                        borderRadius: BorderRadius.all(Radius.circular(50)),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 20, right: 20,
                                                            top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                                                        child: Text(AppStrings.buy.toUpperCase(),
                                                          style: Theme.of(context).textTheme.subtitle1.apply(color: Theme.of(context).accentColor), textScaleFactor: 1.0,),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Offstage(
                                            offstage: widget.isFromCook,
                                            child: SizedBox(width: AppDimensions.generalPadding,),),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: ValueListenableProvider<int>.value(value: _currentIndex,
                                            child: Consumer<int>(builder: (context, currentIndex, child){
                                              return Offstage(
                                                offstage: (lessonModel?.lessonImages != null && (lessonModel?.lessonImages?.isEmpty == true)),
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
                                                        itemCount: lessonModel?.lessonImages?.length ?? 0,
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
                                          height: 60,
                                          decoration: BoxDecoration(
                                          color: AppColors.white,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(AppDimensions.cardRadius),
                                            topRight: Radius.circular(AppDimensions.cardRadius),
                                          ),
                                          ),
                                          child: Column(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  SizedBox(width: AppDimensions.maxPadding,),
                                                  CustomImageShapeWidget(
                                                    45,
                                                    45,
                                                    45 / 2,
                                                    CachedNetworkImage(
                                                      key: GlobalKey(),
                                                      width: 45,
                                                      height: 45,
                                                      fit: BoxFit.fill,
                                                      imageUrl: (lessonModel?.creatorModel?.userImage != null) ? lessonModel?.creatorModel?.userImage : "",
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
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: (){
                                                        if(AppData.user.role == AppConstants.ROLE_USER){
                                                          Navigator.of(context)
                                                              .push(MaterialPageRoute(
                                                              builder: (context) => OtherCookProfileScreen(cookId: lessonModel.creatorModel.id,)));
                                                        }

                                                      },
                                                      child: Text(lessonModel.creatorModel?.firstName ?? "",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle1,),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: AppDimensions.generalPadding,),
                                                  GestureDetector(
                                                    onTap: (){
                                                      Navigator.of(context)
                                                          .push(MaterialPageRoute(
                                                          builder: (context) => LessonReviewsScreen(lessonModel.id, lessonModel.name)));
                                                    },
                                                    child: RatingBarIndicator(
                                                      rating: lessonModel?.lessonRatings ?? 0.0,
                                                      itemBuilder: (context, index) => Icon(
                                                        Icons.star,
                                                        color: AppColors.starRating,
                                                      ),
                                                      itemCount: 5,
                                                      itemSize: 20.0,
                                                      unratedColor: AppColors.nonSelectedStarRating,
                                                      direction: Axis.horizontal,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: AppDimensions.maxPadding,),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              color: AppColors.black,
                                              height: 0.5,
                                            ),
                                          ],
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
                      )
                    ];
                  },
                  body: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: mainContainerWidget(),
                        ),
                      ),
                      StreamBuilder(
                          stream: _bloc.obsGetBookingDetails.stream,
                          builder: (BuildContext context, AsyncSnapshot<ResultModel<BookingStatusModel>> snapshot) {
                            if(snapshot.hasData){
                              return ActionableWidget(isFromCook: widget.isFromCook, bookingStatusModel: snapshot.data?.data,
                                lessonDetailsModel: lessonModel,);
                            } else if (snapshot.hasError){
                              return Container();
                            }
                            return Padding(
                              padding: const EdgeInsets.all(AppDimensions.generalPadding),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [CircularProgressIndicator()],
                              ),
                            );
                          }
                      ),
                    ],
                  ),
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
    );
  }

  Widget _imageWidget(int index){
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder:
            (context) => MediaPageViewScreen(lessonModel.lessonImages, index)));
      },
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: (lessonModel?.lessonImages != null && (lessonModel?.lessonImages?.isNotEmpty == true))
            ? lessonModel.lessonImages[index].filePath : "",
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

  Widget mainContainerWidget(){
    tagsList.clear();
    tagsList = [...lessonModel.cuisines, ...lessonModel.diets];
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: AppDimensions.generalPadding, bottom: AppDimensions.generalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lessonModel?.name ?? "", style: Theme.of(context).textTheme.headline4,),
          SizedBox(height: 10,),
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
                    backgroundColor: Theme.of(context).accentColor,
                    label: Text(tagsList[index].name,
                      style: Theme.of(context).textTheme.subtitle2.apply(
                        color: AppColors.white,
                      ),),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppDimensions.generalPadding,),
          Text(lessonModel?.description ?? "-",
            style: Theme.of(context).textTheme.subtitle2.apply(fontSizeDelta: 1),
          ),
          SizedBox(height: 20,),
          Text(AppStrings.recipeList, style: Theme.of(context).textTheme.headline5.apply(
            color: Theme.of(context).accentColor,
          ),),
          SizedBox(height: 5,),
          Text(AppStrings.recipeNote,
            style: Theme.of(context).textTheme.bodyText2.apply(
              fontStyle: FontStyle.italic
            ),),
          ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: lessonModel?.recipes?.length ?? 0,
              padding: EdgeInsets.only(top: 0),
              itemBuilder: (context, index) {
                var _model = lessonModel.recipes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Card(
                    elevation: 2,
                    child: ExpansionTile(
                      childrenPadding: EdgeInsets.only(top: 10, left: AppDimensions.generalPadding, right: AppDimensions.generalPadding,),
                      title: Text(_model?.name ?? "", style: Theme.of(context).textTheme.headline6.apply(fontWeightDelta: 2),),
                      subtitle: Text(_model?.instruction ?? "", style: Theme.of(context).textTheme.bodyText2,),
                      backgroundColor: AppColors.white,
                      children: ingredientList(index),
                    ),
                  ),
                );
              },
          ),
          SizedBox(height: AppDimensions.generalPadding,),
          Offstage(
            offstage: widget.isFromCook,
            child: StreamBuilder(
                stream: _bloc.obsGetLessonsLists.stream,
                builder: (BuildContext context, AsyncSnapshot<ResultModel<LessonListModel>> snapshot) {
                  if(snapshot.hasData){
                    return Offstage(
                      offstage: ((snapshot.data?.data?.lessons?.length ?? 0) == 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(AppStrings.otherLessons,
                                style: Theme.of(context).textTheme.headline4,),),
                              SizedBox(width: 10,),
                              GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.sectionTitleColor),
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10, right: AppDimensions.generalPadding,
                                        top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                                    child: Text(AppStrings.viewAll, style: Theme.of(context).textTheme.bodyText1.apply(
                                      color: Theme.of(context).accentColor
                                    ),),
                                  ),
                                ),
                                onTap: (){
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                      builder: (context) => OtherLessonsScreen(cookId: widget.cookId,)));
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: (MediaQuery.of(context).size.width/2),
                            child: ListView.builder(
                              padding: EdgeInsets.only(top: AppDimensions.generalPadding,
                                  right: AppDimensions.generalPadding),
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data?.data?.lessons?.length ?? 0,
                              itemBuilder: (context, index) {
                                return OtherLessonItemWidget(lessonModel: snapshot.data?.data?.lessons[index], index: index,);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError){
                    return Center(child: Text(snapshot.error,
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.center,
                    ),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                }
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> ingredientList(int recipeIndex) {
    List<Widget> widgetList = [];

    if(lessonModel.recipes[recipeIndex].ingredients != null && lessonModel.recipes[recipeIndex].ingredients.isNotEmpty) {
      lessonModel.recipes[recipeIndex].ingredients.asMap().forEach((index, model) {
        widgetList.add(ingredientCell(model.ingredient, model.quantity));
      });
    }

    return widgetList;
  }

  Widget ingredientCell(String ingredient, String qty){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(ingredient, style: Theme.of(context).textTheme.subtitle2.apply(fontWeightDelta: 1),)),
          SizedBox(width: 10,),
          Expanded(child: Text(qty, style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

}
