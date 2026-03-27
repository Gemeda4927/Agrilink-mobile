class ChatRequestModel {
  final String message;
  final String? location;

  ChatRequestModel({
    required this.message,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "location": location,
    };
  }
}