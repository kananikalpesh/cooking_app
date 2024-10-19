import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/custom_objects/AttachmentModel.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/common/bottom_sheets/DurationPickerBottomSheet.dart';
import 'package:cooking_app/modules/common/bottom_sheets/PickFileOptionBottomSheet.dart';
import 'package:cooking_app/modules/common/gallery/MediaPageViewScreen.dart';
import 'package:cooking_app/modules/cook/lesson/create_lesson/CreateLessonBloc.dart';
import 'package:cooking_app/modules/cook/lesson/create_lesson/CreateRecipeScreen.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/modules/user/home/TagsModel.dart';
import 'package:cooking_app/modules/user/home/filters/CuisineMultiSelectBottomSheet.dart';
import 'package:cooking_app/modules/user/home/filters/DietaryFilterBottomSheet.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateLessonScreen extends StatefulWidget {

  final LessonDetailsModel lessonDetailsModel;

  CreateLessonScreen({this.lessonDetailsModel});

  @override
  State<StatefulWidget> createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {

  final _formKey = GlobalKey<FormState>();

  String _lessonName;
  String _lessonDescription;
  int _selectedDurationInMinutes;
  String _price;

  FocusNode _focusLessonName;
  FocusNode _focusLessonDescription;
  FocusNode _focusDuration;
  FocusNode _focusPrice;

  var _lessonNameController = new TextEditingController();
  var _lessonDescriptionController = new TextEditingController();
  var _durationController = new TextEditingController();
  var _lessonPriceController = new TextEditingController();

  TagsModel _tagsModel;
  CommonTagItemModel selectedCuisine;
  Map<int, CommonTagItemModel> selectedDietsMap;
  Map<int, CommonTagItemModel> selectedCuisineMap;
  ValueNotifier<String> cuisineText = ValueNotifier(AppStrings.cuisine);
  ValueNotifier<int> cuisineCount = ValueNotifier(0);
  ValueNotifier<String> dietText = ValueNotifier(AppStrings.dietary);
  ValueNotifier<int> dietCount = ValueNotifier(0);
  final ImagePicker _picker = ImagePicker();
  List<File> selectedImageList = <File>[];
  List<AttachmentModel> _lessonImagesList = <AttachmentModel>[];
  ValueNotifier<int> imageCount = ValueNotifier(0);
  List<RecipeModel> recipeList = <RecipeModel>[];
  ValueNotifier<int> recipeListCount = ValueNotifier(0);
  ValueNotifier<String> errorMessage = ValueNotifier("");

  CreateLessonBloc _bloc;
  ValueNotifier<int> imageProcessingIndex = ValueNotifier(-1);

  StreamSubscription subscriberTagList;
  StreamSubscription subscriberCreateLesson;
  StreamSubscription subscriberupdateLesson;
  StreamSubscription subscriberuploadLessonImage;
  StreamSubscription subscriberDeleteLessonImage;

  @override
  void initState() {

     _focusLessonName = FocusNode();
     _focusLessonDescription = FocusNode();
     _focusDuration = FocusNode();
     _focusPrice = FocusNode();

    _bloc = CreateLessonBloc(lessonId: widget.lessonDetailsModel?.id ?? -1);
    selectedDietsMap = {};
    selectedCuisineMap = {};

    _bloc.event.add(EventModel(CreateLessonBloc.GET_TAGS_EVENT));
    subscriberTagList = _bloc.obsGetTagsLists.stream.listen((resultModel) {
      if(resultModel.error != null){
        CommonBottomSheet.showErrorBottomSheet(context, resultModel);
      }else{
        _tagsModel = resultModel.data;
      }
    });

    subscriberCreateLesson = _bloc.obsCreateLesson.stream.listen((resultModel) {
      if(resultModel.error != null){
        CommonBottomSheet.showErrorBottomSheet(context, resultModel);
      }else{
        CommonBottomSheet.showSuccessWithTimerBottomSheet(context, AppStrings.lessonCreationSuccessTitle,
            AppStrings.lessonCreationSuccessDesc);
        Future.delayed(Duration(seconds: 6),() async {
          Navigator.of(context).pop(true);
        });
      }
    });

    subscriberupdateLesson =  _bloc.obsUpdateLesson.stream.listen((resultModel) {
      if(resultModel.error != null){
        CommonBottomSheet.showErrorBottomSheet(context, resultModel);
      }else{
        CommonBottomSheet.showSuccessWithTimerBottomSheet(context, (widget.lessonDetailsModel != null)
            ? AppStrings.lessonUpdateSuccessTitle
            : AppStrings.lessonCreationSuccessTitle,
            (widget.lessonDetailsModel != null) ? AppStrings.lessonUpdateSuccessDesc
                : AppStrings.lessonCreationSuccessDesc);
        Future.delayed(Duration(seconds: 6),() async {
          Navigator.of(context).pop(true);
        });
      }
    });

    subscriberuploadLessonImage = _bloc.obsUploadLessonImage.listen((resultModel) {
      if(resultModel.error != null){
        imageProcessingIndex.value = -1;
        CommonBottomSheet.showErrorBottomSheet(context, resultModel);
      }else{
        _lessonImagesList.removeAt(imageProcessingIndex.value);
        _lessonImagesList.insert(imageProcessingIndex.value, resultModel.data);
        imageProcessingIndex.value = -1;
        setState(() {});
        }
    });

    subscriberDeleteLessonImage =  _bloc.obsDeleteLessonImage.listen((resultModel) {
      if(resultModel.error != null){
        imageProcessingIndex.value = -1;
        CommonBottomSheet.showErrorBottomSheet(context, resultModel);
      }else{
        _lessonImagesList.removeAt(imageProcessingIndex.value);
        imageProcessingIndex.value = -1;
        imageCount.value = _lessonImagesList.length ?? 0;
      }
    });

    if(widget.lessonDetailsModel != null){
      _lessonImagesList.addAll(widget.lessonDetailsModel.lessonImages);
      imageCount.value = _lessonImagesList.length;
      _lessonNameController.text = widget.lessonDetailsModel.name;
      _lessonDescriptionController.text = widget.lessonDetailsModel.description;
      _lessonPriceController.text = "${widget.lessonDetailsModel.amount}";
      _selectedDurationInMinutes = widget.lessonDetailsModel.duration;

      if(_selectedDurationInMinutes != null){
        var hour = (_selectedDurationInMinutes/60).floor();
        double hoursDecimal = (_selectedDurationInMinutes/60) - hour;
        var minute = (hoursDecimal * 60).floor();
        _durationController.text = "$hour h $minute min";
      }

      recipeList.addAll(widget.lessonDetailsModel.recipes);
      recipeListCount.value = recipeList?.length ?? 0;

      if (widget.lessonDetailsModel.cuisines != null && widget.lessonDetailsModel.cuisines.isNotEmpty) {
        widget.lessonDetailsModel.cuisines.forEach((element) {
          element.isSelected = true;
        });
        selectedCuisineMap = Map.fromIterable(widget.lessonDetailsModel.cuisines,
            key: (k) => k.id, value: (v) => v);
       /* if (selectedCuisineMap.length == 2){
          var cuisine = "";
          selectedCuisineMap.forEach((key, value) {
            cuisine += "${value.name}, ";
          });
          cuisineText.value = cuisine.substring(0, cuisine.length-2);
        } else*/ if (selectedCuisineMap.length == 1) {
          cuisineText.value = selectedCuisineMap.values.toList().first.name;
        } else if (selectedCuisineMap.length > 1) {
          cuisineText.value = "${selectedCuisineMap.values.toList().first.name}";
        } else {
          cuisineText.value = AppStrings.cuisine;
        }
      } else {
        cuisineText.value = AppStrings.cuisine;
      }

      cuisineCount.value = (selectedCuisineMap?.length ?? 0) - 1;

      selectedDietsMap = Map.fromIterable(widget.lessonDetailsModel.diets, key: (k) => k.id, value: (v) => v);

      if (widget.lessonDetailsModel.diets != null && widget.lessonDetailsModel.diets.isNotEmpty) {
        widget.lessonDetailsModel.diets.forEach((element) {
          element.isSelected = true;
        });
        selectedDietsMap = Map.fromIterable(widget.lessonDetailsModel.diets,
            key: (k) => k.id, value: (v) => v);
        /*if (selectedDietsMap.length == 2){
          var diets = "";
          selectedDietsMap.forEach((key, value) {
            diets += "${value.name}, ";
          });
          dietText.value = diets.substring(0, diets.length-2);
        } else*/ if (selectedDietsMap.length == 1) {
          dietText.value = selectedDietsMap.values.toList().first.name;
        } else if (selectedDietsMap.length > 1) {
          dietText.value = "${selectedDietsMap.values.toList().first.name}";
        } else {
          dietText.value = AppStrings.dietary;
        }
      } else {
        dietText.value = AppStrings.dietary;
      }

     dietCount.value = (selectedDietsMap?.length ?? 0) - 1;

    }

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.white,
      appBar: AppBar(title: Text((widget.lessonDetailsModel != null) ?AppStrings.editLesson  : AppStrings.createLesson)),
      body: BaseFormBodyUnsafe(
        child: SingleChildScrollView(
          child: Form(key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding,
                  bottom: AppDimensions.generalPadding),
              child: Column(
                children: [
                  ///Image : SelectImageButton and Show Upload Image List
                  Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: Text(AppStrings.lessonImages, style: Theme.of(context).textTheme.headline5,)),
                        IconButton(icon: Icon(Icons.add_circle, color: AppColors.colorAccent, size: 30,), onPressed: (){

                          if(widget.lessonDetailsModel != null && imageProcessingIndex.value != -1){
                            return;
                          }
                          PickFileOptionBottomSheet.showPickFileBottomSheet(
                              context, (int option) async {
                            if (option == FROM_GALLERY) {
                              ImagePicker()
                                  .getImage(source: ImageSource.gallery)
                                  .then((value) async {
                                if (value != null) {
                                  File renamedFile = await ValidationUtils
                                      .getFileFromNewFileName(
                                      File(value.path),
                                      isImage: true);

                                  if(widget.lessonDetailsModel != null){
                                    _lessonImagesList.insert(0, AttachmentModel(localFile: renamedFile));
                                    imageCount.value = _lessonImagesList.length;
                                    _bloc.event.add(EventModel(CreateLessonBloc.UPLOAD_LESSON_IMAGE_EVENT, data: renamedFile));
                                    imageProcessingIndex.value = 0;
                                  }else{
                                    selectedImageList.insert(0, renamedFile);
                                    imageCount.value = selectedImageList.length;
                                  }
                                }
                              });
                            } else {
                              PickedFile pickedFile = await _picker.getImage(
                                  source: ImageSource.camera);
                              if (pickedFile != null) {
                                File renamedFile = await ValidationUtils
                                    .getFileFromNewFileName(
                                    File(pickedFile.path),
                                    isImage: true);

                                if(widget.lessonDetailsModel != null){
                                  _lessonImagesList.insert(0, AttachmentModel(localFile: renamedFile));
                                  imageCount.value = _lessonImagesList.length;
                                  _bloc.event.add(EventModel(CreateLessonBloc.UPLOAD_LESSON_IMAGE_EVENT, data: renamedFile));
                                  imageProcessingIndex.value = 0;
                                }else{
                                  selectedImageList.insert(0, renamedFile);
                                  imageCount.value = selectedImageList.length;
                                }

                              }
                            }

                          });

                        })
                      ],),
                  ),

                  (widget.lessonDetailsModel != null) ? mediaListView() :
                  ValueListenableProvider<int>.value(value: imageCount,
                  child: Consumer<int>(builder: (context, count, child){
                    return ((count ?? 0) == 0) ? Container()
                        : Container(height: MediaQuery.of(context).size.width/1.6,
                            child: PageView.builder(
                                controller: PageController(
                                  viewportFraction: 0.85,
                                  initialPage: 0,
                                ),
                                itemCount: selectedImageList.length,
                                itemBuilder: (context, index){

                              var imageObject = selectedImageList[index];

                              return Padding(
                                padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                                child: Stack(children: [

                                  Image.file(imageObject, fit: BoxFit.cover,
                                    height: MediaQuery.of(context).size.width/1.6,
                                  width: MediaQuery.of(context).size.width-AppDimensions.maxPadding,),

                                  Positioned(left: 18, top: 15,
                                      child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.cardRadius)),
                                        child: Container(height: 38, width: 38,
                                          color: AppColors.black.withOpacity(0.2),
                                          child: Center(
                                            child: Text("$count", style: Theme.
                                            of(context).textTheme.headline6
                                                .apply(color: AppColors.white,
                                            fontWeightDelta: 1),),
                                          ),
                                        ),
                                      )),

                                  Positioned(right: 10, top: 10,
                                      child: IconButton(
                                      icon: Icon(Icons.cancel, size: 30,
                                      color: Theme.of(context).accentColor,),
                                    onPressed: (){
                                    selectedImageList.removeAt(index);
                                    imageCount.value = selectedImageList.length ?? 0;
                                  },))

                                ]),
                              );
                          }));
                  }),),

                  Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: Container(
                      margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                      child: TextFormField(
                        controller: _lessonNameController,
                        decoration:
                        InputDecoration(labelText: AppStrings.lessonNameLabel),
                        maxLines: 1,
                        autofocus: false,
                        focusNode: _focusLessonName,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        onFieldSubmitted: ValidationUtils.fieldNext(
                            context, _focusLessonDescription),
                        validator: ValidationUtils.getEmptyValidator(
                            context, AppStrings.enterLessonName),
                        onSaved: (value) => _lessonName = value,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: Container(
                      margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                      child: TextFormField(
                        controller: _lessonDescriptionController,
                        decoration: InputDecoration(
                            labelText: AppStrings.lessonDesc),
                        maxLines: 6,
                        autofocus: false,
                        //textInputAction: TextInputAction.multiline,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        focusNode: _focusLessonDescription,
                        onSaved: (value) => _lessonDescription = value,
                        validator: ValidationUtils.getEmptyValidator(context, AppStrings.enterLessonDesc),
                      ),
                    ),
                  ),

                  SizedBox(height: AppDimensions.largeTopBottomPadding,),

                  Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: Row(children: [
                      Text(AppStrings.cuisineTypeLabel, style: Theme.of(context).textTheme.subtitle1.apply(fontSizeDelta: 2),),
                      SizedBox(width: AppDimensions.generalPadding,),

                      Flexible(
                        child: GestureDetector(onTap: (){
                          if(_tagsModel == null){
                            _bloc.event.add(EventModel(CreateLessonBloc.GET_TAGS_EVENT, data: true));
                          }else {
                            CuisineMultiSelectBottomSheet.showFiltersSheet(context, selectedCuisineMap, _tagsModel.cuisines, btnText: AppStrings.saveLabel).then((value) {
                              if (value != null){
                                selectedCuisineMap.clear();
                                selectedCuisineMap.addAll((value as Map<int, CommonTagItemModel>));

                                if (selectedCuisineMap != null && selectedCuisineMap.isNotEmpty) {
                                  /*if (selectedCuisineMap.length == 2){
                                    var cuisine = "";
                                    selectedCuisineMap.forEach((key, value) {
                                      cuisine += "${value.name}, ";
                                    });
                                    cuisineText.value = cuisine.substring(0, cuisine.length-2);
                                  } else*/ if (selectedCuisineMap.length == 1) {
                                    cuisineText.value = selectedCuisineMap.values.toList().first.name;
                                  } else if (selectedCuisineMap.length > 1) {
                                    cuisineText.value = "${selectedCuisineMap.values.toList().first.name}";
                                  } else {
                                    cuisineText.value = AppStrings.cuisine;
                                  }
                                } else {
                                  cuisineText.value = AppStrings.cuisine;
                                }

                                cuisineCount.value = (selectedCuisineMap?.length ?? 0) - 1;
                              }
                            });
                          }
                        },
                          child: ValueListenableProvider<String>.value(
                            value: cuisineText,
                            child: Consumer<String>(
                              builder: (context, value, index){
                                return Container(decoration: BoxDecoration(color: AppColors.backgroundGrey300, borderRadius: BorderRadius.all(Radius.circular(100.0))),
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 10),
                                      child:  Row(mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            "assets/dashboard_cuisine.png",
                                            width: 20,
                                            height: 20,
                                            color: AppColors.black,
                                          ),
                                          SizedBox(width: 8,),
                                          Flexible(child: Text(value, style: Theme.of(context).textTheme.caption, overflow: TextOverflow.ellipsis, maxLines: 1,)),
                                          ValueListenableProvider<int>.value(value: cuisineCount,
                                            child: Consumer<int>(builder: (context, value, index){
                                              return (value < 1 ) ? Container() : Text(" +${(value ?? 0)}",
                                                style: Theme.of(context).textTheme.caption, overflow: TextOverflow.ellipsis, maxLines: 1,);
                                            }),),
                                        ],
                                      ),
                                    ));

                                /*Chip(padding: EdgeInsets.only(left: 10, right: 10),
                                    backgroundColor: AppColors.backgroundGrey300,
                                    label: Row(
                                      children: [
                                        Image.asset(
                                          "assets/dashboard_cuisine.png",
                                          width: 20,
                                          height: 20,
                                          color: AppColors.black,
                                        ),
                                        SizedBox(width: 8,),
                                        Text(value, style: Theme.of(context).textTheme.caption,),
                                      ],
                                    ));*/
                              },
                            ),
                          ),
                        ),
                      )
                    ],),
                  ),

                  SizedBox(height: AppDimensions.generalPadding,),

                  Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: Row(children: [
                      Text(AppStrings.dietaryTypeLabel, style: Theme.of(context).textTheme.subtitle1.apply(fontSizeDelta: 2),),
                      SizedBox(width: AppDimensions.generalPadding,),
                      Flexible(
                        child: GestureDetector(onTap: (){
                          if(_tagsModel == null){
                            _bloc.event.add(EventModel(CreateLessonBloc.GET_TAGS_EVENT, data: false));
                          }else{
                            DietaryFilterBottomSheet.showFiltersSheet(context, selectedDietsMap, _tagsModel.diets).then((value) {
                              if (value != null){
                                selectedDietsMap.clear();
                                selectedDietsMap.addAll((value as Map<int, CommonTagItemModel>));

                                if (selectedDietsMap != null || selectedDietsMap.isNotEmpty) {
                                  /*if (selectedDietsMap.length == 2){
                                    var diets = "";
                                    selectedDietsMap.forEach((key, value) {
                                      diets += "${value.name}, ";
                                    });
                                    dietText.value = diets.substring(0, diets.length-2);
                                  } else*/ if (selectedDietsMap.length == 1) {
                                    dietText.value = selectedDietsMap.values.toList().first.name;
                                  } else if (selectedDietsMap.length > 1) {
                                    dietText.value = "${selectedDietsMap.values.toList().first.name}";
                                  } else {
                                    dietText.value = AppStrings.dietary;
                                  }
                                } else {
                                  dietText.value = AppStrings.dietary;
                                }

                                dietCount.value = (selectedDietsMap?.length ?? 0) - 1;
                              }
                            });
                          }
                        },
                          child: ValueListenableProvider<String>.value(value: dietText,
                            child: Consumer<String>(builder: (context, value, child){
                              return Container(decoration: BoxDecoration(color: AppColors.backgroundGrey300, borderRadius: BorderRadius.all(Radius.circular(100.0))),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 10),
                                    child:  Row(mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          "assets/dashboard_diet.png",
                                          width: 20,
                                          height: 20,
                                          color: AppColors.black,
                                        ),
                                        SizedBox(width: 8,),
                                        Flexible(child: Text(value, style: Theme.of(context).textTheme.caption, overflow: TextOverflow.ellipsis, maxLines: 1,)),
                                        ValueListenableProvider<int>.value(value: dietCount,
                                          child: Consumer<int>(builder: (context, value, index){
                                            return (value < 1 ) ? Container() : Text(" +${(value ?? 0)}",
                                              style: Theme.of(context).textTheme.caption, overflow: TextOverflow.ellipsis, maxLines: 1,);
                                          }),),
                                      ],
                                    ),
                                  )); /*Chip(padding: EdgeInsets.only(left: 10, right: 10),
                                  backgroundColor: AppColors.backgroundGrey300,
                                  label: Row(
                                    children: [
                                      Image.asset(
                                        "assets/dashboard_diet.png",
                                        width: 20,
                                        height: 20,
                                        color: AppColors.black,
                                      ),
                                      SizedBox(width: 8,),
                                      Text(value, style: Theme.of(context).textTheme.caption,), //_getDietaryText(count)
                                    ],
                                  ));*/
                            }),),
                        ),
                      )
                    ],),
                  ),

                  SizedBox(height: AppDimensions.largeTopBottomPadding,),

                  ///Duration
                  Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: Container(
                      child: TextFormField(
                        onTap: (){
                          FocusScope.of(context)
                              .requestFocus(new FocusNode());

                          DurationPickerBottomSheet.durationPickerSheet(
                              context,
                              AppStrings.selectDuration,
                                  (int hours, int min) async {
                                    _selectedDurationInMinutes = ((hours*60) + min);
                               _durationController.text = "$hours h $min min";
                              },
                              initialTimeInMinutes: _selectedDurationInMinutes);
                        },
                        controller: _durationController,
                        decoration:
                        InputDecoration(labelText: AppStrings.duration),
                        maxLines: 1,
                        autofocus: false,
                        enableInteractiveSelection: false,
                        showCursor: false,
                        focusNode: _focusDuration,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        /*onFieldSubmitted: ValidationUtils.fieldNext(
                            context, _focusPrice),*/
                        validator: ValidationUtils.getEmptyValidator(
                            context, AppStrings.enterLessonDuration),
                      ),
                    ),
                  ),

                  ///Price
                  Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: Container(
                      margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                      child: TextFormField(
                        controller: _lessonPriceController,
                        decoration:
                        InputDecoration(labelText: AppStrings.priceLabel),
                        maxLines: 1,
                        autofocus: false,
                        focusNode: _focusPrice,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: ValidationUtils.getEmptyValidator(
                            context, AppStrings.enterLessonPrice),
                        onSaved: (value) => _price = value,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.generalMinPadding, left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: Text(AppStrings.priceNoteForBookedLesson,
                      style: Theme.of(context).textTheme.bodyText2.apply(
                          fontStyle: FontStyle.italic
                      ),),
                  ),

                  SizedBox(height: AppDimensions.generalPadding,),

                  ///Recipes
                  Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      Expanded(child: Text(AppStrings.recipeList, style: Theme.of(context).textTheme.headline5,)),
                      IconButton(icon: Icon(Icons.add_circle, color: AppColors.colorAccent, size: 30,), onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRecipeScreen())).then((value){
                          if(value != null){
                            recipeList.add(value);
                            recipeListCount.value = recipeList.length ?? 0;
                          }
                        });
                      })
                    ],),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: ValueListenableProvider<int>.value(value: recipeListCount,
                    child: Consumer<int>(builder: (context, count, child){
                      return (count == 0) ? Container()
                          : ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: count,
                        padding: EdgeInsets.only(top: 0),
                        itemBuilder: (context, index) {
                          var _recipe = recipeList[index];
                          return (_recipe.isDeleted ?? false) ? Container() : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: GestureDetector(onLongPress: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRecipeScreen(recipe: _recipe))).then((value){
                                if(value != null){
                                  recipeList.removeAt(index);

                                  if(recipeList.length >= index){
                                    recipeList.add(value);
                                  }else recipeList.insert(index, value);

                                  recipeListCount.value = recipeList.length ?? 0;
                                  setState(() {});
                                }
                              });
                            },
                              child: Card(
                                elevation: 2,
                                child: ExpansionTile(
                                  childrenPadding: EdgeInsets.only(top: 10, left: AppDimensions.generalPadding, right: AppDimensions.generalPadding,),
                                  title: Text(_recipe.name, style: Theme.of(context).textTheme.headline6.apply(fontWeightDelta: 2),),
                                  subtitle: Text(_recipe.instruction, style: Theme.of(context).textTheme.bodyText2,),
                                  backgroundColor: AppColors.white,
                                  children: _ingredientList(_recipe),
                                  trailing: IconButton(
                                    icon: Icon(Icons.cancel, size: 30,
                                      //color: AppColors.red,
                                    ),
                                    onPressed: (){
                                      CommonBottomSheet.showConfirmationBottomSheet(context, AppStrings.deleteRecipe, AppStrings.confirmDeleteRecipe, AppStrings.yes, AppStrings.no, (){
                                        Navigator.pop(context);
                                        recipeList[index].isDeleted = true; //removeAt(index);
                                        //recipeListCount.value = recipeList.length;
                                        setState(() {});
                                      });
                                    },),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),),
                  ),

                  SizedBox(height: AppDimensions.generalPadding,),

                  Padding(
                    padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: ValueListenableProvider<String>.value(value: errorMessage,
                    child: Consumer<String>(builder: (context, error, child){
                      return (error.isEmpty) ? Container()
                          : Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text("$error",
                        style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.errorTextColor),),
                          );
                    }),),
                  ),

                  ///SaveButton
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.generalPadding, left: AppDimensions.generalPadding,
                      right: AppDimensions.generalPadding,),
                    child: ValueListenableProvider<bool>.value(
                        value: _bloc.isSavingLesson,
                        child: Consumer<bool>(
                            builder: (context, isLoading, child){
                              return isLoading ? _getLoaderWidget() : _getSubmitButton();
                            })
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {

    _focusLessonName.dispose();
    _focusLessonDescription.dispose();
    _focusDuration.dispose();
    _focusPrice.dispose();


    if(subscriberTagList != null)
    subscriberTagList.cancel();
   if(subscriberCreateLesson != null)
     subscriberCreateLesson.cancel();
   if(subscriberupdateLesson != null)
     subscriberupdateLesson.cancel();
   if(subscriberuploadLessonImage != null)
     subscriberuploadLessonImage.cancel();
   if(subscriberDeleteLessonImage != null)
     subscriberDeleteLessonImage.cancel();

    _bloc.dispose();
    super.dispose();
  }

  Widget mediaListView(){
    return ValueListenableProvider<int>.value(value: imageCount,
      child: Consumer<int>(builder: (context, count, child){
        return ((count ?? 0) == 0) ? Container()
            : Container(height: MediaQuery.of(context).size.width/1.6,
            child: PageView.builder(
                controller: PageController(
                  viewportFraction: 0.85,
                  initialPage: 0,
                ),
                itemCount: _lessonImagesList.length,
                itemBuilder: (context, index){

                  var lessonImage = _lessonImagesList[index];

                  if(lessonImage.id == null){

                    return Padding(
                      padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder:
                              (context) => MediaPageViewScreen(_lessonImagesList, index)));
                        },
                        child: Stack(children: [

                          Image.file(lessonImage.localFile, fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.width/1.6,
                            width: MediaQuery.of(context).size.width-AppDimensions.maxPadding,),

                          Positioned(left: 18, top: 15,
                              child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.cardRadius)),
                                child: Container(height: 38, width: 38,
                                  color: AppColors.black.withOpacity(0.2),
                                  child: Center(
                                    child: Text("$count", style: Theme.
                                    of(context).textTheme.headline6
                                        .apply(color: AppColors.white,
                                        fontWeightDelta: 1),),
                                  ),
                                ),
                              )),

                          Positioned(right: 10, top: 10,
                              child: IconButton(
                                icon: Icon(Icons.cancel, size: 30,
                                  color: Theme.of(context).accentColor,),
                                onPressed: (){
                                  if(imageProcessingIndex.value != -1){
                                    return;
                                  }
                                  if(_lessonImagesList[index].id == null){
                                    _lessonImagesList.removeAt(index);
                                    imageCount.value = _lessonImagesList.length;
                                  }else CommonBottomSheet.showConfirmationBottomSheet(context,
                                      AppStrings.deleteImage,
                                      AppStrings.wantToDeleteImage,
                                      AppStrings.yes,
                                      AppStrings.no,
                                          (){
                                      Navigator.pop(context);
                                      imageProcessingIndex.value = index;
                                      _bloc.event.add(EventModel(CreateLessonBloc.DELETE_LESSON_IMAGE_EVENT, data: _lessonImagesList[index].id));

                                          });
                                },)),

                          ValueListenableProvider<int>.value(value: imageProcessingIndex,
                          child: Consumer<int>(builder: (context, value, child){
                            return (value == index)
                                ? Center(child: CircularProgressIndicator())
                                :  Center(child: GestureDetector(onTap: (){
                              if(widget.lessonDetailsModel != null && imageProcessingIndex.value != -1){
                                return;
                              }
                              _bloc.event.add(EventModel(CreateLessonBloc.UPLOAD_LESSON_IMAGE_EVENT, data: _lessonImagesList[index].localFile));
                              imageProcessingIndex.value = index;
                            },
                                  child: Container(decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                    width: 2, color: Theme.of(context).accentColor),
                                      color: Theme.of(context).accentColor,
                                    ),
                                    child: Icon(Icons.upload_rounded,
                                        color: AppColors.white, size: 40)),
                                ));
                          }),),

                        ]),
                      ),
                    );

                  }else{

                    return Padding(
                      padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder:
                              (context) => MediaPageViewScreen(_lessonImagesList, index)));
                        },
                        child: Stack(children: [

                            CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      height: MediaQuery.of(context).size.width/1.6,
                                      width: MediaQuery.of(context).size.width-AppDimensions.maxPadding,
                                      imageUrl: (lessonImage.thumbnailPath?.isEmpty ?? true) ? "" : lessonImage.thumbnailPath,
                                      progressIndicatorBuilder: (context,
                                          url, downloadProgress) =>
                                          Image.asset(
                                            "assets/loading_image.png",
                                            fit: BoxFit.cover,
                                            height: MediaQuery.of(context).size.width/1.6,
                                            width: MediaQuery.of(context).size.width-AppDimensions.maxPadding,
                                          ),
                                      errorWidget:
                                          (context, url, error) =>
                                          Image.asset(
                                            "assets/error_image.png",
                                            color: AppColors.grayColor,
                                            fit: BoxFit.cover,
                                            height: MediaQuery.of(context).size.width/1.6,
                                            width: MediaQuery.of(context).size.width-AppDimensions.maxPadding,
                                          ),
                                    ),

                          Positioned(left: 26, top: 20,
                              child: ClipRRect(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.cardRadius)),
                                child: Container(height: 38, width: 38,
                                  color: AppColors.black.withOpacity(0.2),
                                  child: Center(
                                    child: Text("$count", style: Theme.
                                    of(context).textTheme.headline6
                                        .apply(color: AppColors.white,
                                        fontWeightDelta: 1),),
                                  ),
                                ),
                              )),

                          Positioned(right: 16, top: 10,
                              child: IconButton(
                                icon: Icon(Icons.cancel, size: 30,
                                  color: Theme.of(context).accentColor,),
                                onPressed: (){
                                  if(imageProcessingIndex.value != -1){
                                    return;
                                  }
                                  CommonBottomSheet.showConfirmationBottomSheet(context,
                                      AppStrings.deleteImage,
                                      AppStrings.wantToDeleteImage,
                                      AppStrings.yes,
                                      AppStrings.no,
                                          (){
                                            Navigator.pop(context);
                                            imageProcessingIndex.value = index;
                                            _bloc.event.add(EventModel(CreateLessonBloc.DELETE_LESSON_IMAGE_EVENT, data: _lessonImagesList[index].id));
                                      });

                                },)),

                          ValueListenableProvider<int>.value(value: imageProcessingIndex,
                            child: Consumer<int>(builder: (context, value, child){
                              return (value == index) ? Center(child: CircularProgressIndicator()) :  Container();
                            }),),

                        ]),
                      ),
                    );

                  }
                }));
      }),);
  }

  Widget _getLoaderWidget() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.generalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator()],
      ),
    );
  }

  Widget _getSubmitButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _processForm(),
            child: Text(AppStrings.saveLabel,),
          ),
        ),
      ],
    );
  }


  List<Widget> _ingredientList(RecipeModel recipe) {
    List<Widget> widgetList = [];

    if(recipe.ingredients != null && recipe.ingredients.isNotEmpty) {
      recipe.ingredients.asMap().forEach((index, model) {
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

  _processForm(){
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if((selectedImageList.length ?? 0) == 0 && widget.lessonDetailsModel == null){
        errorMessage.value = AppStrings.addImages;
        return;
      }else if(_lessonImagesList.length == 0 && widget.lessonDetailsModel != null){
        errorMessage.value = AppStrings.addImages;
        return;
      }

      if((recipeList.length ?? 0)== 0){
        errorMessage.value = AppStrings.addRecipes;
        return;
      }else {
        bool nonDeletedLessonFound = false;

        for(int i=0; i < recipeList.length; i++){
          if((recipeList[i].isDeleted ?? false) == false){
            nonDeletedLessonFound = true;
            break;
          }
        }

        if(nonDeletedLessonFound == false){
          errorMessage.value = AppStrings.addRecipes;
          return;
        }
      }

      if(selectedCuisineMap?.isEmpty ?? true){
        errorMessage.value = AppStrings.selectCuisineType;
        return;
      }

      if((selectedDietsMap?.isEmpty ?? true)){
        errorMessage.value = AppStrings.selectDietaryTypes;
        return;
      }

      errorMessage.value = "";

      List<dynamic> recipeListData = <dynamic>[];

      recipeList.forEach((element) {

        var ingredientsData = <String, String>{};

        element.ingredients.forEach((element) {
          ingredientsData.putIfAbsent("${element.ingredient}", () => "${element.quantity}");
        });

        var recipeData = <String, dynamic>{
          "name" : element.name,
          "instructions" : element.instruction,
          "utensils" : element.utensils,
          "ingredients" : ingredientsData,
          "duration_minutes" : _selectedDurationInMinutes,
          "is_deleted" : element.isDeleted ?? false,
        };

        if(widget.lessonDetailsModel != null && element.id != null){
          recipeData.putIfAbsent("id", () => element.id);
        }

        recipeListData.add(recipeData);
      });


      var lessonData = <String, dynamic>{
        "name" : _lessonName,
        "description" : _lessonDescription,
        "duration_minutes" : _selectedDurationInMinutes,
        "booking_amount" : double.parse(_price),
        "c" : selectedCuisineMap.keys.toList(),
        "d" : selectedDietsMap.keys.toList(),
        "recipes" : recipeListData
      };

      if(widget.lessonDetailsModel != null){
        lessonData.putIfAbsent("id", () => widget.lessonDetailsModel.id);
      }

      if(widget.lessonDetailsModel != null){
        _bloc.event.add(EventModel(CreateLessonBloc.UPDATE_LESSON_EVENT, data: lessonData));
      }else{
        _bloc.uploadImageList = selectedImageList;

        _bloc.event.add(EventModel(CreateLessonBloc.CREATE_LESSON, data: lessonData));

      }

    }
  }

}
