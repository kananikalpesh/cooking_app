import 'package:cooking_app/utils/AppStrings.dart';
import 'package:flutter/foundation.dart';

enum DaysEnum{
  EVERYDAY, SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY
}

extension SelectedDaysEnum on DaysEnum{

  String get displayName{
    String day = "";
    switch(this){
      case DaysEnum.EVERYDAY:
        day = AppStrings.everyday;
        break;
      case DaysEnum.SUNDAY:
        day = AppStrings.sunday;
        break;
      case DaysEnum.MONDAY:
        day = AppStrings.monday;
        break;
      case DaysEnum.TUESDAY:
        day = AppStrings.tuesday;
        break;
      case DaysEnum.WEDNESDAY:
        day = AppStrings.wednesday;
        break;
      case DaysEnum.THURSDAY:
        day = AppStrings.thursday;
        break;
      case DaysEnum.FRIDAY:
        day = AppStrings.friday;
        break;
      case DaysEnum.SATURDAY:
        day = AppStrings.saturday;
        break;
    }
    return day;
  }

  int get indexValue{
    int value;
    switch(this){
      case DaysEnum.EVERYDAY:
        value = -1;
        break;
      case DaysEnum.SUNDAY:
        value = 0;
        break;
      case DaysEnum.MONDAY:
        value = 1;
        break;
      case DaysEnum.TUESDAY:
        value = 2;
        break;
      case DaysEnum.WEDNESDAY:
        value = 3;
        break;
      case DaysEnum.THURSDAY:
        value = 4;
        break;
      case DaysEnum.FRIDAY:
        value = 5;
        break;
      case DaysEnum.SATURDAY:
        value = 6;
        break;
    }
    return value;
  }

}

class AvailabilityDays{
  static String getDayValue(int value){
    String day = "";
    switch(value){
      case -1:
        day = AppStrings.everyday;
        break;
      case 0:
        day = AppStrings.sunday;
        break;
      case 1:
        day = AppStrings.monday;
        break;
      case 2:
        day = AppStrings.tuesday;
        break;
      case 3:
        day = AppStrings.wednesday;
        break;
      case 4:
        day = AppStrings.thursday;
        break;
      case 5:
        day = AppStrings.friday;
        break;
      case 6:
        day = AppStrings.saturday;
        break;
    }
    return day;
  }
}