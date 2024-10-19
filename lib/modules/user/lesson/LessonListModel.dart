
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';

class LessonListModel {
  List <LessonDetailsModel> lessons;

  LessonListModel({
    this.lessons,
  });

  factory LessonListModel.fromJson(List<dynamic> json) {
    if (json == null) return null;

    List<LessonDetailsModel> lessons = <LessonDetailsModel>[];
    lessons = json.map((i)=>LessonDetailsModel.fromJson(i)).toList();

    return LessonListModel(
      lessons: lessons,
    );
  }

}


