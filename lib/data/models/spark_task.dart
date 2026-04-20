// lib/data/models/spark_task.dart
import 'package:isar/isar.dart';

part 'spark_task.g.dart';

@collection
class SparkTask {
  Id id = Isar.autoIncrement;

  late String uid;
  late String projectId;
  late String title;
  String? description;
  late String status; // todo, in_progress, done
  late String priority; // low, medium, high
  DateTime? dueDate;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isCompleted = false;

  SparkTask({
    required this.uid,
    required this.projectId,
    required this.title,
    this.description,
    this.status = 'todo',
    this.priority = 'medium',
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
  });
}
