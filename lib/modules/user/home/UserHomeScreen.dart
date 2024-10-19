
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:cooking_app/business/network/ServerConnectionHelper.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/dashboard/HomeNavigationsScreen.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemWidget.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/modules/user/home/TagsModel.dart';
import 'package:cooking_app/modules/user/home/UserHomeBloc.dart';
import 'package:cooking_app/modules/user/lesson/ScreenOpenedFrom.dart';
import 'package:cooking_app/modules/user/lesson/search/SearchLessonScreen.dart';
import 'package:cooking_app/modules/video_chat/CallScreen.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class UserHomeScreen extends StatefulWidget {

  final ChangeWidget onChangeWidget;

  UserHomeScreen(this.onChangeWidget);

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {

  UserHomeBloc _bloc;

  var _searchEdit = new TextEditingController();
  ValueNotifier<bool> _showClearButton = ValueNotifier(false);
  TagsModel _tagsModel;
  CommonTagItemModel selectedCuisine;
  Map<int, CommonTagItemModel> selectedDietsMap;

  @override
  void initState() {
    _bloc = UserHomeBloc();

    selectedDietsMap = {};

    _bloc.event.add(EventModel(UserHomeBloc.GET_TAGS_EVENT));

    super.initState();

  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResultModel<TagsModel>>(
      stream: _bloc.obsGetTagsLists.stream,
      builder: (context, AsyncSnapshot<ResultModel<TagsModel>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data?.data != null){
            _tagsModel = snapshot.data?.data;
            return SingleChildScrollView(
              child: mainContainerWidget(),
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
      },
    );
    //return mainContainerWidget();
  }

  Widget mainContainerWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: AppDimensions.generalPadding,
              bottom: AppDimensions.generalPadding,
              left: AppDimensions.generalPadding,
              right: AppDimensions.generalPadding),
          child: ValueListenableProvider<bool>.value(
            value: _showClearButton,
            child: Consumer<bool>(
              builder: (context, clearIconVisibility, child) {
                return GestureDetector(
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
                  ),
                  onTap: (){
                    widget.onChangeWidget(SearchLessonScreen(cuisines: _tagsModel.cuisines, diets: _tagsModel.diets, searchQuery: "",
                        openedFrom: ScreenOpenedFrom.HOME.index, selectedCuisine: selectedCuisine,
                        selectedDietsMap: selectedDietsMap, onChangeWidget: widget.onChangeWidget));
                  },
                );
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding, left: AppDimensions.generalPadding + 10),
          child: Text(AppStrings.whatYouWantToLearnNote, style: Theme.of(context).textTheme.bodyText2.apply(
            fontStyle: FontStyle.italic,
          ),),
        ),

        Padding(
          padding: const EdgeInsets.only(top: AppDimensions.generalPadding, left: AppDimensions.generalPadding + 10),
          child: Text(AppStrings.cuisine, style: Theme.of(context).textTheme.headline4.apply(
            fontSizeDelta: 2,
          ),),
        ),
        SizedBox(
          height: (MediaQuery.of(context).size.width/2),
          child: ListView.builder(
            padding: EdgeInsets.only(top: AppDimensions.generalPadding, left: AppDimensions.generalPadding,
                right: AppDimensions.generalPadding),
            scrollDirection: Axis.horizontal,
            itemCount: _tagsModel.cuisines.length,
            itemBuilder: (context, index) {
              return CommonTagItemWidget(cuisineModel: _tagsModel.cuisines[index], index: index, cuisines: _tagsModel.cuisines, diets: _tagsModel.diets,
                selectedCuisine: selectedCuisine, selectedDietsMap: selectedDietsMap, isCuisine: true, onChangeWidget: widget.onChangeWidget,);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppDimensions.maxPadding, left: AppDimensions.generalPadding+10),
          child: Text(AppStrings.dietType, style: Theme.of(context).textTheme.headline4.apply(
            fontSizeDelta: 2,
          ),),
        ),
        SizedBox(
          height: (MediaQuery.of(context).size.width/2),
          child: ListView.builder(
            padding: EdgeInsets.only(top: AppDimensions.generalPadding, left: AppDimensions.generalPadding,
                right: AppDimensions.generalPadding),
            scrollDirection: Axis.horizontal,
            itemCount: _tagsModel.diets.length,
            itemBuilder: (context, index) {
              return CommonTagItemWidget(cuisineModel: _tagsModel.diets[index], index: index, cuisines: _tagsModel.cuisines, diets: _tagsModel.diets,
                  selectedCuisine: selectedCuisine, selectedDietsMap: selectedDietsMap, isCuisine: false, onChangeWidget: widget.onChangeWidget,);
            },
          ),
        ),
      ],
    );
  }

}
