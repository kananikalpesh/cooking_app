
import 'package:cooking_app/model/custom_objects/UserModel.dart';

class BookingStatusModel {
  int lessonBookingId;
  int bookingStatus;
  String bookingStatusMsg;
  int paymentStatus;
  String paymentStatusMsg;
  DateTime lessonStartTimeUtc;
  DateTime lessonEndTimeUtc;
  int videoCallBufferInSec;
  DateTime cancellableBeforeUtc;
  CCDetailsModel ccDetailsModel;
  UserModel user;
  bool hasCookReviewedTheUser;
  bool hasUserReviewedTheCook;

  BookingStatusModel({
    this.bookingStatus,
    this.bookingStatusMsg,
    this.paymentStatus,
    this.paymentStatusMsg,
    this.lessonStartTimeUtc,
    this.lessonEndTimeUtc,
    this.videoCallBufferInSec,
    this.cancellableBeforeUtc,
    this.ccDetailsModel,
    this.lessonBookingId,
    this.user,
    this.hasCookReviewedTheUser,
    this.hasUserReviewedTheCook,
  });

  factory BookingStatusModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BookingStatusModel(
      bookingStatus: json["booking_status"],
      bookingStatusMsg: json["__booking_status"],
      paymentStatus: json["payment_status"],
      paymentStatusMsg: json["__payment_status"],
      lessonStartTimeUtc: ((json["lesson_start_utc"] != null)
          ? DateTime.parse(json["lesson_start_utc"])
          : null),
      lessonEndTimeUtc: ((json["lesson_end_utc"] != null)
          ? DateTime.parse(json["lesson_end_utc"])
          : null),
      videoCallBufferInSec: json["video_call_buffer_seconds"],
      cancellableBeforeUtc: ((json["cancellable_before_utc"] != null)
          ? DateTime.parse(json["cancellable_before_utc"])
          : null),
      ccDetailsModel: CCDetailsModel.fromJson(json["cc_info"]),
      lessonBookingId: json["lesson_booking_id"],
        user: UserModel.fromJson(json["user_info"]),
      hasCookReviewedTheUser: json["has_cook_reviewed"],
      hasUserReviewedTheCook: json["has_user_reviewed"],
    );
  }
}

class CCDetailsModel {
  String ccId;
  String name;
  CCDetailsModel({
    this.ccId,
    this.name,
  });

  factory CCDetailsModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return CCDetailsModel(
      ccId: json["cc_id"],
      name: json["name"],
    );
  }
}

enum BookingStatusEnum{
  NEW_REQUEST, COOK_ACCEPTED, PAID_AND_BOOKED, USER_RETRACTED, COOK_REJECTED, COOK_REJECTED_LESSON_DELETED,
  USER_CANCELLED, COOK_CANCELLED, EXPIRED, KILLED_CONFLICTING_BOOKED
}

enum PaymentStatusEnum{
  NONE, ATTEMPTED, PAID, RETRY, FAILED, REFUNDED
}

extension BookingStatusEnumExtension on BookingStatusEnum{
  int get enumValue{
    int value;
    switch(this){
      case BookingStatusEnum.NEW_REQUEST:
        value = 100;
        break;
      case BookingStatusEnum.COOK_ACCEPTED:
        value = 200;
        break;
      case BookingStatusEnum.PAID_AND_BOOKED:
        value = 300;
        break;
      case BookingStatusEnum.USER_RETRACTED:
        value = -100;
        break;
      case BookingStatusEnum.COOK_REJECTED:
        value = -200;
        break;
      case BookingStatusEnum.COOK_REJECTED_LESSON_DELETED:
        value = -201;
        break;
      case BookingStatusEnum.USER_CANCELLED:
        value = -400;
        break;
      case BookingStatusEnum.COOK_CANCELLED:
        value = -410;
        break;
      case BookingStatusEnum.EXPIRED:
        value = -511;
        break;
      case BookingStatusEnum.KILLED_CONFLICTING_BOOKED:
        value = -521;
        break;
    }
    return value;
  }
}

extension PaymentStatusEnumExtension on PaymentStatusEnum{
  int get enumValue{
    int value;
    switch(this){
      case PaymentStatusEnum.NONE:
        value = 100;
        break;
      case PaymentStatusEnum.ATTEMPTED:
        value = 200;
        break;
      case PaymentStatusEnum.PAID:
        value = 300;
        break;
      case PaymentStatusEnum.RETRY:
        value = -200;
        break;
      case PaymentStatusEnum.FAILED:
        value = -300;
        break;
      case PaymentStatusEnum.REFUNDED:
        value = -400;
        break;
    }
    return value;
  }
}
