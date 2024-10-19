
import 'dart:io';

import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/model/custom_objects/UserModel.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../UserProfileRepository.dart';

class EditProfileBloc extends Bloc{
  static const String TAG = "EditProfileBloc";

  static const String UPDATE_PROFILE_EVENT = "update_profile";
  static const String UPLOAD_PROFILE_PIC_EVENT = "upload_profile_pic";

  final _repository = UserProfileRepository();
  final event = PublishSubject<EventModel>();

  final obsUpdateProfile = BehaviorSubject<ResultModel<bool>>();
  final obsUploadPic = PublishSubject<ResultModel>();

  ValueNotifier<bool> isProfileUpdating = ValueNotifier(false);
  ValueNotifier<bool> isLoadingForUpdatePic = ValueNotifier(false);

  EditProfileBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case UPDATE_PROFILE_EVENT:
          _updateProfile(event.data);
          break;
        case UPLOAD_PROFILE_PIC_EVENT:
          _handleUpload(event.data);
          break;
      }
    });
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

  @override
  void dispose() {
    event.close();
    obsUpdateProfile.close();
    obsUploadPic.close();
  }
}