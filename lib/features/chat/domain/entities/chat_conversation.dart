/// ================= PROFILE =================
class Profile {
  final String? fullName;

  Profile({this.fullName});
}

/// ================= USER =================
class User {
  final String id;
  final String? phone;
  final String? email;
  final Profile? profile;

  User({
    required this.id,
    this.phone,
    this.email,
    this.profile,
  });
}

/// ================= MESSAGE =================
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });
}

/// ================= CONVERSATION =================
class Conversation {
  final String id;
  final String userOneId;
  final String userTwoId;
  final DateTime createdAt;
  final User userOne;
  final User userTwo;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.userOneId,
    required this.userTwoId,
    required this.createdAt,
    required this.userOne,
    required this.userTwo,
    required this.messages,
  });
}