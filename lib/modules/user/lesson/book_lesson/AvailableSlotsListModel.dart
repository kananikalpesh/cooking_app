

class AvailableSlotsListModel {
  String warningMessage;
  List <AvailableSlotModel> slotsList;

  AvailableSlotsListModel({
    this.warningMessage,
    this.slotsList,
  });

  factory AvailableSlotsListModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;


    List<AvailableSlotModel> slotsList =<AvailableSlotModel>[];
    List<dynamic> jsonList = json["slots"];
    slotsList = jsonList.map((i)=>AvailableSlotModel.fromJson(i)).toList();

    return AvailableSlotsListModel(
      warningMessage: json["warningMessage"],
      slotsList: slotsList,
    );
  }

}

class AvailableSlotModel {
  String startTimeString;
  DateTime startTimeUtc;
  DateTime endTimeUtc;

  AvailableSlotModel({
    this.startTimeString,
    this.startTimeUtc,
    this.endTimeUtc,
  });

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return AvailableSlotModel(
      startTimeString: json["start_time"],
      startTimeUtc: ((json["start_time"] != null)
          ? DateTime.parse(json["start_time"])
          : null),
      endTimeUtc: ((json["end_time"] != null)
          ? DateTime.parse(json["end_time"])
          : null),
    );
  }
}

