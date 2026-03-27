import 'package:agrilink/features/recommendation/data/model/source_model.dart';

class AgentBreakdown {
  final String agentType;
  final String response;
  final double confidence;
  final List<SourceModel> sources;

  AgentBreakdown({
    required this.agentType,
    required this.response,
    required this.confidence,
    required this.sources,
  });

  factory AgentBreakdown.fromJson(Map<String, dynamic> json) {
    return AgentBreakdown(
      agentType: json['agent_type'] ?? '',
      response: json['response'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      sources: (json['sources'] as List<dynamic>? ?? [])
          .map((e) => SourceModel.fromJson(e))
          .toList(),
    );
  }
}