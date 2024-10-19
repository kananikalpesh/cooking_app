
import 'package:cooking_app/model/custom_objects/AttachmentModel.dart';
import 'package:cooking_app/modules/cook/profile/CookAvailabilityModel.dart';
import 'package:cooking_app/modules/dashboard/DeviceInfo.dart';
import 'package:cooking_app/modules/user/home/CommonTagItemModel.dart';

class UserModel {
  int id;
  int role;
  String firstName;
  String lastName;
  String email;
  String mobile;
  String userImage;
  String userImageThumbnail;
  String aboutMe;
  String token;
  String timezone;
  int ccId;
  List<CommonTagItemModel> cooksCuisines;
  List<CommonTagItemModel> cooksDiets;
  String cookAvailabilityString;
  List<CookAvailabilityModel> cookAvailabilities;
  bool isProfessionalChef;
  List<AttachmentModel> cookImages;
  double cookRating;
  PgStatus pgStatus;
  AddressModel addressModel;

  UserModel(
      {this.id,
      this.role,
      this.firstName,
        this.lastName,
      this.email,
      this.mobile,
      this.userImage,
        this.userImageThumbnail,
      this.aboutMe,
      this.token,
      this.timezone,
      this.ccId,
      this.cooksCuisines,
      this.cooksDiets,
      this.cookAvailabilityString,
      this.cookAvailabilities,
      this.isProfessionalChef,
      this.cookImages,
        this.cookRating,
        this.pgStatus,
      this.addressModel});

  factory UserModel.fromJson(Map<String, dynamic> json){
    if(json == null) return null;

    return UserModel(
        id: ((json.containsKey("id")) ? json["id"] : json["userId"]),
        role: json["role"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        mobile: json["mobileNumber"],
        userImage: (json["__pi_orig"] != null)
            ? json["__pi_orig"]
            : json["filePath"],
        userImageThumbnail: json["__pi_thumb"],
        aboutMe: json["about_me"],
        token: json["token"],
        timezone: json["timezone"],
      ccId: ((json["cid"] != null) ? int.parse(((json["cid"] as String).isNotEmpty) ? json["cid"] : "-1") : null),
      cooksCuisines: (json["ctags"] as List)?.map((e) => CommonTagItemModel.fromJson(e))?.toList(),
      cooksDiets: (json["dtags"] as List)?.map((e) => CommonTagItemModel.fromJson(e))?.toList(),
        cookAvailabilityString: json["cook_availabilities_string"],
        cookAvailabilities: (json["cook_availabilities"] as List)?.map((e) => CookAvailabilityModel.fromJson(e))?.toList(),
        isProfessionalChef: json["is_prof_cook"],
        cookImages: (json["cook_profile_images"] as List)?.map((e) => AttachmentModel.fromJson(e))?.toList(),
      cookRating: json["avg_rating"],
      pgStatus: PgStatus.fromJson(json["pg_status"]),
      addressModel: AddressModel.fromJson(json["address"]),
    );
  }

  Map<String, dynamic> toJson(){
    return <String, dynamic>{
      "id": this.id,
      "cid": "${this.ccId}",
      "role": this.role,
      "first_name": this.firstName,
      "last_name": this.lastName,
      "email": this.email,
      "mobileNumber": this.mobile,
      "__pi_orig": this.userImage,
      "__pi_thumb": this.userImageThumbnail,
      "about_me": this.aboutMe,
      "token": this.token,
      "timezone": this.timezone,
    };
  }

}

class AddressModel {
  int id;
  int userId;
  String line1;
  String line2;
  String city;
  String state;
  String zipCode;
  String country;

  AddressModel({
    this.id,
    this.userId,
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return AddressModel(
      id: json["id"],
      userId: json["user_id"],
      line1: json["line1"],
      line2: json["line2"],
      city: json["city"],
      state: json["state"],
      zipCode: json["zip"],
      country: json["country"],
    );
  }
}
