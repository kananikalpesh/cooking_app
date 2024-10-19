
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/AttachmentModel.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/common/gallery/MediaPageViewScreen.dart';
import 'package:cooking_app/modules/common/widgets/CustomImageShapeWidget.dart';
import 'package:cooking_app/modules/common/bottom_sheets/PickFileOptionBottomSheet.dart';
import 'package:cooking_app/modules/cook/profile/CookProfileBloc.dart';
import 'package:cooking_app/modules/user/home/filters/CuisineMultiSelectBottomSheet.dart';
import 'package:cooking_app/modules/cook/profile/edit_profile/EditProfileBloc.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';
import 'package:cooking_app/modules/user/home/TagsModel.dart';
import 'package:cooking_app/modules/user/home/filters/DietaryFilterBottomSheet.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:cooking_app/utils/ConCubeUtils.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

const int CAPSULE_FLEX = 80;
const int SPACE_FLEX = 20;

class EditProfileScreen extends StatefulWidget {

  final UserModel profileModel;
  final CookProfileBloc cookBloc;
  final bool isInComplete;

  EditProfileScreen(this.profileModel, this.cookBloc, {this.isInComplete = false});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  EditProfileBloc _bloc;

  String _aboutMe;
  String _name;

  final _formKey = GlobalKey<FormState>();
  FocusNode _focusName;
  FocusNode _focusEmail;
  FocusNode _focusAboutMe;

  var _nameController = new TextEditingController();
  var _emailController = new TextEditingController();
  var _aboutMeController = new TextEditingController();

  final ImagePicker _picker = ImagePicker();
  PickedFile pickedFile;
  File selectedImage;

  TagsModel _tagsModel;
  Map<int, CommonTagItemModel> selectedCuisineMap = {};
  Map<int, CommonTagItemModel> selectedDietsMap = {};
  ValueNotifier<String> cuisineText = ValueNotifier(AppStrings.cuisine);
  ValueNotifier<int> cuisineCount = ValueNotifier(0);
  ValueNotifier<String> dietText = ValueNotifier(AppStrings.dietary);
  ValueNotifier<int> dietCount = ValueNotifier(0);
  ValueNotifier<bool> _isProfessionalChef;
  ValueNotifier<int> mediaCount = ValueNotifier(0);
  ValueNotifier<String> _cuisineSelectionError = ValueNotifier("");
  List<AttachmentModel> _cookImagesList = <AttachmentModel>[];
  ValueNotifier<int> imageProcessingIndex = ValueNotifier(-1);

