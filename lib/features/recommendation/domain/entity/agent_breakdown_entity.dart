import 'source_entity.dart';

class AgentBreakdownEntity {
  final String agentType;
  final String response;
  final double confidence;
  final List<SourceEntity> sources;

  AgentBreakdownEntity({
    required this.agentType,
    required this.response,
    required this.confidence,
    required this.sources,
  });
}