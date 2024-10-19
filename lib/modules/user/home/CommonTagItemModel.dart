
class CommonTagItemModel {
  int id;
  String name;
  String imagePath;
  IconsModel iconsPath;
  bool isSelected = false;

  CommonTagItemModel({
    this.id,
    this.name,
    this.imagePath,
    this.iconsPath,
    this.isSelected,
  });

  factory CommonTagItemModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return CommonTagItemModel(
      id: json["id"],
      name: json["name"],
      imagePath: json["image_url"],
      iconsPath: IconsModel.fromJson(json["icon_urls"]),
      isSelected: false,
    );
  }
}

class IconsModel {
  String greenColor;
  String grayColor;
  String blackColor;

  IconsModel({
    this.greenColor,
    this.grayColor,
    this.blackColor
  });

  factory IconsModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return IconsModel(
      greenColor: json["green"],
      grayColor: json["gray"],
      blackColor: json["black"]
    );
  }

}


