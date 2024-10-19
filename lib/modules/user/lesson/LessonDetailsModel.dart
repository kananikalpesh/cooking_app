
import 'package:cooking_app/model/custom_objects/AttachmentModel.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';

class LessonDetailsModel {
  int id;
  String name;
  int amount;
  int duration;
  List<AttachmentModel> lessonImages;
  LessonCreatorModel creatorModel;
  List<RecipeModel> recipes;
  double lessonRatings;
  List<CommonTagItemModel> cuisines;
  List<CommonTagItemModel> diets;
  String description;

  LessonDetailsModel({
    this.id,
    this.name,
    this.amount,
    this.duration,
    this.lessonImages,
    this.creatorModel,
    this.recipes,
    this.lessonRatings,
    this.cuisines,
    this.diets,
    this.description,
  });

  factory LessonDetailsModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return LessonDetailsModel(
      id: json["id"],
      name: json["name"],
      duration: json["duration_minutes"],
      amount: json["booking_amount"],
      lessonImages: (json["lesson_images"] as List)?.map((e) => AttachmentModel.fromJson(e))?.toList(),
      creatorModel: LessonCreatorModel.fromJson(json["creator"]),
      recipes: (json["recipes"] as List)?.map((e) => RecipeModel.fromJson(e))?.toList(),
      lessonRatings: json["avg_rating"],
      cuisines:  (json["ctags"] as List)?.map((e) => CommonTagItemModel.fromJson(e))?.toList(), //(json["ctags"] != null) ? List.from(json["ctags"]) : [],
      diets: (json["dtags"] as List)?.map((e) => CommonTagItemModel.fromJson(e))?.toList(), //(json["dtags"] != null) ? List.from(json["dtags"]) : [],
      description: json["description"],
    );
  }
}

class LessonCreatorModel {
  int id;
  String firstName;
  String lastName;
  String emailId;
  String mobile;
  int role;
  String aboutMe;
  DateTime createdOn;
  String userImage;
  String userImageThumbnail;
  String cookAvailabilityString;
  List<CookAvailabilityModel> cookAvailabilities;
  double rating;

  LessonCreatorModel({
    this.id,
    this.firstName,
    this.lastName,
    this.emailId,
    this.mobile,
    this.role,
    this.aboutMe,
    this.createdOn,
    this.userImage,
    this.userImageThumbnail,
    this.cookAvailabilityString,
    this.cookAvailabilities,
    this.rating
  });

  factory LessonCreatorModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return LessonCreatorModel(
      id: json["id"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      emailId: json["email"],
      mobile: json["mobile"],
      role: json["role"],
      aboutMe: json["about_me"],
      createdOn: ((json["created_at"] != null)
          ? DateTime.parse(json["created_at"])
          : null),
      userImage: json["__pi_orig"],
      userImageThumbnail: json["__pi_thumb"],
      cookAvailabilityString: json["cook_availabilities_string"],
      cookAvailabilities: (json["cook_availabilities"] as List)?.map((e) => CookAvailabilityModel.fromJson(e))?.toList(),
      rating: json["avg_rating"],
    );
  }
}

class CookAvailabilityModel {
  int id;
  int cookId;
  int dayIndex;
  DateTime startDateTime;
  DateTime endDateTime;

  CookAvailabilityModel({
    this.id,
    this.cookId,
    this.dayIndex,
    this.startDateTime,
    this.endDateTime
  });

  factory CookAvailabilityModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return CookAvailabilityModel(
      id: json["id"],
      cookId: json["cook_id"],
      dayIndex: json["day_index"],
      startDateTime: ((json["from_time"] != null)
          ? DateTime.parse(json["from_time"])
          : null),
      endDateTime: ((json["to_time"] != null)
          ? DateTime.parse(json["to_time"])
          : null),
    );
  }

}

class RecipeModel {
  int id;
  String name;
  String lessonName;
  String utensils;
  String instruction;
  int durationMins;
  bool isDeleted;
  List<IngredientModel> ingredients;

  RecipeModel({
    this.id,
    this.name,
    this.lessonName,
    this.utensils,
    this.instruction,
    this.durationMins,
    this.isDeleted,
    this.ingredients
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return RecipeModel(
      id: json["id"],
      name: json["name"],
      lessonName: json["lesson_name"],
      utensils: json["utensils"],
      instruction: json["instructions"],
      durationMins: json["duration_minutes"],
      isDeleted: json["is_deleted"] ?? false,
      ingredients: (json["ingredients"] as Map)?.entries?.toList()?.map((e) => IngredientModel.fromJson(e))?.toList(),
    );
  }

}

class IngredientModel {
  String quantity;
  String ingredient;

  IngredientModel({
    this.quantity,
    this.ingredient,
  });

  factory IngredientModel.fromJson(MapEntry<String, dynamic> entry) {
    if (entry == null) return null;

    return IngredientModel(
      ingredient: entry.key,
      quantity: entry.value,
    );
  }

}

