
import 'package:cooking_app/model/custom_objects/UserModel.dart';

class MyBookingsListModel {
  List <MyBookingDetailsModel> lessons;

  MyBookingsListModel({
    this.lessons,
  });

  factory MyBookingsListModel.fromJson(List<dynamic> json) {
    if (json == null) return null;

    List<MyBookingDetailsModel> lessons = <MyBookingDetailsModel>[];
    lessons = json.map((i)=>MyBookingDetailsModel.fromJson(i)).toList();

    return MyBookingsListModel(
      lessons: lessons,
    );
  }

}

class MyBookingDetailsModel {
  int id;
  int bookingStatus;
  String bookingStatusMsg;
  int paymentStatus;
  String paymentStatusMsg;
  DateTime lessonStartTime;
  DateTime lessonEndTime;
  String age;
  double transactionFee;
  double refundAmount;
  double refundCharges;
  double refundTransactionFee;
  UserModel cook;
  UserModel user;
  LessonModel lessonModel;
  bool hasUserReviewedTheCook;
  bool hasCookReviewedTheUser;
  bool hasUserReportedTheCook;
  bool hasCookReportedTheUser;

  MyBookingDetailsModel({
    this.id,
    this.bookingStatus,
    this.bookingStatusMsg,
    this.paymentStatus,
    this.paymentStatusMsg,
    this.lessonStartTime,
    this.lessonEndTime,
    this.age,
    this.transactionFee,
    this.refundAmount,
    this.refundCharges,
    this.refundTransactionFee,
    this.cook,
    this.user,
    this.lessonModel,
    this.hasUserReviewedTheCook,
    this.hasCookReviewedTheUser,
    this.hasUserReportedTheCook,
    this.hasCookReportedTheUser
  });

  factory MyBookingDetailsModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return MyBookingDetailsModel(
      id: json["id"],
      bookingStatus: json["booking_status"],
      bookingStatusMsg: json["__booking_status"],
      paymentStatus: json["payment_status"],
      paymentStatusMsg: json["__payment_status"],
      lessonStartTime: ((json["start_time"] != null)
          ? DateTime.parse(json["start_time"])
          : null),
      lessonEndTime: ((json["end_time"] != null)
          ? DateTime.parse(json["end_time"])
          : null),
      age: json["age"],
      transactionFee: json["transaction_fees"],
      refundAmount: json["refund_amount"],
      refundCharges: json["refund_charges"],
      refundTransactionFee: json["refund_transaction_fees"],
      cook: UserModel.fromJson(json["cook"]),
      user: UserModel.fromJson(json["user"]),
      lessonModel: LessonModel.fromJson(json["lesson"]),
        hasUserReviewedTheCook: json["has_user_reviewed"],
        hasCookReviewedTheUser: json["has_cook_reviewed"],
        hasUserReportedTheCook: json["has_user_reported"],
        hasCookReportedTheUser: json["has_cook_reported"],
    );
  }

}

class LessonModel {
  int id;
  int creatorId;
  String name;
  int durationMin;
  int bookingAmount;
  String description;
  double rating;

  LessonModel({
    this.id,
    this.creatorId,
    this.name,
    this.durationMin,
    this.bookingAmount,
    this.description,
    this.rating
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return LessonModel(
      id: json["id"],
      creatorId: json["creator_id"],
      name: json["name"],
      durationMin: json["duration_minutes"],
      bookingAmount: json["booking_amount"],
      description: json["description"],
      rating: json["avg_rating"],
    );
  }
}

enum BookingRequestEnum{
  ALL, PENDING_CONFIRMATION, ACCEPTED_AND_PENDING_PAYMENT, REJECTED, PAID_AND_BOOKED, CANCELLED_BY_COOK_OR_USER,
  EXPIRED, ACCEPTED_AND_PAID//Combination of enum 1 and 3
}

enum TimelineStatusEnum{
  ALL, PAST, UPCOMING
}

enum UserBookingRequestEnum{
  ALL, NOT_BOOKED, BOOKED, COMBINED
}

extension BookingRequestEnumExtension on BookingRequestEnum{
  int get enumValue{
    int value;
    switch(this){
      case BookingRequestEnum.ALL:
        value = -1;
        break;
      case BookingRequestEnum.PENDING_CONFIRMATION:
        value = 0;
        break;
      case BookingRequestEnum.ACCEPTED_AND_PENDING_PAYMENT:
        value = 1;
        break;
      case BookingRequestEnum.REJECTED:
        value = 2;
        break;
      case BookingRequestEnum.PAID_AND_BOOKED:
        value = 3;
        break;
      case BookingRequestEnum.CANCELLED_BY_COOK_OR_USER:
        value = 4;
        break;
      case BookingRequestEnum.EXPIRED:
        value = 5;
        break;
      case BookingRequestEnum.ACCEPTED_AND_PAID:
        value = 6;
        break;
    }
    return value;
  }
}

extension TimelineStatusEnumExtension on TimelineStatusEnum{
  int get enumValue{
    int value;
    switch(this){
      case TimelineStatusEnum.ALL:
        value = -1;
        break;
      case TimelineStatusEnum.PAST:
        value = 0;
        break;
      case TimelineStatusEnum.UPCOMING:
        value = 1;
        break;
    }
    return value;
  }
}

extension UserBookingRequestEnumExtension on UserBookingRequestEnum{
  int get enumValue{
    int value;
    switch(this){
      case UserBookingRequestEnum.ALL:
        value = -1;
        break;
      case UserBookingRequestEnum.NOT_BOOKED:
        value = 0;
        break;
      case UserBookingRequestEnum.BOOKED:
        value = 1;
        break;
      case UserBookingRequestEnum.COMBINED:
        value = 2;
        break;
    }
    return value;
  }
}

