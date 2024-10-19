
class ReviewListModel {
  List <ReviewModel> reviews;

  ReviewListModel({
    this.reviews,
  });

  factory ReviewListModel.fromJson(List<dynamic> json) {
    if (json == null) return null;

    List<ReviewModel> reviews =<ReviewModel>[];
    reviews = json.map((i)=>ReviewModel.fromJson(i)).toList();

    return ReviewListModel(
      reviews: reviews,
    );
  }

}

class ReviewModel {
  int id;
  int rating;
  String comment;
  DateTime reviewDate;
  ReviewerModel reviewerModel;

  ReviewModel({
    this.id,
    this.rating,
    this.comment,
    this.reviewDate,
    this.reviewerModel,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return ReviewModel(
      id: json["id"],
      rating: json["rating"],
      comment: json["reviewer_comment"],
      reviewDate: ((json["created_at"] != null)
          ? DateTime.parse(json["created_at"])
          : null),
      reviewerModel: ReviewerModel.fromJson(json["reviewer"]),
    );
  }
}

class ReviewerModel {
  int id;
  String firstName;
  String lastName;
  String userImage;
  String userImageThumbnail;
  double rating;

  ReviewerModel({
    this.id,
    this.firstName,
    this.lastName,
    this.userImage,
    this.userImageThumbnail,
    this.rating
  });

  factory ReviewerModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return ReviewerModel(
      id: json["id"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      userImage: (json["__pi_orig"] != null) ? json["__pi_orig"] : null,
      userImageThumbnail: (json["__pi_thumb"] != null) ? json["__pi_thumb"] : null,
      rating: json["__avg_rating"],
    );
  }
}


