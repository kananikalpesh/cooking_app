
class OnboardingModel {
  String link;
  String returnUrl;
  String refreshUrl;

  OnboardingModel({
    this.link,
    this.returnUrl,
    this.refreshUrl,
  });

  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return OnboardingModel(
      link: (json["link"]),
      returnUrl: (json["return_url"]),
      refreshUrl: (json["refresh_url"]),
    );
  }
}

