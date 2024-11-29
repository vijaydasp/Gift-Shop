class ProductReview {
  final String username;
  final String profileImage;
  final double rating;
  final String comment;
  final DateTime? dateTime;

  ProductReview({
    required this.username,
    required this.profileImage,
    required this.rating,
    required this.comment,
    this.dateTime,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    // Extract user information
    final userInfo = json['USERLID'] ?? {};
    final username = '${userInfo['First_Name'] ?? ''} ${userInfo['Last_Name'] ?? ''}'.trim();
    final profileImage = userInfo['profileimage'] ?? '';

    return ProductReview(
      username: username.isEmpty ? 'Anonymous' : username,
      profileImage: profileImage,
      rating: (json['Rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['Review']?.toString() ?? "",
      dateTime: json['Date'] != null 
        ? DateTime.tryParse(json['Date'].toString()) 
        : null,
    );
  }
}