
import 'dart:async';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/dashboard/HomeNavigationsScreen.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/modules/user/home/UserHomeScreen.dart';
import 'package:cooking_app/modules/user/lesson/LessonListModel.dart';
import 'package:cooking_app/modules/user/lesson/ScreenOpenedFrom.dart';
import 'package:cooking_app/modules/user/lesson/result/SearchResultScreen.dart';
import 'package:cooking_app/modules/user/lesson/search/LessonItemWidget.dart';
import 'package:cooking_app/modules/user/lesson/search/SearchLessonBloc.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class SearchLessonScreen extends StatefulWidget {

  final List<CommonTagItemModel> cuisines;
  final List<CommonTagItemModel> diets;
  final String searchQuery;
  final int openedFrom;
  final CommonTagItemModel selectedCuisine;
  final Map<int, CommonTagItemModel> selectedDietsMap;
  final ChangeWidget onChangeWidget;

  SearchLessonScreen(
      {this.cuisines,
      this.diets,
      this.searchQuery,
      this.openedFrom,
      this.selectedCuisine,
      this.selectedDietsMap, this.onChangeWidget});

  @override
  _SearchLessonScreenState createState() => _SearchLessonScreenState();
}

class _SearchLessonScreenState extends State<SearchLessonScreen> {

  static const PAGE_SIZE = 7;
  SearchLessonBloc _bloc;

  var _searchEdit = new TextEditingController();
  String _searchQuery = "";
  String _previousQuery = "";
  FocusNode _focusNode;
  ValueNotifier<bool> _showClearButton = ValueNotifier(false);
  CommonTagItemModel selectedCuisine;
  Map<int, CommonTagItemModel> selectedDietsMap = {};

  List<CommonTagItemModel> filteredCuisineList;
  List<CommonTagItemModel> filteredDietList;

  StreamSubscription _lessonListSubscription;
  ScrollController _listScrollController;

  @override
  void initState() {
    _bloc = SearchLessonBloc(PAGE_SIZE);
    _focusNode = FocusNode();

    selectedCuisine = widget.selectedCuisine;
    if (widget.selectedDietsMap != null) selectedDietsMap.addAll(widget.selectedDietsMap);
    filteredCuisineList = widget.cuisines;
    filteredDietList = widget.diets;
    _searchEdit.text = widget.searchQuery;

    _listScrollController = ScrollController();
    /*_listScrollController.addListener(() {
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
    });*/

    _lessonListSubscription = _bloc.obsGetLessonsLists.stream.listen((result) {
      _bloc.setCount = (_bloc.lessonsList.length);
      /*if (result?.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context, result);
      }*/
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _searchEdit.addListener(_textListener);
      } else {
        _searchEdit.removeListener(_textListener);
      }
    });

