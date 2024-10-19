
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/details/LessonDetailsBloc.dart';
import 'package:flutter/material.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppStrings.dart';

typedef LessonDetailsCallBack(LessonDetailsModel lessonDetailsModel);

class LessonDetailsBottomSheet{

  static void lessonDetailsSheet(BuildContext context, int lessonId,
      LessonDetailsCallBack onLessonDetailsCallBack,
      {LessonDetailsModel lessonDetailsModel}){
       showModalBottomSheet(
          context: context,
          enableDrag: true,
          isDismissible: true,
          backgroundColor: AppColors.transparent,
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
                    padding: const EdgeInsets.only(left: AppDimensions.generalMinPadding, right: AppDimensions.generalPadding, top: 20, bottom: 20),
                    child: _BottomWidget( lessonId, onLessonDetailsCallBack, lessonDetailsModel: lessonDetailsModel),
                  ),),
              ),
            );
          });
  }
}

class _BottomWidget extends StatefulWidget {

  final int lessonId;
  final LessonDetailsCallBack onLessonDetailsCallBack;
  final LessonDetailsModel lessonDetailsModel;

  _BottomWidget(this.lessonId,
      this.onLessonDetailsCallBack,
      {this.lessonDetailsModel});

  @override
  _BottomWidgetState createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<_BottomWidget> {

  static const int PAGE_SIZE = 0;

  ValueNotifier<String> _errorMessage = ValueNotifier("");
  LessonDetailsBloc _bloc;
  LessonDetailsModel lessonModel;
  List<CommonTagItemModel> tagsList = [];

  @override
  void initState() {
     _bloc = LessonDetailsBloc(PAGE_SIZE);

     if(widget.lessonDetailsModel != null){
       lessonModel = widget.lessonDetailsModel;
       _bloc.obsGetLessonDetails.add(ResultModel(data: lessonModel));
       _bloc.event.add(EventModel(LessonDetailsBloc.GET_LESSON_DETAILS, data: widget.lessonId));
     }else{
     _bloc.event.add(EventModel(LessonDetailsBloc.GET_LESSON_DETAILS, data: widget.lessonId));
     }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<ResultModel<LessonDetailsModel>>(
        stream: _bloc.obsGetLessonDetails.stream,
        builder: (context, AsyncSnapshot<ResultModel<LessonDetailsModel>> snapshot) {
          if(snapshot.hasData){

            if (snapshot.data?.data != null){
              lessonModel = snapshot.data.data;
              widget.onLessonDetailsCallBack(lessonModel);
              tagsList.clear();
              tagsList = [...lessonModel.cuisines, ...lessonModel.diets];

              return Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: AppDimensions.generalPadding, bottom: AppDimensions.generalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(lessonModel?.name ?? "", style: Theme.of(context).textTheme.headline4,)),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      width: 2, color: Theme.of(context).accentColor),
                                  color: Theme.of(context).accentColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Center(
                                    child: Icon(Icons.close, color: AppColors.white, size: 16,),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
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
                  ],
                ),
              );
            }else {

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
          }else if (snapshot.hasError) {

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
          Text(qty, style: Theme.of(context).textTheme.bodyText2,),
        ],
      ),
    );
  }

}