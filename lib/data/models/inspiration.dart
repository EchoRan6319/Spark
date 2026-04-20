// lib/data/models/inspiration.dart
import 'package:isar/isar.dart';

part 'inspiration.g.dart';

@collection
class Inspiration {
  Id id = Isar.autoIncrement;

  late String uid; // UUID
  late String content;
  late List<String> tags;
  late String emotion; // excited, calm, curious, anxious, inspired, neutral
  late int colorValue; // Color.value
  late DateTime createdAt;
  late DateTime updatedAt;
  late List<String> supplements; // 补充记录
  late List<String> attachments; // 附件路径
  String? aiAnalysis; // AI 分析结果 JSON
  String? projectId; // 关联的项目 ID
  bool isFavorite = false;

  // 计算属性：颜色
  @ignore
  int get color => colorValue;

  Inspiration({
    required this.uid,
    required this.content,
    required this.tags,
    required this.emotion,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    required this.supplements,
    required this.attachments,
    this.aiAnalysis,
    this.projectId,
    this.isFavorite = false,
  });
}
