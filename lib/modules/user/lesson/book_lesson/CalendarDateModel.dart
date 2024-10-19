
import 'package:cooking_app/utils/AppDateUtils.dart';

class CalendarDateModel{
  DateTime calendarStarDate;
  DateTime calendarEndDate;
  List<DateTime> availableDays;

  CalendarDateModel({this.calendarStarDate, this.calendarEndDate, this.availableDays});

  factory CalendarDateModel.fromJson(Map<String, dynamic> json){
    if(json == null) return null;

    return CalendarDateModel(
        calendarStarDate: AppDateUtils.stringToDate(json["calendar_start_date"]) , //_utc
        calendarEndDate: AppDateUtils.stringToDate(json["calendar_end_date"]), //_utc
        availableDays: (json["available_days"] as List)?.map((e) => AppDateUtils.stringToDate(e))?.toList()); //_utc
  }

}