
class PaymentModel {
  String sessionId;
  String successUrl;
  String failureUrl;
  String apiKey;
  String clientRefId;

  PaymentModel({
    this.sessionId,
    this.successUrl,
    this.failureUrl,
    this.apiKey,
    this.clientRefId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return PaymentModel(
      sessionId: (json["id"]),
      successUrl: (json["success_url"]),
      failureUrl: (json["cancel_url"]),
      apiKey: (json["pkey"]),
      clientRefId: (json["csid"]),
    );
  }
}

