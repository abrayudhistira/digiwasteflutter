class Review {
  int idReview;
  String star;
  String komentar;

  Review({
    required this.idReview,
    required this.star,
    required this.komentar,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      idReview: json['id_review'],
      star: json['star'],
      komentar: json['komentar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_review': idReview,
      'star': star,
      'komentar': komentar,
    };
  }
}