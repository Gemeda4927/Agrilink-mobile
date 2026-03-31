class ConversationModel {
  final String id;
  final String userOneId;
  final String userTwoId;
  final DateTime createdAt;
  final UserModel userOne;
  final UserModel userTwo;
  final List<MessageModel> messages;

  ConversationModel({
    required this.id,
    required this.userOneId,
    required this.userTwoId,
    required this.createdAt,
    required this.userOne,
    required this.userTwo,
    required this.messages,
  });

  ConversationModel copyWith({
    String? id,
    String? userOneId,
    String? userTwoId,
    DateTime? createdAt,
    UserModel? userOne,
    UserModel? userTwo,
    List<MessageModel>? messages,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userOneId: userOneId ?? this.userOneId,
      userTwoId: userTwoId ?? this.userTwoId,
      createdAt: createdAt ?? this.createdAt,
      userOne: userOne ?? this.userOne,
      userTwo: userTwo ?? this.userTwo,
      messages: messages ?? this.messages,
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      userOneId: json['userOneId'],
      userTwoId: json['userTwoId'],
      createdAt: DateTime.parse(json['createdAt']),
      userOne: UserModel.fromJson(json['userOne']),
      userTwo: UserModel.fromJson(json['userTwo']),
      messages: (json['messages'] as List)
          .map((e) => MessageModel.fromJson(e))
          .toList(),
    );
  }
}
// ================= USER =================
class UserModel {
  final String id;
  final String? phone;
  final String? email;
  final ProfileModel? profile;

  UserModel({
    required this.id,
    this.phone,
    this.email,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      email: json['email'],
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'])
          : null,
    );
  }
}

// ================= PROFILE =================
class ProfileModel {
  final String? fullName;

  ProfileModel({this.fullName});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      fullName: json['fullName'],
    );
  }
}

// ================= MESSAGE =================
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}