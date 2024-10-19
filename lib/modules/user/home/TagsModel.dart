
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';

class TagsModel {
  List<CommonTagItemModel> cuisines;
  List<CommonTagItemModel> diets;

  TagsModel({
    this.cuisines,
    this.diets,
  });

  factory TagsModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return TagsModel(
      cuisines: (json["cuisine_tags"] as List)?.map((e) => CommonTagItemModel.fromJson(e))?.toList(),
      diets: (json["dietary_tags"] as List)?.map((e) => CommonTagItemModel.fromJson(e))?.toList(),
    );
  }

}



