import 'package:intl/intl.dart';

class AppDateUtils {
  static final String serverDateTimeFormat = "yyyy-MM-dd'T'HH:mm:s.SZ";//"yyyy-MM-dd'T'HH:mm:ss";
  static final String serverTimeFormat = "HH:mm:ss";
  static final String dateTimeAMFormat = "yyyy-MM-dd hh:mm a";
  static final String dateOnlyFormat = "dd MMM yyy";
  static final String timeOnlyFormat = "hh:mm a";
  static final String dateFormatForSlots = "EEEE, MMMM d";

  static DateTime stringToDate(String date) {
    return DateFormat(serverDateTimeFormat).parse(date, true);
  }

  static DateTime stringToTime(String date) {
    return DateFormat(serverTimeFormat).parse(date, false);
  }

  static String dateToString(DateTime date) {
    return DateFormat(serverDateTimeFormat).format(date);
  }

 static String dateOnlyFormatToString(DateTime date) {
    return DateFormat(dateOnlyFormat).format(date);
  }

  static String timeOnlyFormatToString(DateTime date) {
    return DateFormat(timeOnlyFormat).format(date);
  }

  static String dateToAMString(DateTime date) {
    return DateFormat(dateTimeAMFormat).format(date);
  }

  static String availableSlotsFormat(DateTime date) {
    return  DateFormat(dateFormatForSlots).format(date);
  }

  static String profileFormat(DateTime date) {
    return  DateFormat.yMMMd().format(date);
  }

  static String profileTimeFormat(DateTime date) {
    return DateFormat.jm().format(date);
  }

  static String attendanceDateFormat(DateTime date) {
    return  DateFormat.yMMMd().format(date);
  }

  static String calenderMonthFormat(DateTime date) {
    return  DateFormat.yMMM().format(date);
  }

  static String commonDateTimePresenter(DateTime date){
    return "${ DateFormat.yMMMd().format(date)} ${DateFormat.jm().format(date)}";
  }

  static String loggerTime(DateTime date) {
    return DateFormat.jm().format(date);
  }

/*static String notificationDate(DateTime date, NotificationDayType type) {
    String strDate = "";
    switch(type){
      case NotificationDayType.Today:
        strDate = DateFormat.jm().format(date);
        break;

      case NotificationDayType.Yesterday:
        strDate = "${ DateFormat.yMMMd().format(date)} ${DateFormat.jm().format(date)}";
        break;

      case NotificationDayType.Previous:
        strDate =DateFormat.yMMMd().format(date);
        break;
    }
    return strDate;
  }*/

}
