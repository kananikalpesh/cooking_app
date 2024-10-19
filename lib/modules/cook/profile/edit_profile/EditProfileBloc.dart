
import 'dart:io';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/cook/profile/CookProfileRepository.dart';
import 'package:cooking_app/modules/user/home/TagsModel.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class EditProfileBloc extends Bloc{
  static const String TAG = "EditProfileBloc";

  static const String UPDATE_PROFILE_EVENT = "update_profile";
  static const String UPLOAD_PROFILE_PIC_EVENT = "upload_profile_pic";
  static const String GET_TAGS_EVENT = "get_tags_lists";
  static const String ADD_COOK_MEDIA_EVENT = "add_cook_media";
  static const String DELETE_COOK_MEDIA_EVENT = "delete_cook_media";

  final _repository = CookProfileRepository();
  final event = PublishSubject<EventModel>();

  final obsUpdateProfile = BehaviorSubject<ResultModel<bool>>();
  final obsUploadPic = PublishSubject<ResultModel>();
  final obsGetTagsLists = BehaviorSubject<ResultModel<TagsModel>>();
  final obsAddCookMedia = BehaviorSubject<ResultModel<dynamic>>();
  final obsDeleteCookMedia = BehaviorSubject<ResultModel<bool>>();

  ValueNotifier<bool> isCuisineLoading = ValueNotifier(false);
  ValueNotifier<bool> isDietaryLoading = ValueNotifier(false);

  ValueNotifier<bool> isProfileUpdating = ValueNotifier(false);
  ValueNotifier<bool> isLoadingForUpdatePic = ValueNotifier(false);

  ValueNotifier<bool> isAddCookMediaLoading = ValueNotifier(false);
  ValueNotifier<bool> isDeleteCookMediaLoading = ValueNotifier(false);

  EditProfileBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case UPDATE_PROFILE_EVENT:
          _updateProfile(event.data);
          break;
        case UPLOAD_PROFILE_PIC_EVENT:
          _handleUpload(event.data);
          break;
        case GET_TAGS_EVENT:
          _getTagsLists(event.data);
          break;
        case ADD_COOK_MEDIA_EVENT:
          _addMedia(event.data);
          break;
        case DELETE_COOK_MEDIA_EVENT:
          _deleteMedia(event.data);
          break;
      }
    });
  }

  _getTagsLists(bool forCuisines) async{
    isCuisineLoading.value = forCuisines;
    isDietaryLoading.value = !(forCuisines ?? true);
    LogManager().log(TAG, "_getTagsLists", "Call API for getTagsLists.");
    ResultModel resultModel = await _repository.getCuisineDietList();
    obsGetTagsLists.sink.add(resultModel);
    isCuisineLoading.value = false;
    isDietaryLoading.value = false;
  }

  _updateProfile(Map<String , dynamic> userData) async {
    LogManager().log(TAG, "_updateProfile", "Call API for updateUserProfile.");
    ResultModel resultModel = await _repository.updateUserProfile(userData);
    obsUpdateProfile.sink.add(resultModel);
  }

  _handleUpload(File selectedFile) async{
    ResultModel resultModel;
    try {
      isLoadingForUpdatePic.value = true;
      LogManager().log(TAG, "_handleUpload", "Call API for updateUserProfile.");
      resultModel = await _repository.updateProfilePic(selectedFile);
      obsUploadPic.sink.add(resultModel);
      isLoadingForUpdatePic.value = false;
    } catch(e) {
      LogManager().log(
          TAG, "_handleUpload", "Exception from while updateProfilePic .",
          e: e);
      obsUploadPic.sink
          .add(ResultModel(error: "File compression exception $e"));
    }
  }

  _deleteMedia(Map<String , dynamic> userData) async {
    isDeleteCookMediaLoading.value = true;
    LogManager().log(TAG, "_deleteMedia", "Call API for deleteMedia.");
    ResultModel resultModel = await _repository.deleteMedia(userData);
    obsDeleteCookMedia.sink.add(resultModel);
    isDeleteCookMediaLoading.value = false;
  }

  _addMedia(File selectedFiles) async{
    ResultModel resultModel;
    try {
      isAddCookMediaLoading.value = true;
      LogManager().log(TAG, "_addMedia", "Call API for add Media.");
      resultModel = await _repository.addMedia(selectedFiles);
      obsAddCookMedia.sink.add(resultModel);
      isAddCookMediaLoading.value = false;
    } catch(e) {
      LogManager().log(
          TAG, "_addMedia", "Exception while adding Media.",
          e: e);
      obsAddCookMedia.sink
          .add(ResultModel(error: "File compression exception $e"));
    }
  }

  @override
  void dispose() {
    event.close();
    obsGetTagsLists.close();
    obsUpdateProfile.close();
    obsUploadPic.close();
    obsAddCookMedia.close();
    obsDeleteCookMedia.close();
  }
}