import 'package:study_notebook/app/config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get _baseUrl => AppConfig.backendBaseUrl;

  // Document management
  static String get uploadDocument => '$_baseUrl/api/uploadDocument';
  static String get deleteDocument => '$_baseUrl/api/deleteDocument';
  static String fetchDocument(String documentId) =>
      '$_baseUrl/api/fetchDocument?id=$documentId';

  // AI / RAG
  static String get queryAI =>
      '$_baseUrl/api/agents/documentQ&A/AIQueryRLM';
  static String get predictiveAnalysis =>
      '$_baseUrl/api/agents/predictive-document-analysis';

  // Study agent
  static String get studyAgentChat => '$_baseUrl/api/study-agent/chat';
  static String studyAgentSession(String sessionId) =>
      '$_baseUrl/api/study-agent/me?sessionId=$sessionId';
}
