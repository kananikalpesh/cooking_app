
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';

class BaseJsonList<T> {
  static const String ERROR_MODEL = 'errors';

  final List<T> listData;
  final List<ErrorModel> errors;

  BaseJsonList({this.listData, this.errors});

  factory BaseJsonList.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJsonList(
      listData: json as List<T>,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  getErrorMessages(){
    if (errors.length == 1){
      return errors.first.message;
    } else {
      String messages = "";
      errors.forEach((element) {
        messages += element.message + ". ";
      });
      return messages;
    }
  }
  

  factory BaseJsonList.fromGetLessonsJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJsonList(
      listData: LessonDetailsModel.fromJson(json) as List,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

}


class ErrorModel {
  final String timezone;
  final String message;

  const ErrorModel({
    this.timezone,
    this.message,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return ErrorModel(
      timezone: json['timezone'],
      message: json['detail'],
    );
  }
}
