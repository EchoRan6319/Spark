// lib/services/ai/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiAnalysisResult {
  final double feasibility; // 0.0 ~ 1.0
  final double potential;   // 0.0 ~ 1.0
  final double risk;        // 0.0 ~ 1.0
  final String summary;
  final List<String> strengths;
  final List<String> challenges;
  final List<String> actionPlan;

  const AiAnalysisResult({
    required this.feasibility,
    required this.potential,
    required this.risk,
    required this.summary,
    required this.strengths,
    required this.challenges,
    required this.actionPlan,
  });

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResult(
      feasibility: (json['feasibility'] as num?)?.toDouble() ?? 0.7,
      potential: (json['potential'] as num?)?.toDouble() ?? 0.7,
      risk: (json['risk'] as num?)?.toDouble() ?? 0.3,
      summary: json['summary'] as String? ?? '',
      strengths: List<String>.from(json['strengths'] ?? []),
      challenges: List<String>.from(json['challenges'] ?? []),
      actionPlan: List<String>.from(json['actionPlan'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'feasibility': feasibility,
    'potential': potential,
    'risk': risk,
    'summary': summary,
    'strengths': strengths,
    'challenges': challenges,
    'actionPlan': actionPlan,
  };
}

class MindMapNode {
  final String id;
  final String label;
  final int level;
  final List<MindMapNode> children;

  const MindMapNode({
    required this.id,
    required this.label,
    required this.level,
    this.children = const [],
  });

  factory MindMapNode.fromJson(Map<String, dynamic> json) {
    return MindMapNode(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      children: (json['children'] as List<dynamic>?)
              ?.map((c) => MindMapNode.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'level': level,
    'children': children.map((c) => c.toJson()).toList(),
  };
}

class ChatMessage {
  final String role; // user, assistant
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

class AiService {
  String _apiKey;
  String _apiBaseUrl;
  String _model;

  AiService({
    String apiKey = '',
    String apiBaseUrl = 'https://api.openai.com/v1',
    String model = 'gpt-4o-mini',
  })  : _apiKey = apiKey,
        _apiBaseUrl = apiBaseUrl,
        _model = model;

  void updateConfig({String? apiKey, String? apiBaseUrl, String? model}) {
    if (apiKey != null) _apiKey = apiKey;
    if (apiBaseUrl != null) _apiBaseUrl = apiBaseUrl;
    if (model != null) _model = model;
  }

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<Map<String, dynamic>> _callApi(List<Map<String, String>> messages) async {
    if (!isConfigured) {
      throw Exception('请先在设置中配置 AI API Key');
    }

    final response = await http.post(
      Uri.parse('$_apiBaseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 2000,
      }),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception('AI 服务错误 (${response.statusCode}): ${error['error']?['message'] ?? '未知错误'}');
    }
  }

  String _extractContent(Map<String, dynamic> data) {
    return data['choices'][0]['message']['content'] as String;
  }

  /// 创意评估：分析灵感的可行性、潜力、风险
  Future<AiAnalysisResult> analyzeInspiration(String content) async {
    final messages = [
      {
        'role': 'system',
        'content': '''你是一个创意分析专家。请分析用户的想法，以JSON格式返回分析结果。
返回格式：
{
  "feasibility": 0.0-1.0的数值（可行性），
  "potential": 0.0-1.0的数值（潜力），
  "risk": 0.0-1.0的数值（风险），
  "summary": "简洁的评估总结（2-3句话）",
  "strengths": ["优势1", "优势2", "优势3"],
  "challenges": ["挑战1", "挑战2"],
  "actionPlan": ["第一步", "第二步", "第三步", "第四步", "第五步"]
}
请只返回JSON，不要其他内容。''',
      },
      {
        'role': 'user',
        'content': '请分析这个创意想法：\n\n$content',
      },
    ];

    try {
      final data = await _callApi(messages);
      final content = _extractContent(data);
      // 清理可能的 markdown 代码块
      final cleaned = content
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return AiAnalysisResult.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }

  /// 生成思维导图结构
  Future<MindMapNode> generateMindMap(String content) async {
    final messages = [
      {
        'role': 'system',
        'content': '''你是思维导图专家。请将用户的创意转化为层级思维导图结构，以JSON返回。
格式：
{
  "id": "root",
  "label": "核心主题（简短）",
  "level": 0,
  "children": [
    {
      "id": "1",
      "label": "一级主题",
      "level": 1,
      "children": [
        {"id": "1-1", "label": "子主题", "level": 2, "children": []}
      ]
    }
  ]
}
要求：3-5个一级节点，每个节点2-3个子节点，标签简洁（10字以内）。只返回JSON。''',
      },
      {
        'role': 'user',
        'content': '为以下创意生成思维导图：\n\n$content',
      },
    ];

    final data = await _callApi(messages);
    final responseContent = _extractContent(data);
    final cleaned = responseContent
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final json = jsonDecode(cleaned) as Map<String, dynamic>;
    return MindMapNode.fromJson(json);
  }

  /// AI 对话
  Future<String> chat(String inspirationContent, List<ChatMessage> history, String userMessage) async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': '你是一个创意顾问，正在帮助用户深入探讨以下创意想法：\n\n$inspirationContent\n\n请提供建设性的建议和想法，语言简洁友好。',
      },
      ...history.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': userMessage},
    ];

    final data = await _callApi(messages);
    return _extractContent(data);
  }

  /// 生成行动计划
  Future<List<String>> generateActionPlan(String content) async {
    final messages = [
      {
        'role': 'system',
        'content': '你是一个执行规划专家。请为用户的创意生成具体可执行的行动计划，以JSON数组返回（每个元素是一个具体步骤，10-30字）。只返回JSON数组。',
      },
      {
        'role': 'user',
        'content': '为以下创意生成行动计划：\n\n$content',
      },
    ];

    final data = await _callApi(messages);
    final responseContent = _extractContent(data);
    final cleaned = responseContent
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final list = jsonDecode(cleaned) as List<dynamic>;
    return list.cast<String>();
  }
}