  @override
  void initState() {

    _bloc = EditProfileBloc();

    _cookImagesList.addAll(widget.profileModel.cookImages);
    mediaCount.value = _cookImagesList.length ?? 0;

    if (widget.profileModel.cooksCuisines != null && widget.profileModel.cooksCuisines.isNotEmpty) {
      widget.profileModel.cooksCuisines.forEach((element) {
        element.isSelected = true;
      });
      selectedCuisineMap = Map.fromIterable(widget.profileModel.cooksCuisines,
          key: (k) => k.id, value: (v) => v);
      /*if (selectedCuisineMap.length == 2){
        var cuisine = "";
        selectedCuisineMap.forEach((key, value) {
          cuisine += "${value.name}, ";
        });
        cuisineText.value = cuisine.substring(0, cuisine.length-2);
      } else*/ if (selectedCuisineMap.length == 1) {
        cuisineText.value = selectedCuisineMap.values.toList().first.name;
      } else if (selectedCuisineMap.length > 1) {
        cuisineText.value = "${selectedCuisineMap.values.toList().first.name}"; //+${selectedCuisineMap.length-1}
      } else {
        cuisineText.value = AppStrings.cuisine;
      }
    } else {
      cuisineText.value = AppStrings.cuisine;
    }

    cuisineCount.value = (selectedCuisineMap?.length ?? 0) - 1;

    if (widget.profileModel.cooksDiets != null && widget.profileModel.cooksDiets.isNotEmpty) {
      widget.profileModel.cooksDiets.forEach((element) {
        element.isSelected = true;
      });
      selectedDietsMap = Map.fromIterable(widget.profileModel.cooksDiets,
          key: (k) => k.id, value: (v) => v);
     /* if (selectedDietsMap.length == 2){
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

    _bloc.event.add(EventModel(EditProfileBloc.GET_TAGS_EVENT));
    _bloc.obsGetTagsLists.stream.listen((resultModel) {
      if(resultModel.error != null){
        CommonBottomSheet.showErrorBottomSheet(context, resultModel);
      }else{
        _tagsModel = resultModel.data;
      }
    });

    _bloc.obsUpdateProfile.stream.listen((result) async {
      if (result.error != null) {
        _bloc.isProfileUpdating.value = false;
        CommonBottomSheet.showErrorBottomSheet(context,result);
      } else{
        widget.cookBloc.event.add(EventModel(CookProfileBloc.GET_PROFILE_EVENT, data: AppData.user.id));
        AppData.user.aboutMe = _aboutMe;
        AppData.user.firstName = _name;

        await ConCubeUtils.handleUpdateCCUserName(_name);

        _bloc.isProfileUpdating.value = false;
        Navigator.pop(context, true);
      }
    });

    _bloc.obsUploadPic.stream.listen((result) {
      if (result.error != null) {
        CommonBottomSheet.showErrorBottomSheet(context,result);
      }else{}
    });

    _bloc.obsAddCookMedia.stream.listen((result) {
      if (result.error != null) {
        imageProcessingIndex.value = -1;
        CommonBottomSheet.showErrorBottomSheet(context,result);
      } else {
        _cookImagesList.removeAt(imageProcessingIndex.value);
        _cookImagesList.insert(imageProcessingIndex.value, result.data);
        imageProcessingIndex.value = -1;
        setState(() {});
      }
    });

    _bloc.obsDeleteCookMedia.listen((resultModel) {
    if(resultModel.error != null){
    imageProcessingIndex.value = -1;
    CommonBottomSheet.showErrorBottomSheet(context, resultModel);
    }else{
      _cookImagesList.removeAt(imageProcessingIndex.value);
    imageProcessingIndex.value = -1;
      mediaCount.value = _cookImagesList.length ?? 0;
    }
    });

    _nameController.text = widget.profileModel?.firstName;
    _emailController.text = widget.profileModel?.email;
    _aboutMeController.text = widget.profileModel?.aboutMe;
    _isProfessionalChef = ValueNotifier(widget.profileModel?.isProfessionalChef ?? false);

    _focusName = FocusNode();
    _focusEmail = FocusNode();
    _focusAboutMe = FocusNode();

    super.initState();

    if(widget.isInComplete){
     Future.delayed(Duration(microseconds: 100), (){
        CommonBottomSheet.showSuccessBottomSheet(context, AppStrings.letsSetUpProfile, title: AppStrings.updateProfileTitle);
     });
    }

  }

  @override
  Widget build(BuildContext context) {

    _nameController.selection = TextSelection.fromPosition(TextPosition(offset:_nameController.text.length));
    _emailController.selection = TextSelection.fromPosition(TextPosition(offset:_emailController.text.length));
    _aboutMeController.selection = TextSelection.fromPosition(TextPosition(offset:_aboutMeController.text.length));

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.editProfile)),
      backgroundColor: AppColors.white,
      body: BaseFormBodyUnsafe(
        child: SingleChildScrollView(
          child: mainContainerWidget(),
        ),
      ),
    );
  }

  Widget mainContainerWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppDimensions.maxPadding,),
        Stack(children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Center(
                      child: CustomImageShapeWidget(100, 100, 100/2,
                        (selectedImage == null)
                            ? CachedNetworkImage(
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                          imageUrl: (widget.profileModel.userImage == null)
                              ? " "
                              : widget.profileModel.userImage,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                              Image.asset(
                                "assets/loading_image.png",
                                fit: BoxFit.fill,
                                width: 100,
                                height: 100,
                              ),
                          errorWidget: (context, url, error) =>
                              Image.asset(
                                "assets/profile_user_default_icon.png",
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                        )
                            : ValueListenableProvider<bool>.value(
                          value: _bloc.isLoadingForUpdatePic,
                          child: Consumer<bool>(
                            builder: (context, isLoading, child) {
                              return (isLoading)
                                  ? Padding(
                                padding: const EdgeInsets.all(0),
                                child: Image.asset(
                                  "assets/loading_image.png",
                                  fit: BoxFit.fill,
                                  width: 100,
                                  height: 100,
                                ),
                              )
                                  : Image.file(
                                selectedImage,
                                width: 100,
                                height: 100,
                                fit: BoxFit.fill,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 70, left: 70),
                      child: GestureDetector(
                        onTap: () {
                          if (!_bloc.isLoadingForUpdatePic.value) {
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

                                    selectedImage = renamedFile;
                                    setState(() {
                                      _bloc.event.add(EventModel(EditProfileBloc.UPLOAD_PROFILE_PIC_EVENT,
                                          data: selectedImage));
                                    });
                                  }
                                });
                              } else {
                                pickedFile = await _picker.getImage(
                                    source: ImageSource.camera);
                                if (pickedFile != null) {
                                  File renamedFile = await ValidationUtils
                                      .getFileFromNewFileName(
                                      File(pickedFile.path),
                                      isImage: true);

                                  selectedImage = renamedFile;
                                  setState(() {
                                    _bloc.event.add(EventModel(EditProfileBloc.UPLOAD_PROFILE_PIC_EVENT,
                                        data: selectedImage));
                                  });
                                }
                              }

                            });
                          }
                        },
                        child: Center(
                          child: Container(
                              height: AppDimensions.maxPadding,
                              width: AppDimensions.maxPadding,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.lightBlue,
                              ),
                              child: Image.asset(
                                "assets/add_photo_outline.png",
                                scale: 2,
                                color: Theme.of(context).accentColor,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: (95/2),)
              ],
            ),
          ),
        ],),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              GestureDetector(
                child: Row(
                  children: [
                    ValueListenableProvider<bool>.value(
                      value: _isProfessionalChef,
                      child: Consumer<bool>(
                        builder: (context, isChecked, child){
                          return isChecked ? Icon(Icons.check_box_outlined)
                              : Icon(Icons.check_box_outline_blank);
                        },
                      ),
                    ),
                    SizedBox(width: 10,),
                    Text(AppStrings.professionalChefCheckboxLabel, style: Theme.of(context).textTheme.subtitle1.apply(fontSizeDelta: 2),),
                  ],
                ),
                onTap: (){
                  _isProfessionalChef.value = !(_isProfessionalChef.value);
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 6,),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(AppStrings.professionalChefNote, style: Theme.of(context).textTheme.bodyText2.apply(
              fontStyle: FontStyle.italic,
          ),),
        ),
        SizedBox(height: AppDimensions.maxPadding,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 5),
              child: Text(AppStrings.personalInfo, style: Theme.of(context).textTheme.headline4.apply(
                color: AppColors.sectionTitleColor,
              ),),
            ),
            Divider(),
            SizedBox(height: AppDimensions.generalPadding,),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(left: AppDimensions.generalPadding, right: AppDimensions.generalPadding, bottom: AppDimensions.generalPadding),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: TextFormField(
                        controller: _nameController,
                        decoration:
                        InputDecoration(labelText: AppStrings.nameLabel),
                        maxLines: 1,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                        autofocus: false,
                        focusNode: _focusName,
                        onFieldSubmitted: ValidationUtils.fieldNext(
                            context, _focusAboutMe),
                        onSaved: (value) => _name = value,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z ]+"))
                        ],
                        validator: ValidationUtils.getEmptyValidator(
                            context, AppStrings.enterName),
                      ),
                    ),
                    Container(
                      margin:
                      EdgeInsets.only(top: AppDimensions.generalPadding),
                      child: TextFormField(
                        controller: _emailController,
                        decoration:
                        InputDecoration(labelText: AppStrings.emailId),
                        maxLines: 1,
                        autofocus: false,
                        focusNode: _focusEmail,
                        enabled: false,
                        style: Theme.of(context).textTheme.subtitle1.apply(color: AppColors.lightGray),
                        onFieldSubmitted: ValidationUtils.fieldNext(context, _focusAboutMe),
                        validator: ValidationUtils.getEmailAddressValidator(context),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                      child: TextFormField(
                        controller: _aboutMeController,
                        decoration: InputDecoration(
                            labelText: AppStrings.aboutMeTitle),
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        autofocus: false,
                        focusNode: _focusAboutMe,
                        onSaved: (value) => _aboutMe = value,
                        validator: ValidationUtils.getEmptyValidator(context, AppStrings.aboutMeDesc),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.maxPadding,),
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 5),
          child: Text(AppStrings.otherDetails, style: Theme.of(context).textTheme.headline4.apply(
            color: AppColors.sectionTitleColor,
          ),),
        ),
        Divider(),
        SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.only(left: AppDimensions.generalPadding, right: AppDimensions.generalPadding, bottom: AppDimensions.generalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisSize: MainAxisSize.min,
                children: [
                Text(AppStrings.cuisineTypeLabel, style: Theme.of(context).textTheme.subtitle1.apply(fontSizeDelta: 2),),
                SizedBox(width: AppDimensions.generalPadding,),

                Flexible(
                  child: GestureDetector(onTap: (){
                    if(_tagsModel == null){
                      _bloc.event.add(EventModel(EditProfileBloc.GET_TAGS_EVENT, data: true));
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
                              cuisineText.value = "${selectedCuisineMap.values.toList().first.name}"; // (+${selectedCuisineMap.length-1})
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
                                   Flexible(child: Text(value, style: Theme.of(context).textTheme.caption, overflow: TextOverflow.ellipsis, maxLines: 1,)),
                                    ValueListenableProvider<int>.value(value: cuisineCount,
                                    child: Consumer<int>(builder: (context, value, index){
                                      return (value < 1 ) ? Container() : Text(" +${(selectedCuisineMap.length ?? 0)}",
                                        style: Theme.of(context).textTheme.caption, overflow: TextOverflow.ellipsis, maxLines: 1,);
                                    }),),
                                ],
                              ));*/
                        },
                      ),
                    ),
                  ),
                ),
              ],),
              SizedBox(height: AppDimensions.generalPadding,),
              Row(children: [
                Text(AppStrings.dietaryTypeLabel, style: Theme.of(context).textTheme.subtitle1.apply(fontSizeDelta: 2),),
                SizedBox(width: AppDimensions.generalPadding,),

                GestureDetector(
                  onTap: (){
                    if(_tagsModel == null){
                      _bloc.event.add(EventModel(EditProfileBloc.GET_TAGS_EVENT, data: false));
                    }else{
                      DietaryFilterBottomSheet.showFiltersSheet(context, selectedDietsMap, _tagsModel.diets, btnText: AppStrings.saveLabel).then((value) {
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
                      return  Container(decoration: BoxDecoration(color: AppColors.backgroundGrey300, borderRadius: BorderRadius.all(Radius.circular(100.0))),
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
                          ));

                      /*;Chip(padding: EdgeInsets.only(left: 10, right: 10),
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
                              Text(value, style: Theme.of(context).textTheme.caption,),
                            ],
                          ))*/
                    }),),
                ),
              ],),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.maxPadding,),
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(AppStrings.addImageVideo, style: Theme.of(context).textTheme.headline4.apply(
                  color: AppColors.sectionTitleColor,
                ),),
              ),
              Row(
                children: [
                  GestureDetector(
                    child: Icon(Icons.image, color: Theme.of(context).accentColor, size: 30,),
                    onTap: (){
                      if (!_bloc.isAddCookMediaLoading.value){
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

                                _cookImagesList.insert(0, AttachmentModel(localFile: renamedFile, fileType: AppConstants.IMAGE));
                                mediaCount.value = _cookImagesList.length;
                                _bloc.event.add(EventModel(EditProfileBloc.ADD_COOK_MEDIA_EVENT, data: renamedFile));
                                imageProcessingIndex.value = 0;

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

                              _cookImagesList.insert(0, AttachmentModel(localFile: renamedFile, fileType: AppConstants.IMAGE));
                              mediaCount.value = _cookImagesList.length;
                              _bloc.event.add(EventModel(EditProfileBloc.ADD_COOK_MEDIA_EVENT, data: renamedFile));
                              imageProcessingIndex.value = 0;

                            }
                          }
                        });
                      }
                    },
                  ),
                  SizedBox(width: 10,),
                  GestureDetector(
                    child: Icon(Icons.video_library, color: Theme.of(context).accentColor, size: 30,),
                    onTap: (){
                      if (!_bloc.isAddCookMediaLoading.value) {
                        PickFileOptionBottomSheet.showPickFileBottomSheet(
                            context, (int option) async {
                          if (option == FROM_GALLERY) {
                            ImagePicker()
                                .getVideo(
                                source: ImageSource.gallery)
                                .then((value) async {
                              if (value != null) {
                                File renamedFile = await ValidationUtils
                                    .getFileFromNewFileName(
                                    File(value.path),
                                    isImage: false);

                                _cookImagesList.insert(0, AttachmentModel(localFile: renamedFile, fileType: AppConstants.VIDEO));
                                mediaCount.value = _cookImagesList.length;
                                _bloc.event.add(EventModel(EditProfileBloc.ADD_COOK_MEDIA_EVENT, data: renamedFile));
                                imageProcessingIndex.value = 0;

                              }
                            });
                          } else {
                            PickedFile pickedFile = await _picker
                                .getVideo(
                              source: ImageSource.camera,
                              preferredCameraDevice: CameraDevice
                                  .rear,
                            );
                            if (pickedFile != null) {
                              File renamedFile = await ValidationUtils
                                  .getFileFromNewFileName(
                                  File(pickedFile.path),
                                  isImage: false);

                              _cookImagesList.insert(0, AttachmentModel(localFile: renamedFile, fileType: AppConstants.VIDEO));
                              mediaCount.value = _cookImagesList.length;
                              _bloc.event.add(EventModel(EditProfileBloc.ADD_COOK_MEDIA_EVENT, data: renamedFile));
                              imageProcessingIndex.value = 0;
                            }
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(right: 10),),
            ],
          ),
        ),
        Divider(),
        SizedBox(height: AppDimensions.generalPadding,),
        _getMediaListWidget(),
        ValueListenableProvider<String>.value(
          value: _cuisineSelectionError,
          child: Consumer<String>(
            builder: (context, value, child) {
              return Offstage(
                offstage: ((value?.isEmpty ?? true)),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.generalPadding,
                    right: AppDimensions.generalPadding,
                    top: AppDimensions.maxPadding,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "$value",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.errorTextColor),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: AppDimensions.generalPadding,
            right: AppDimensions.generalPadding, top: AppDimensions.generalPadding,
            bottom: AppDimensions.maxPadding,),
          child: Column(
            children: [
              ValueListenableProvider<bool>.value(
                  value: _bloc.isProfileUpdating,
                  child: Consumer<bool>(
                      builder: (context, isLoading, child){
                        return isLoading ? _getLoaderWidget() : _getSubmitButton();
                      })
              ),
            ],
          ),
        ),
      ],
    );
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

  Widget _getMediaListWidget(){
    return ValueListenableProvider<int>.value(value: mediaCount,
      child: Consumer<int>(builder: (context, count, child){
        return ((count ?? 0) == 0) ? Container()
            : Container(height: MediaQuery.of(context).size.width/1.6,
            child: PageView.builder(
                controller: PageController(
                  viewportFraction: 0.8,
                  initialPage: 0,
                ),
                itemCount: _cookImagesList.length,
                itemBuilder: (context, index){

                  AttachmentModel media = _cookImagesList[index];

                  if(media.fileType == AppConstants.IMAGE){
                    ///Image part
                    if(media.id == null) { //local image
                      return Padding(
                        padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder:
                                (context) => MediaPageViewScreen(_cookImagesList, index)));
                          },
                          child: Stack(children: [

                            Image.file(media.localFile, fit: BoxFit.cover,
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
                                    if(_cookImagesList[index].id == null){
                                      _cookImagesList.removeAt(index);
                                      mediaCount.value = _cookImagesList.length;
                                    }else CommonBottomSheet.showConfirmationBottomSheet(context,
                                        AppStrings.deleteImage,
                                        AppStrings.wantToDeleteImage,
                                        AppStrings.yes,
                                        AppStrings.no,
                                            (){
                                          Navigator.pop(context);
                                          imageProcessingIndex.value = index;
                                          _bloc.event.add(EventModel(EditProfileBloc.DELETE_COOK_MEDIA_EVENT, data: <String, dynamic>{"li" : _cookImagesList[index].id}));
                                        });
                                  },)),

                            ValueListenableProvider<int>.value(value: imageProcessingIndex,
                              child: Consumer<int>(builder: (context, value, child){
                                return (value == index)
                                    ? Center(child: CircularProgressIndicator())
                                    :  Center(child: GestureDetector(onTap: (){
                                  _bloc.event.add(EventModel(EditProfileBloc.ADD_COOK_MEDIA_EVENT, data: _cookImagesList[index].localFile));
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
                    }else{ // network image
                      return Padding(
                        padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder:
                                (context) => MediaPageViewScreen(_cookImagesList, index)));
                          },
                          child: Stack(children: [

                            CachedNetworkImage(
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.width/1.6,
                              width: MediaQuery.of(context).size.width-AppDimensions.maxPadding,
                              imageUrl: (media.filePath?.isEmpty ?? true) ? "" : media.filePath,
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
                                    CommonBottomSheet.showConfirmationBottomSheet(context,
                                        AppStrings.deleteImage,
                                        AppStrings.wantToDeleteImage,
                                        AppStrings.yes,
                                        AppStrings.no,
                                            (){
                                          Navigator.pop(context);
                                          imageProcessingIndex.value = index;
                                          _bloc.event.add(EventModel(EditProfileBloc.DELETE_COOK_MEDIA_EVENT, data: <String, dynamic>{"li" : _cookImagesList[index].id}));
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

                  } else if(media.fileType == AppConstants.VIDEO) {
                    ///Video part
                    if(media.id == null){

                      getThumbnail(context, index);

                      return Padding(
                        padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                        child: Stack(children: [

                          ((media.localThumbnail?.isEmpty ?? true))
                              ? Center(
                            child: CircularProgressIndicator(),
                          )
                              : Image.file(
                            File(media.localThumbnail),
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.width/1.6,
                            width: MediaQuery.of(context).size.width-AppDimensions.maxPadding,
                          ),

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
                                  if(_cookImagesList[index].id == null){
                                    _cookImagesList.removeAt(index);
                                    mediaCount.value = _cookImagesList.length;
                                  }else CommonBottomSheet.showConfirmationBottomSheet(context,
                                      AppStrings.deleteVideo,
                                      AppStrings.wantToDeleteVideo,
                                      AppStrings.yes,
                                      AppStrings.no,
                                          (){
                                        Navigator.pop(context);
                                        imageProcessingIndex.value = index;
                                        _bloc.event.add(EventModel(EditProfileBloc.DELETE_COOK_MEDIA_EVENT, data: <String, dynamic>{"li" : _cookImagesList[index].id}));

                                      });


                                },)),

                          Center(child:GestureDetector(onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder:
                                (context) => MediaPageViewScreen(_cookImagesList, index)));
                          },
                            child: Container(decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  width: 2, color: Theme.of(context).accentColor),
                              color: Theme.of(context).accentColor,
                            ),
                                child: Icon(Icons.play_arrow,
                                    color: AppColors.white, size: 30)),
                          )),

                          ValueListenableProvider<int>.value(value: imageProcessingIndex,
                            child: Consumer<int>(builder: (context, value, child){
                              return (value == index)
                                  ? Center(child: CircularProgressIndicator())
                                  :  Center(child: GestureDetector(onTap: (){
                                _bloc.event.add(EventModel(EditProfileBloc.ADD_COOK_MEDIA_EVENT, data: _cookImagesList[index].localFile));
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
                      );

                    }else{
                      return Padding(
                        padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                        child: Stack(children: [
                          CachedNetworkImage(
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.width/1.6,
                            width: MediaQuery.of(context).size.width-AppDimensions.maxPadding,
                            imageUrl: (media.thumbnailPath?.isEmpty ?? true) ? "" : media.thumbnailPath,
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
                                  CommonBottomSheet.showConfirmationBottomSheet(context,
                                      AppStrings.deleteVideo,
                                      AppStrings.wantToDeleteVideo,
                                      AppStrings.yes,
                                      AppStrings.no,
                                          (){
                                        Navigator.pop(context);
                                        imageProcessingIndex.value = index;
                                        _bloc.event.add(EventModel(EditProfileBloc.DELETE_COOK_MEDIA_EVENT, data: <String, dynamic>{"li" : _cookImagesList[index].id}));
                                      });

                                },)),

                          ValueListenableProvider<int>.value(value: imageProcessingIndex,
                            child: Consumer<int>(builder: (context, value, child){
                              return (value == index)
                                  ? Center(child: CircularProgressIndicator())
                                  :  Center(child: GestureDetector(onTap: (){
                                _bloc.event.add(EventModel(EditProfileBloc.ADD_COOK_MEDIA_EVENT, data: _cookImagesList[index].localFile));
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

                          Center(child:GestureDetector(onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder:
                                (context) => MediaPageViewScreen(_cookImagesList, index)));
                          },
                            child: Container(decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  width: 2, color: Theme.of(context).accentColor),
                              color: Theme.of(context).accentColor,
                            ),
                                child: Icon(Icons.play_arrow,
                                    color: AppColors.white, size: 30)),
                          )),

                        ]),
                      );
                    }

                  } else return Container(color: Theme.of(context).accentColor,);
                }));
      }),);
  }

  _processForm(){
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      
      if(selectedCuisineMap.isEmpty){
        _cuisineSelectionError.value = AppStrings.applyMultiCuisineValidationError;
        return;
      }

      _cuisineSelectionError.value = "";
      
      var userData = <String, dynamic>{
        "first_name": _name,
        "last_name": _name,
        "email": widget.profileModel.email,
        "about_me": _aboutMe,
        "is_pro": _isProfessionalChef.value,
        "ct": selectedCuisineMap.keys.toList(),
        "dt": selectedDietsMap.keys.toList()
      };

      _bloc.isProfileUpdating.value = true;
      _bloc.event.add(EventModel(EditProfileBloc.UPDATE_PROFILE_EVENT, data: userData));
    } else if (selectedCuisineMap.isEmpty){
      _cuisineSelectionError.value = AppStrings.applyMultiCuisineValidationError;
    } else _cuisineSelectionError.value = "";
  }

  getThumbnail(BuildContext context, int index) async {
    _cookImagesList[index].localThumbnail = await VideoThumbnail.thumbnailFile(
      video: _cookImagesList[index].localFile.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: MediaQuery.of(context).size.width~/1.6,
      quality: 70,
    );
    mediaCount.value = _cookImagesList.length;
  }

  @override
  void dispose() {
    _focusName.dispose();
    _focusEmail.dispose();
    _focusAboutMe.dispose();
    super.dispose();
  }

}
