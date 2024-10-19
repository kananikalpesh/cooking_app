
import 'dart:io';

import 'package:cooking_app/blocs/Bloc.dart';
import 'package:cooking_app/model/constants/AppConstants.dart';
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/cook/lesson/create_lesson/CreateLessonRepository.dart';
import 'package:cooking_app/modules/user/home/TagsModel.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CreateLessonBloc extends Bloc {
  static const String TAG = "CreateLessonBloc";

  static const String CREATE_LESSON = "create_lesson";
  static const String GET_TAGS_EVENT = "get_tags_lists";
  static const String UPDATE_LESSON_EVENT = "update_lesson_event";
  static const String UPLOAD_LESSON_IMAGE_EVENT = "upload_lesson_image_event";
  static const String DELETE_LESSON_IMAGE_EVENT = "delete_lesson_image_event";

  final _repository = CreateLessonRepository();

  final event = PublishSubject<EventModel>();

  final obsGetTagsLists = BehaviorSubject<ResultModel<TagsModel>>();
  final obsCreateLesson = BehaviorSubject<ResultModel<dynamic>>();
  final obsUpdateLesson = BehaviorSubject<ResultModel<dynamic>>();
  final obsUploadLessonImage = PublishSubject<ResultModel<dynamic>>();
  final obsDeleteLessonImage = PublishSubject<ResultModel<dynamic>>();

  ValueNotifier<bool> isCuisineLoading = ValueNotifier(false);
  ValueNotifier<bool> isDietaryLoading = ValueNotifier(false);
  ValueNotifier<bool> isSavingLesson = ValueNotifier(false);

  //images related
  ValueNotifier<int> currentDeletingImageIndex = ValueNotifier(-1);
  ValueNotifier<int> currentUploadingImageIndex = ValueNotifier(-1);
  ValueNotifier<int> imagesCount = ValueNotifier(0);

  List<File> uploadImageList = <File>[];

  int lessonId;

  CreateLessonBloc({int lessonId}) {

    this.lessonId = lessonId;

    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_TAGS_EVENT:
          _getTagsLists(event.data);
          break;
        case CREATE_LESSON:
          _handleCreateLesson(event.data);
          break;
        case UPDATE_LESSON_EVENT:
          _handleUpdateLesson(event.data);
          break;

        case UPLOAD_LESSON_IMAGE_EVENT:
          _uploadImage(event.data);
          break;

        case DELETE_LESSON_IMAGE_EVENT:
          _deleteImage(event.data);
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

  _handleCreateLesson(Map<String, dynamic> lessonData) async{
    ResultModel resultModel;
    try {
      isSavingLesson.value = true;
      LogManager().log(TAG, "_handleCreateLesson", "Call API for createLesson.");
      resultModel = await _repository.createLesson(lessonData, uploadImageList);
      obsCreateLesson.sink.add(resultModel);
      isSavingLesson.value = false;
    } catch(e) {
      isSavingLesson.value = false;
      LogManager().log(
          TAG, "_handleCreateLesson", "Exception from while createLesson .",
          e: e);
      obsCreateLesson.sink
          .add(ResultModel(error: "File compression exception $e"));
    }
  }

  _handleUpdateLesson(Map<String, dynamic> updatedLessonData) async {
    ResultModel resultModel;
    try {
      isSavingLesson.value = true;
      LogManager().log(TAG, "_handleUpdateLesson", "Call API for createLesson.");
      resultModel = await _repository.updateLesson(updatedLessonData, lessonId);
      obsUpdateLesson.sink.add(resultModel);
      isSavingLesson.value = false;
    } catch(e) {
      isSavingLesson.value = false;
      LogManager().log(
          TAG, "_handleUpdateLesson", "Exception from while updateLesson .",
          e: e);
      obsUpdateLesson.sink
          .add(ResultModel(error: "File compression exception $e"));
    }
  }

  _uploadImage(File fileToUpload) async {
    LogManager().log(TAG, "_uploadImage", "Call API for upload image.");
    ResultModel resultModel = await _repository.uploadLessonImage(lessonId, fileToUpload, AppConstants.IMAGE);
    obsUploadLessonImage.sink.add(resultModel);
  }

  _deleteImage(int imageId) async {
    LogManager().log(TAG, "_deleteImage", "Call API for delete image.");
    ResultModel resultModel = await _repository.deleteLessonImage(lessonId, imageId);
    obsDeleteLessonImage.sink.add(resultModel);
  }

  @override
  void dispose() {
    event.close();
    obsGetTagsLists.close();
    obsCreateLesson.close();
    obsUpdateLesson.close();
    obsUploadLessonImage.close();
    obsDeleteLessonImage.close();
  }

}