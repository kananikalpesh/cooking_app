
import 'dart:async';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/dashboard/HomeNavigationsScreen.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/modules/user/home/UserHomeScreen.dart';
import 'package:cooking_app/modules/user/home/filters/CuisineFilterBottomSheet.dart';
import 'package:cooking_app/modules/user/home/filters/DietaryFilterBottomSheet.dart';
import 'package:cooking_app/modules/user/home/filters/GeneralFilterBottomSheet.dart';
import 'package:cooking_app/modules/user/lesson/ScreenOpenedFrom.dart';
import 'package:cooking_app/modules/user/lesson/result/ResultItemWidget.dart';
import 'package:cooking_app/modules/user/lesson/search/SearchLessonBloc.dart';
import 'package:cooking_app/modules/user/lesson/search/SearchLessonScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatefulWidget {

  final List<CommonTagItemModel> cuisines;
  final List<CommonTagItemModel> diets;
  final String searchQuery;
  final int openedFrom;
  CommonTagItemModel selectedCuisine;
  final Map<int, CommonTagItemModel> selectedDietsMap;
  final ChangeWidget onChangeWidget;

  SearchResultScreen({this.cuisines, this.diets, this.searchQuery, this.openedFrom, this.selectedCuisine,
    this.selectedDietsMap, this.onChangeWidget});

  @override
  _SearchLessonScreenState createState() => _SearchLessonScreenState();
}

class _SearchLessonScreenState extends State<SearchResultScreen> {

  static const PAGE_SIZE = 10;
  SearchLessonBloc _bloc;

  var _searchEdit = new TextEditingController();
  CommonTagItemModel selectedCuisine;
  Map<int, CommonTagItemModel> selectedDietsMap = {};
  int selectedFilter = -1;
  String selectedFilterString = "";

  ValueNotifier<String> cuisineText = ValueNotifier("");
  ValueNotifier<String> dietText = ValueNotifier("");
  ValueNotifier<String> sortByText = ValueNotifier(AppStrings.sortBy);

  StreamSubscription _lessonListSubscription;
  ScrollController _listScrollController;

  @override
  void initState() {
    _bloc = SearchLessonBloc(PAGE_SIZE);

    _searchEdit.text = widget.searchQuery;

    if (widget.selectedCuisine != null) {
      selectedCuisine = widget.selectedCuisine;
      cuisineText.value = selectedCuisine?.name;
    } else {
      cuisineText.value = AppStrings.cuisine;
    }

    if (widget.selectedDietsMap != null && widget.selectedDietsMap.isNotEmpty) {
      selectedDietsMap.addAll(widget.selectedDietsMap);
      if (selectedDietsMap.length == 2){
        var diets = "";
        selectedDietsMap.forEach((key, value) {
          diets += "${value.name}, ";
        });
        dietText.value = diets.substring(0, diets.length-2);
      } else if (selectedDietsMap.length == 1) {
        dietText.value = selectedDietsMap.values.toList().first.name;
      } else if (selectedDietsMap.length > 2) {
        dietText.value = AppStrings.dietary + " (${selectedDietsMap.length})";
      } else {
        dietText.value = AppStrings.dietary;
      }
    } else {
      dietText.value = AppStrings.dietary;
    }

    _listScrollController = ScrollController();
    _listScrollController.addListener(() {
      if (_listScrollController.offset >=
          _listScrollController.position.maxScrollExtent &&
          !_listScrollController.position.outOfRange) {
        if (!_bloc.loadingNextPageData.value) {
          if (_bloc.listSizeOfCurrentFetch >= _bloc.getPageSize) {
            _bloc.loadingNextPageData.value = true;
            _loadNewData();
          }
        }
      }
    });

    _lessonListSubscription = _bloc.obsGetLessonsLists.stream.listen((result) {
      _bloc.setCount = (_bloc.lessonsList.length);
      if (result?.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context, result);
      }
    });

    _loadNewData();