    if (_searchEdit.text.isEmpty){
      _bloc.obsGetLessonsLists.add(ResultModel(data: LessonListModel(lessons: [])));
    }

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (_lessonListSubscription != null) {
      _lessonListSubscription.cancel();
      _bloc.dispose();
    }
    super.dispose();
  }

  _loadNewData() {
    var _searchData = <String, dynamic>{
      "k": _searchEdit.text.toString(),
      "c": selectedCuisine?.id != null ? [selectedCuisine.id] : [],
      "d": selectedDietsMap.keys.toList(),
    };
    _bloc.obsGetLessonsLists.sink.add(null);
    _bloc.event
        .add(EventModel(SearchLessonBloc.GET_SEARCH_RESULT_EVENT, data: _searchData));
  }

  _textListener() {

    _searchQuery = _searchEdit.text;
    /*var _searchData = <String, dynamic>{
      "k": _searchEdit.text.toString(),
      "c": selectedCuisinesMap.keys.toList(),
      "d": selectedDietsMap.keys.toList(),
    };*/

    if (_searchQuery.isEmpty) {
      _previousQuery = "";
      _showClearButton.value = false;
      filteredCuisineList = widget.cuisines;
      filteredDietList = widget.diets;
      _bloc.reloadFromStart();
      setState(() {});
    } else {
      _showClearButton.value = true;
      filteredCuisineList = widget.cuisines.where((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      filteredDietList = widget.diets.where((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      setState(() {});
      if ((_searchQuery.compareTo(_previousQuery) != 0)){
        _previousQuery = _searchQuery;
        _bloc.reloadFromStart();
        _loadNewData();
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPop,
      child: SingleChildScrollView(child: mainContainerWidget(), controller: _listScrollController,),
    );
  }

  Future<bool> _willPop() async{
    widget.onChangeWidget(UserHomeScreen(widget.onChangeWidget));
    return false;
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
              SizedBox(width: AppDimensions.generalPadding,),
              Expanded(
                child: ValueListenableProvider<bool>.value(
                  value: _showClearButton,
                  child: Consumer<bool>(
                    builder: (context, clearIconVisibility, child) {
                      return Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextField(
                            controller: _searchEdit,
                            decoration:
                            AppTheme.inputDecorationThemeForSearch(searchHint: AppStrings.homeSearchHint),
                            focusNode: _focusNode,
                            cursorColor: Theme.of(context).accentColor,
                            autofocus: true,
                          ),
                          Offstage(
                            offstage: (!clearIconVisibility),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                              ),
                              height: 46,
                              width: 90,
                              child: IconButton(
                                onPressed: () {
                                  _showClearButton.value = false;
                                  _searchEdit.text = "";
                                  _focusNode.unfocus();
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          Offstage(
                              offstage: (clearIconVisibility),
                              child: Container(
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
                              ))
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Offstage(
          offstage: (_searchQuery.isEmpty || filteredCuisineList.isEmpty),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey300,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
              child: Row(
                children: [
                  Expanded(child: Text(AppStrings.cuisine, style: Theme.of(context).textTheme.subtitle1,)),
                ],
              ),
            ),
          ),
        ),
        Offstage(
          offstage: (_searchQuery.isEmpty || filteredCuisineList.isEmpty),
          child: ListView.builder(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.only(top: 5,),
              itemCount: filteredCuisineList.length,
              itemBuilder: (context, index) {
                var _model = filteredCuisineList[index];
                return GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10,),
                    child: Column(
                      children: [
                        Row(children: [
                          SizedBox(width: 10,),
                          Icon(Icons.search, color: AppColors.grayColor, size: 20,),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Text(_model.name,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ],),
                        SizedBox(height: 10,),
                        Offstage(offstage: (index == filteredCuisineList.length -1), child: Divider(height: 1,)),
                        SizedBox(height: 5,)
                      ],
                    ),
                  ),
                  onTap: (){
                    _model.isSelected = true;
                    selectedCuisine = _model;
                    widget.onChangeWidget(SearchResultScreen(cuisines: widget.cuisines, diets: widget.diets, searchQuery: "",
                        openedFrom: ScreenOpenedFrom.SEARCH.index, selectedCuisine: selectedCuisine,
                        onChangeWidget: widget.onChangeWidget,));
                  },
                );
              }),
        ),
        Offstage(
          offstage: (_searchQuery.isEmpty || filteredDietList.isEmpty),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey300,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
              child: Row(
                children: [
                  Expanded(child: Text(AppStrings.dietType, style: Theme.of(context).textTheme.subtitle1,)),
                ],
              ),
            ),
          ),
        ),
        Offstage(
          offstage: (_searchQuery.isEmpty || filteredDietList.isEmpty),
          child: ListView.builder(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.only(top: 5,),
              itemCount: filteredDietList.length,
              itemBuilder: (context, index) {
                var _model = filteredDietList[index];
                return GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10,),
                    child: Column(
                      children: [
                        Row(children: [
                          SizedBox(width: 10,),
                          Icon(Icons.search, color: AppColors.grayColor, size: 20,),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Text(_model.name,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ],),
                        SizedBox(height: 10,),
                        Offstage(offstage: (index == filteredDietList.length -1), child: Divider(height: 1,)),
                        SizedBox(height: 5,)
                      ],
                    ),
                  ),
                  onTap: (){
                    widget.selectedDietsMap.clear();
                    _model.isSelected = true;
                    widget.selectedDietsMap.putIfAbsent(_model.id, () => _model);
                    widget.onChangeWidget(SearchResultScreen(cuisines: widget.cuisines, diets: widget.diets, searchQuery: "",
                        openedFrom: ScreenOpenedFrom.SEARCH.index,
                        selectedDietsMap: widget.selectedDietsMap, onChangeWidget: widget.onChangeWidget,));
                  },
                );
              }),
        ),
        ValueListenableProvider<bool>.value(
          value: _bloc.isLoadingFirstPage,
          child: Consumer<bool>(
            builder: (context, isLoadingFirstPage, child) {
              return ValueListenableProvider<int>.value(
                value: _bloc.getCount,
                child: Consumer<int>(
                  builder: (context, valueListCount, child) {
                    return (isLoadingFirstPage)
                        ? Center(child: CircularProgressIndicator())
                        : (valueListCount == 0 && filteredCuisineList.isEmpty && filteredDietList.isEmpty)
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

  Widget _getLessonListBuilder(int valueListCount) {
    return Column(
      children: [
        Offstage(
          offstage: (_searchQuery.isEmpty),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey300,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
              child: Row(
                children: [
                  Expanded(child: Text(AppStrings.lessonTitle, style: Theme.of(context).textTheme.subtitle1,)),
                  GestureDetector(
                    child: Text(AppStrings.seeAll,
                      style: Theme.of(context).textTheme.subtitle2.apply(fontWeightDelta: 3,
                          color: Theme.of(context).accentColor),),
                    onTap: (){
                      widget.onChangeWidget(SearchResultScreen(cuisines: widget.cuisines, diets: widget.diets, searchQuery: _searchQuery,
                        openedFrom: ScreenOpenedFrom.SEARCH.index, selectedCuisine: widget.selectedCuisine,
                        selectedDietsMap: widget.selectedDietsMap, onChangeWidget: widget.onChangeWidget,));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        ListView.builder(
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
                return LessonItemWidget(lessonModel: _bloc.lessonsList[index],
                  index: index, onChangeWidget: widget.onChangeWidget,);
              }
            }),
      ],
    );
  }

}
