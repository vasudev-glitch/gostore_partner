class GoogleSignInUserData {
  final String displayName;
  final String email;
  final String id;
  final String photoUrl;
  final String idToken;
  final String serverAuthCode;

  GoogleSignInUserData({
    required this.displayName,
    required this.email,
    required this.id,
    required this.photoUrl,
    required this.idToken,
    required this.serverAuthCode,
  });

  factory GoogleSignInUserData.fromJson(Map<String, dynamic> json) {
    return GoogleSignInUserData(
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      id: json['id'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      idToken: json['idToken'] ?? '',
      serverAuthCode: json['serverAuthCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'id': id,
      'photoUrl': photoUrl,
      'idToken': idToken,
      'serverAuthCode': serverAuthCode,
    };
  }
}
