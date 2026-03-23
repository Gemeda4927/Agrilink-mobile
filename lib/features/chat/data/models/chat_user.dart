
class ChatUserModel {
  final String id;
  final String? phone;
  final String email;
  final Map<String, dynamic>? profile;
  final String? fullName;

  ChatUserModel({
    required this.id,
    this.phone,
    required this.email,
    this.profile,
    this.fullName,
  });

  /// Convert JSON to Model
  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    // Extract fullName from profile if available
    String? extractedFullName;
    if (json['profile'] != null && json['profile']['fullName'] != null) {
      extractedFullName = json['profile']['fullName'];
    }

    return ChatUserModel(
      id: json['id'] ?? '',
      phone: json['phone'],
      email: json['email'] ?? '',
      profile: json['profile'],
      fullName: extractedFullName,
    );
  }

  /// Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'profile': profile,
    };
  }
}