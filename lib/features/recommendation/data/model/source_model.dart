class SourceModel {
  final String type;
  final String name;
  final String provider;

  SourceModel({
    required this.type,
    required this.name,
    required this.provider,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      provider: json['provider'] ?? '',
    );
  }
}