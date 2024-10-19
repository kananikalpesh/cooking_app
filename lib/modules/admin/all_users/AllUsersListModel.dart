
import 'package:cooking_app/model/custom_objects/UserModel.dart';

class AllUsersListModel {
  List <UserModel> users;

  AllUsersListModel({
    this.users,
  });

  factory AllUsersListModel.fromJson(List<dynamic> json) {
    if (json == null) return null;

    List<UserModel> userList = <UserModel>[];
    userList = json.map((i)=>UserModel.fromJson(i)).toList();

    return AllUsersListModel(
      users: userList,
    );
  }

}