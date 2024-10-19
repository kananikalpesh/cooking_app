
class ServerModel {
  int id;
  String title;
  String description;
  ServerModel({this.id, this.title, this.description});


  factory ServerModel.fromJson(Map<String, dynamic> json){
    if(json == null) return null;

    return ServerModel(
      id: json["id"],
      title: json["name"],
      description: json["description"]
    );
  }
}
