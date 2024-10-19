
class RegisterModel {
  int oi;

  RegisterModel({
    this.oi,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return RegisterModel(
      oi: json["oi"],
    );
  }

}


