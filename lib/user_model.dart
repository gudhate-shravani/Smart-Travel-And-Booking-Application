class UserModel {
  String username;
  String fullName;
  String profileImage;
  String bio;

  UserModel({
    required this.username,
    required this.fullName,
    required this.profileImage,
    required this.bio,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'fullName': fullName,
      'profileImage': profileImage,
      'bio': bio,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'],
      fullName: map['fullName'],
      profileImage: map['profileImage'],
      bio: map['bio'],
    );
  }
}
