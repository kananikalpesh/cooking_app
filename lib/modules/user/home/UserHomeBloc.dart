
import 'package:cooking_app/model/custom_objects/EventModel.dart';
import 'package:cooking_app/model/custom_objects/ResultModel.dart';
import 'package:cooking_app/modules/user/home/TagsModel.dart';
import 'package:cooking_app/modules/user/home/UserHomeRepository.dart';
import 'package:cooking_app/utils/LogManager.dart';
import 'package:cooking_app/blocs/Bloc.dart';
import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';

class UserHomeBloc extends Bloc {
  static const String TAG = "UserHomeBloc";

  static const String GET_TAGS_EVENT = "get_tags_lists";

  final _repository = UserHomeRepository();

  final event = PublishSubject<EventModel>();

  final obsGetTagsLists = BehaviorSubject<ResultModel<TagsModel>>();

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  UserHomeBloc() {
    event.stream.listen((event) {
      switch (event.eventType) {
        case GET_TAGS_EVENT:
          _getTagsLists();
          break;
      }
    });
  }

  _getTagsLists() async{
    isLoading.value = true;
    LogManager().log(TAG, "_getTagsLists", "Call API for getTagsLists.");
    ResultModel resultModel = await _repository.getCuisineDietList();
    obsGetTagsLists.sink.add(resultModel);
    isLoading.value = false;
  }

  @override
  void dispose() {
    event.close();
    obsGetTagsLists.close();
  }
}