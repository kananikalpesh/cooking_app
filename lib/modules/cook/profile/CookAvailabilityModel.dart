
class CookAvailabilityModel {
  int id;
  int cookId;
  int dayIndex;
  DateTime startDateTime;
  DateTime endDateTime;
  bool archived;

  CookAvailabilityModel({
    this.id,
    this.cookId,
    this.dayIndex,
    this.startDateTime,
    this.endDateTime,
    this.archived,
  });

  factory CookAvailabilityModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return CookAvailabilityModel(
      id: json["id"],
      cookId: json["cook_id"],
      dayIndex: json["day_index"],
      startDateTime: (json["from_time"] != null) ? DateTime.parse(json["from_time"]) : null,
      endDateTime: (json["to_time"] != null) ? DateTime.parse(json["to_time"]) : null,
      archived: json["archived"]
    );
  }
}


