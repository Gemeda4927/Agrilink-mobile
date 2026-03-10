class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String regionId;
  final String zoneId;
  final String woredaId;
  final String kebeleId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.regionId,
    required this.zoneId,
    required this.woredaId,
    required this.kebeleId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"],
      name: json["name"],
      email: json["email"],
      phone: json["phone"],
      regionId: json["regionId"],
      zoneId: json["zoneId"],
      woredaId: json["woredaId"],
      kebeleId: json["kebeleId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "regionId": regionId,
      "zoneId": zoneId,
      "woredaId": woredaId,
      "kebeleId": kebeleId,
    };
  }
}