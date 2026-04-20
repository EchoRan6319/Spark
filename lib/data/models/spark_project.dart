// lib/data/models/spark_project.dart
import 'package:isar/isar.dart';

part 'spark_project.g.dart';

@collection
class SparkProject {
  Id id = Isar.autoIncrement;

  late String uid;
  late String title;
  String? description;
  late String status; // planning, in_progress, completed, archived
  String? inspirationId; // 来源灵感 ID
  late List<String> taskIds; // SparkTask uid 列表
  late List<String> milestones;
  late int colorValue;
  late DateTime createdAt;
  late DateTime updatedAt;
  double progress = 0.0; // 0.0 ~ 1.0

  SparkProject({
    required this.uid,
    required this.title,
    this.description,
    this.status = 'planning',
    this.inspirationId,
    required this.taskIds,
    required this.milestones,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.progress = 0.0,
  });
}
