
import 'package:cooking_app/modules/admin/all_users/AllUsersListModel.dart';
import 'package:cooking_app/modules/admin/analytics/AnalyticsModel.dart';
import 'package:cooking_app/modules/admin/payments/PaymentListModel.dart';
import 'package:cooking_app/modules/dashboard/DeviceInfo.dart';
import 'package:cooking_app/modules/login/register/RegisterModel.dart';
import 'package:cooking_app/modules/my_bookings/MyBookingsListModel.dart';
import 'package:cooking_app/modules/stripe_payment/OnboardingModel.dart';
import 'package:cooking_app/modules/stripe_payment/PaymentModel.dart';
import 'package:cooking_app/modules/user/home/TagsModel.dart';
import 'package:cooking_app/modules/user/lesson/LessonDetailsModel.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/AvailableSlotsListModel.dart';
import 'package:cooking_app/modules/user/lesson/book_lesson/CalendarDateModel.dart';
import 'package:cooking_app/modules/user/lesson/details/BookingStatusModel.dart';

import 'UserModel.dart';

class BaseJson<T> {
  static const String ERROR_MODEL = 'errors';

  final T data;
  final List<ErrorModel> errors;

  BaseJson({this.data, this.errors});

  factory BaseJson.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: json as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  getErrorMessages(){
    if (errors.length == 1){
      return errors.first.message;
    } else {
      String messages = "";
      errors.forEach((element) {
        messages += element.message + ". ";
      });
      return messages;
    }
  }

  factory BaseJson.forNullResponse(Map<String, dynamic> json) {
    return BaseJson(
      data:  null,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromUserModelJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: UserModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromRegisterModelJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: RegisterModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromGetUserProfileJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: UserModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromGetLessonDetailsJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: LessonDetailsModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromUploadProfilePicJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: UserModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromGetHomeTagsJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: TagsModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromGetLessonsJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: LessonDetailsModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromGetAvailableSlotJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: AvailableSlotModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromDeviceInfoJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: DeviceInfo.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromGetPaymentDetailsJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: PaymentModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromGetOnboardingDetailsJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: OnboardingModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromGetBookingDetailsJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: BookingStatusModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromCountries({dynamic successJson,  Map<String, dynamic> errorJson}) {
    if (successJson == null && errorJson == null) return null;
    return BaseJson(
      data: (successJson as List)?.map((e) => e.toString())?.toList(growable: false) as T,
      errors: errorJson != null ? (errorJson[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList() : null,
    );
  }

  factory BaseJson.fromGetMyBookingsJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: MyBookingDetailsModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromCalenderDateJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: CalendarDateModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromGetAnalyticsJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: AnalyticsModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromGetPaymentListJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: AdminPaymentDetailsModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

  factory BaseJson.fromGetAllUsersListJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return BaseJson(
      data: UserModel.fromJson(json) as T,
      errors: (json[ERROR_MODEL] as List)?.map((e) => ErrorModel.fromJson(e))?.toList(),
    );
  }

}


class ErrorModel {
  final String timezone;
  final String message;

  const ErrorModel({
    this.timezone,
    this.message,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return ErrorModel(
      timezone: json['timezone'],
      message: json['detail'],
    );
  }
}
