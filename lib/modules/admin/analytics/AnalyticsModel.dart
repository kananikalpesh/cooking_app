
class AnalyticsModel {
  String totalCooks;
  String totalUsers;
  String totalBookingAmount;
  String totalTransFee;
  List<TopCookModel> topCooks;

  AnalyticsModel({
    this.totalCooks,
    this.totalUsers,
    this.totalBookingAmount,
    this.totalTransFee,
    this.topCooks,
  });
  
  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return AnalyticsModel(
      totalCooks: json["cooks_count"],
      totalUsers: json["users_count"],
      totalBookingAmount: json["total_booking_amount"],
      totalTransFee: json["total_transaction_fees"],
      topCooks: (json["top5cooks"] as List)?.map((e) => TopCookModel.fromJson(e))?.toList(),
    );
  }
}

class TopCookModel {
  int id;
  String name;
  double rating;
  String email;
  int totalLessons;
  int totalBookings;
  int totalAmount;
  double totalTransFee;

  TopCookModel({
    this.id,
    this.name,
    this.rating,
    this.email,
    this.totalLessons,
    this.totalBookings,
    this.totalAmount,
    this.totalTransFee,
  });

  factory TopCookModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return TopCookModel(
      id: json["id"],
      name: json["name"],
      rating: json["avg_rating"],
      email: json["email"],
      totalLessons: json["lessons_count"],
      totalBookings: json["bookings"],
      totalAmount: json["total_amount"],
      totalTransFee: json["transaction_fees"],
    );
  }
}