    super.initState();
  }

  @override
  void dispose() {
    if (_lessonListSubscription != null) {
      _lessonListSubscription.cancel();
      _bloc.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: SingleChildScrollView(child: mainContainerWidget(), controller: _listScrollController,),
    );
  }

  Future<bool> _willPop() async{
    if (widget.openedFrom == ScreenOpenedFrom.HOME.index){
      widget.onChangeWidget(UserHomeScreen(widget.onChangeWidget));
    } else if (widget.openedFrom == ScreenOpenedFrom.SEARCH.index){
      widget.onChangeWidget(SearchLessonScreen(cuisines: widget.cuisines, diets: widget.diets, searchQuery: "",
          openedFrom: ScreenOpenedFrom.RESULT.index, onChangeWidget: widget.onChangeWidget));
    }
    return false;
  }

  Widget _getEmptyListWidget() {
    var height = MediaQuery.of(context).size.height/2;
    return Container(
      height: height,
      child: Center(
        child: Text(AppStrings.emptySearchData,
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _getInitialLoaderWidget() {
    var height = MediaQuery.of(context).size.height/2;
    return Container(
      height: height,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget mainContainerWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: AppDimensions.generalPadding,
              bottom: (AppDimensions.maxPadding),
              left: AppDimensions.generalPadding,
              right: AppDimensions.generalPadding),
          child: Row(
            children: [
              GestureDetector(
                child: Icon(Icons.arrow_back, color: AppColors.black, size: 25,),
                onTap: _willPop,),
              SizedBox(width: 10,),
              Expanded(
                child: GestureDetector(
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        enabled: false,
                        controller: _searchEdit,
                        decoration:
                        AppTheme.inputDecorationThemeForSearch(searchHint: AppStrings.homeSearchHint),
                        cursorColor: AppColors.colorAccent,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        height: 46,
                        width: 90,
                        child: IconButton(
                          icon: Icon(Icons.search,
                              color: AppColors.white),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                  onTap: (){
                    widget.onChangeWidget(SearchLessonScreen(cuisines: widget.cuisines, diets: widget.diets, searchQuery: widget.searchQuery,
                        openedFrom: ScreenOpenedFrom.RESULT.index, onChangeWidget: widget.onChangeWidget));
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 36,
          child: Row(mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                    SizedBox(width: AppDimensions.generalPadding,),
                    GestureDetector(
                      child: ValueListenableProvider<String>.value(
                        value: cuisineText,
                        child: Consumer<String>(
                          builder: (context, value, index){
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGrey300,
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: AppDimensions.generalPadding,
                                    top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/dashboard_cuisine.png",
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 8,),
                                    Text(value, style: Theme.of(context).textTheme.caption,),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      onTap: (){
                        bool callAPI = false;
                        CuisineFilterBottomSheet.showFiltersSheet(context, selectedCuisine, widget.cuisines, callback: (bool isCallAPI) async{
                          callAPI = isCallAPI;
                        }).then((value) {
                          if (callAPI) {
                            selectedCuisine = value;
                            _bloc.reloadFromStart();
                            _loadNewData();
                            cuisineText.value =  selectedCuisine?.name ?? AppStrings.cuisine;
                          }
                        });
                      },
                    ),
                    SizedBox(width: AppDimensions.generalPadding,),
                    GestureDetector(
                      child: ValueListenableProvider<String>.value(
                        value: dietText,
                        child: Consumer<String>(
                          builder: (context, value, index){
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGrey300,
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: AppDimensions.generalPadding,
                                    top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/dashboard_diet.png",
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(width: 8,),
                                    Text(value, style: Theme.of(context).textTheme.caption,),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      onTap: (){
                        DietaryFilterBottomSheet.showFiltersSheet(context, selectedDietsMap, widget.diets).then((value) {
                          if (value != null){
                            selectedDietsMap.clear();
                            selectedDietsMap.addAll((value as Map<int, CommonTagItemModel>));
                            _bloc.reloadFromStart();
                            _loadNewData();

                            if (selectedDietsMap != null || selectedDietsMap.isNotEmpty) {
                              if (selectedDietsMap.length == 2){
                                var diets = "";
                                selectedDietsMap.forEach((key, value) {
                                  diets += "${value.name}, ";
                                });
                                dietText.value = diets.substring(0, diets.length-2);
                              } else if (selectedDietsMap.length == 1) {
                                dietText.value = selectedDietsMap.values.toList().first.name;
                              } else if (selectedDietsMap.length > 2) {
                                dietText.value = AppStrings.dietary + " (${selectedDietsMap.length})";
                              } else {
                                dietText.value = AppStrings.dietary;
                              }
                            } else {
                              dietText.value = AppStrings.dietary;
                            }
                          }
                        });
                      },
                    ),
                    SizedBox(width: AppDimensions.generalPadding,),
                    GestureDetector(
                      child: ValueListenableProvider<String>.value(
                        value: sortByText,
                        child: Consumer<String>(
                          builder: (context, value, index){
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundGrey300,
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: AppDimensions.generalPadding,
                                    top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                                child: Row(
                                  children: [
                                    Icon(Icons.sort, size: 20, color: AppColors.black,),
                                    SizedBox(width: 8,),
                                    Text(value, style: Theme.of(context).textTheme.caption,),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      onTap: (){
                        GeneralFilterBottomSheet.showFiltersSheet(context, selectedFilter).then((value) {
                          if(value != null){
                            selectedFilter = value as int;

                            switch(selectedFilter){
                              case -1:
                                selectedFilterString = "";
                                sortByText.value = AppStrings.sortBy;
                                break;
                              case 0:
                                selectedFilterString = "price_asc";
                                sortByText.value = AppStrings.priceLowest;
                                break;
                              case 1:
                                selectedFilterString = "price_desc";
                                sortByText.value = AppStrings.priceHighest;
                                break;
                              case 2:
                                selectedFilterString = "rating_desc";
                                sortByText.value = AppStrings.ratingsHighest;
                                break;
                              case 3:
                                selectedFilterString = "rating_asc";
                                sortByText.value = AppStrings.ratingsLowest;
                                break;
                            }

                            _bloc.reloadFromStart();
                            _loadNewData();
                          }
                        });
                      },
                    ),
                    SizedBox(width: 10,),
                  ],
                ),
              ),
            ],
          ),
        ),
        //SizedBox(height: 10,),
       /* Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              child: ValueListenableProvider<String>.value(
                value: cuisineText,
                child: Consumer<String>(
                  builder: (context, value, index){
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey300,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: AppDimensions.generalPadding,
                            top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/dashboard_cuisine.png",
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 8,),
                            Text(value, style: Theme.of(context).textTheme.caption,),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              onTap: (){
                bool callAPI = false;
                CuisineFilterBottomSheet.showFiltersSheet(context, selectedCuisine, widget.cuisines, callback: (bool isCallAPI) async{
                  callAPI = isCallAPI;
                }).then((value) {
                  if (callAPI) {
                    selectedCuisine = value;
                    _bloc.reloadFromStart();
                    _loadNewData();
                    cuisineText.value =  selectedCuisine?.name ?? AppStrings.cuisine;
                  }
                });
              },
            ),
            SizedBox(width: AppDimensions.generalPadding,),
            GestureDetector(
              child: ValueListenableProvider<String>.value(
                value: dietText,
                child: Consumer<String>(
                  builder: (context, value, index){
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey300,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: AppDimensions.generalPadding,
                            top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/dashboard_diet.png",
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 8,),
                            Text(value, style: Theme.of(context).textTheme.caption,),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              onTap: (){
                DietaryFilterBottomSheet.showFiltersSheet(context, selectedDietsMap, widget.diets).then((value) {
                  if (value != null){
                    selectedDietsMap.clear();
                    selectedDietsMap.addAll((value as Map<int, CommonTagItemModel>));
                    _bloc.reloadFromStart();
                    _loadNewData();

                    if (selectedDietsMap != null || selectedDietsMap.isNotEmpty) {
                      if (selectedDietsMap.length == 2){
                        var diets = "";
                        selectedDietsMap.forEach((key, value) {
                          diets += "${value.name}, ";
                        });
                        dietText.value = diets.substring(0, diets.length-2);
                      } else if (selectedDietsMap.length == 1) {
                        dietText.value = selectedDietsMap.values.toList().first.name;
                      } else if (selectedDietsMap.length > 2) {
                        dietText.value = AppStrings.dietary + " (${selectedDietsMap.length})";
                      } else {
                        dietText.value = AppStrings.dietary;
                      }
                    } else {
                      dietText.value = AppStrings.dietary;
                    }
                  }
                });
              },
            ),
            SizedBox(width: AppDimensions.generalPadding,),
            GestureDetector(
              child: ValueListenableProvider<String>.value(
                value: sortByText,
                child: Consumer<String>(
                  builder: (context, value, index){
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey300,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: AppDimensions.generalPadding,
                            top: AppDimensions.generalMinPadding, bottom: AppDimensions.generalMinPadding),
                        child: Row(
                          children: [
                            Icon(Icons.sort, size: 20, color: AppColors.black,),
                            SizedBox(width: 8,),
                            Text(value, style: Theme.of(context).textTheme.caption,),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              onTap: (){
                GeneralFilterBottomSheet.showFiltersSheet(context, selectedFilter).then((value) {
                  if(value != null){
                    selectedFilter = value as int;

                    switch(selectedFilter){
                      case -1:
                        selectedFilterString = "";
                        sortByText.value = AppStrings.sortBy;
                        break;
                      case 0:
                        selectedFilterString = "price_asc";
                        sortByText.value = AppStrings.priceLowest;
                        break;
                      case 1:
                        selectedFilterString = "price_desc";
                        sortByText.value = AppStrings.priceHighest;
                        break;
                      case 2:
                        selectedFilterString = "rating_desc";
                        sortByText.value = AppStrings.ratingsHighest;
                        break;
                      case 3:
                        selectedFilterString = "rating_asc";
                        sortByText.value = AppStrings.ratingsLowest;
                        break;
                    }

                    _bloc.reloadFromStart();
                    _loadNewData();
                  }
                });
              },
            ),
            SizedBox(width: 10,),
          ],
        ),*/
        SizedBox(height: 5,),
        ValueListenableProvider<bool>.value(
          value: _bloc.isLoadingFirstPage,
          child: Consumer<bool>(
            builder: (context, isLoadingFirstPage, child) {
              return ValueListenableProvider<int>.value(
                value: _bloc.getCount,
                child: Consumer<int>(
                  builder: (context, valueListCount, child) {
                    return (isLoadingFirstPage)
                        ?  _getInitialLoaderWidget()
                        : (valueListCount == 0)
                        ? _getEmptyListWidget()
                        : _getLessonListBuilder(valueListCount);
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(height: AppDimensions.maxPadding,),
      ],
    );
  }

  _loadNewData() {
    var _searchData = <String, dynamic>{
      if(widget.searchQuery.isNotEmpty) "k": widget.searchQuery ?? "",
      "c": selectedCuisine?.id != null ? [selectedCuisine.id] : [],
      "d": selectedDietsMap.keys.toList(),
      if(selectedFilterString.isNotEmpty) "sort": selectedFilterString,
    };

    _bloc.obsGetLessonsLists.sink.add(null);
    _bloc.event
        .add(EventModel(SearchLessonBloc.GET_SEARCH_RESULT_EVENT, data: _searchData));
  }

  Widget _getLessonListBuilder(int valueListCount) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: valueListCount + 1,
        padding: EdgeInsets.only(left: AppDimensions.generalPadding,
            right: AppDimensions.generalPadding),
        itemBuilder: (context, index) {
          if (index == (valueListCount)) {
            return ValueListenableProvider<bool>.value(
              value: _bloc.loadingNextPageData,
              child: Consumer<bool>(
                builder: (context, value, child) {
                  Future.delayed(
                      Duration(
                        milliseconds: 10,
                      ), () {
                    if (value && (index == (valueListCount))) {
                      _listScrollController.jumpTo(
                          _listScrollController.position.maxScrollExtent);
                    }
                  });
                  return Offstage(
                    offstage: (!value),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10,
                          bottom: AppDimensions.generalPadding),
                      child: Center(
                        child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator()),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return ResultItemWidget(lessonModel: _bloc.lessonsList[index], index: index, isFromHomeScreen: true,);
          }
        });
  }

}
