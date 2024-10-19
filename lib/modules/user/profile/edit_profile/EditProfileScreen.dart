
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooking_app/model/constants/AppData.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/modules/common/bottom_sheets/CommonBottomSheet.dart';
import 'package:cooking_app/modules/common/widgets/CustomImageShapeWidget.dart';
import 'package:cooking_app/modules/common/bottom_sheets/PickFileOptionBottomSheet.dart';
import 'package:cooking_app/modules/user/profile/address/EditAddressScreen.dart';
import 'package:cooking_app/modules/user/profile/edit_profile/EditProfileBloc.dart';
import 'package:cooking_app/utils/AppColors.dart';
import 'package:cooking_app/utils/AppDimensions.dart';
import 'package:cooking_app/utils/AppStrings.dart';
import 'package:cooking_app/utils/BaseFormBodyUnsafe.dart';
import 'package:cooking_app/utils/ConCubeUtils.dart';
import 'package:cooking_app/utils/ValidationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {

  final UserModel profileModel;

  EditProfileScreen(this.profileModel);

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
  var _addressController = new TextEditingController();

  final ImagePicker _picker = ImagePicker();
  PickedFile pickedFile;
  File selectedImage;

  @override
  void initState() {

    _bloc = EditProfileBloc();

    _bloc.obsUpdateProfile.stream.listen((result) async {
      if (result.error != null) {
        _bloc.isProfileUpdating.value = false;
        CommonBottomSheet.showErrorBottomSheet(context,result);
      } else{
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
      }
    });

    _nameController.text = widget.profileModel?.firstName;
    _emailController.text = widget.profileModel?.email;
    _aboutMeController.text = widget.profileModel?.aboutMe;
    if (widget.profileModel?.addressModel != null){
      var address = widget.profileModel.addressModel;
      _addressController.text = "${address.line1}, ${(address.line2.isNotEmpty) ? "${address?.line2},": ""} ${address.city}, ${address.state}, ${address.country}- ${address.zipCode}";
    } else {
      _addressController.text = "";
    }

    _focusName = FocusNode();
    _focusEmail = FocusNode();
    _focusAboutMe = FocusNode();

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    _nameController.selection = TextSelection.fromPosition(TextPosition(offset:_nameController.text.length));
    _emailController.selection = TextSelection.fromPosition(TextPosition(offset:_emailController.text.length));
    _aboutMeController.selection = TextSelection.fromPosition(TextPosition(offset:_aboutMeController.text.length));

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.editProfile)),
      body: BaseFormBodyUnsafe(
        child: SingleChildScrollView(
          child: mainContainerWidget(),
        ),
      ),
    );
  }

  Widget mainContainerWidget(){
    return Column(
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
              ],
            ),
          ),
        ],),
        Container(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: AppDimensions.maxPadding, left: AppDimensions.generalPadding, right: AppDimensions.generalPadding, bottom: AppDimensions.generalPadding),
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
                      enabled: false,
                      style: Theme.of(context).textTheme.subtitle1.apply(color: AppColors.lightGray),
                      autofocus: false,
                      focusNode: _focusEmail,
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
                      maxLines: 6,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      focusNode: _focusAboutMe,
                      onSaved: (value) => _aboutMe = value,
                      validator: ValidationUtils.getEmptyValidator(context, AppStrings.aboutMeDesc),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: AppDimensions.generalPadding),
                    child: TextFormField(
                      onTap: () async {
                        FocusScope.of(context)
                            .requestFocus(new FocusNode());
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditAddressScreen(addressModel: widget.profileModel?.addressModel,))).then((value){
                              if(value != null){
                                var address = value as AddressModel;
                                _addressController.text = "${address.line1}, ${(address.line2.isNotEmpty) ? "${address?.line2},": ""} ${address.city}, ${address.state}, ${address.country}- ${address.zipCode}";
                              }
                        });
                      },
                      controller: _addressController,
                      decoration: InputDecoration(labelText: AppStrings.address,),
                      maxLines: 3,
                      autofocus: false,
                      enableInteractiveSelection: false,
                      showCursor: false,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      onSaved: (value) {},
                    ),
                  ),
                ],
              ),
            ),
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

  _processForm(){
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      
      var userData = <String, dynamic>{
        "first_name": _name,
        "last_name": _name,
        "email": widget.profileModel.email,
        "about_me": _aboutMe,
      };

      _bloc.isProfileUpdating.value = true;
      _bloc.event.add(EventModel(EditProfileBloc.UPDATE_PROFILE_EVENT, data: userData));
    }
  }

  @override
  void dispose() {
    _focusName.dispose();
    _focusEmail.dispose();
    _focusAboutMe.dispose();
    super.dispose();
  }

}
