
class PaymentListModel {
  List <AdminPaymentDetailsModel> payments;

  PaymentListModel({
    this.payments,
  });

  factory PaymentListModel.fromJson(List<dynamic> json) {
    if (json == null) return null;

    List<AdminPaymentDetailsModel> payments = <AdminPaymentDetailsModel>[];
    payments = json.map((i)=>AdminPaymentDetailsModel.fromJson(i)).toList();

    return PaymentListModel(
      payments: payments,
    );
  }

}

class AdminPaymentDetailsModel {
  int bookingAmount;
  double transactionFee;
  String date;

  AdminPaymentDetailsModel({
    this.bookingAmount,
    this.transactionFee,
    this.date,
  });

  factory AdminPaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return AdminPaymentDetailsModel(
      bookingAmount: json["booking_amount"],
      transactionFee: json["transaction_fees"],
      date: json["created_at"],
    );
  }

}
