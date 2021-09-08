class LocalUser {
  LocalUser({
    required this.name,
    required this.email,
    required this.title,
    required this.reg,
    required this.imageUrl,
    required this.verified,
    // required this.createdAt,
    // required this.updatedAt,
    required this.verifiedBy,
  });

  LocalUser.fromJson(Map<String, Object?> json)
      : this(
          name: json['name']! as String,
          email: json['email']! as String,
          title: json['title']! as String,
          reg: json['reg']! as int,
          imageUrl: json['imageUrl']! as String,
          verified: json['verified']! as bool,
          verifiedBy: json['verifiedBy']! as String,
          // createdAt:
          //     DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
          // updatedAt:
          //     DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
        );

  String name;
  String email;
  String title;
  int reg;
  String imageUrl;
  bool verified;
  String verifiedBy;
  // DateTime createdAt;
  // DateTime updatedAt;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'email': email,
      'title': title,
      'reg': reg,
      'imageUrl': imageUrl,
      'verified': verified,
      // 'createdAt': createdAt,
      // 'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

// 'name': name,
// 'shortName': shortName,
// 'email': email,
// 'title': title,
// 'reg': reg,
// 'imageUrl': url,
// 'verified': false,
// 'createdAt': DateTime.now().millisecondsSinceEpoch,
// 'updatedAt': DateTime.now().millisecondsSinceEpoch,
