
class FlaggedUsersListModel {
  List <FlaggedUserDetailsModel> flaggedUsers;

  FlaggedUsersListModel({
    this.flaggedUsers,
  });

  factory FlaggedUsersListModel.fromJson(List<dynamic> json) {
    if (json == null) return null;

    List<FlaggedUserDetailsModel> flaggedUsers = <FlaggedUserDetailsModel>[];
    flaggedUsers = json.map((i)=>FlaggedUserDetailsModel.fromJson(i)).toList();

    return FlaggedUsersListModel(
      flaggedUsers: flaggedUsers,
    );
  }
}

class FlaggedUserDetailsModel {
  int id;
  String reportedComment;
  DateTime reportedDate;
  ReportedUserModel reporter;
  ReportedUserModel user;

  FlaggedUserDetailsModel({
    this.id,
    this.reportedComment,
    this.reportedDate,
    this.reporter,
    this.user,
  });

  factory FlaggedUserDetailsModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return FlaggedUserDetailsModel(
      id: json["id"],
      reportedComment: json["reported_comment"],
      reportedDate: ((json["reported_on"] != null)
          ? DateTime.parse(json["reported_on"])
          : null),
      reporter: ReportedUserModel.fromJson(json["__reporter"]),
      user: ReportedUserModel.fromJson(json["__user"]),
    );
  }
}

class ReportedUserModel {
  String name;
  String email;

  ReportedUserModel({
    this.name,
    this.email,
  });

  factory ReportedUserModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return ReportedUserModel(
      name: json["name"],
      email: json["email"],
    );
  }
}
