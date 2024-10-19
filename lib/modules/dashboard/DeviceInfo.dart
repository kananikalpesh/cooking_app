
import 'dart:convert';

class DeviceInfo {
  final String deviceId;
  final PgStatus pgStatus;

  DeviceInfo({this.deviceId, this.pgStatus});

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return DeviceInfo(
        deviceId: json['deviceId'],
        pgStatus: PgStatus.fromJson(json["pg_status"]));
  }
}

class PgStatus {
   bool block;
  final bool flashMessage;
  final String displayMessage;
  final List<StripeError> errorMessages;

  PgStatus({this.block, this.flashMessage, this.displayMessage, this.errorMessages});

  factory PgStatus.fromJson(Map<String, dynamic> json){
    if (json == null) return null;

    return PgStatus(block: json["block"],
        flashMessage: json["flash_message"],
        displayMessage: json["display_message"],
        errorMessages: (json["error_messages"] as List)?.map((e) => StripeError.fromJson(e))?.toList(growable: false));
  }

   Map<String, dynamic> toJson(){

    List<Map<String, dynamic>> errorMessages = <Map<String, dynamic>>[];

    this.errorMessages.forEach((element) {
      errorMessages.add(<String, dynamic>{
        "code" : element.code,
        "reason" : element.reason,
        "requirement" : element.requirement,
      });
    });

    return <String, dynamic>{
      "block" : this.block,
      "flash_message": this.flashMessage,
      "display_message": this.displayMessage,
      "error_messages": json.encode(errorMessages),
    };
  }

}

class StripeError{
  String code;
  String reason;
  String requirement;

  StripeError({this.code, this.reason, this.requirement});

  factory StripeError.fromJson(Map<String, dynamic> json){
    if(json == null) return null;

    return StripeError(code: json["code"],
  reason: json["reason"],
  requirement: json["requirement"]);
  }

}