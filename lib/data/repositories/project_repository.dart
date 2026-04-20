// lib/data/repositories/project_repository.dart
import 'package:uuid/uuid.dart';
import '../datasources/isar_datasource.dart';
import '../models/spark_project.dart';
import '../models/spark_task.dart';
import '../../core/constants/app_constants.dart';

class ProjectRepository {
  final IsarDatasource _db;
  final _uuid = const Uuid();

  ProjectRepository(this._db);

  Future<List<SparkProject>> getAll() => _db.getAllProjects();

  Future<SparkProject?> getByUid(String uid) => _db.getProjectByUid(uid);

  Future<List<SparkTask>> getTasksForProject(String projectId) =>
      _db.getTasksByProject(projectId);

  Future<SparkProject> create({
    required String title,
    String? description,
    String? inspirationId,
    int? colorValue,
  }) async {
    final now = DateTime.now();
    final project = SparkProject(
      uid: _uuid.v4(),
      title: title,
      description: description,
      status: 'planning',
      inspirationId: inspirationId,
      taskIds: [],
      milestones: [],
      colorValue: colorValue ?? AppColors.primary.value,
      createdAt: now,
      updatedAt: now,
    );
    await _db.saveProject(project);
    return project;
  }

  Future<SparkTask> addTask({
    required String projectId,
    required String title,
    String? description,
    String priority = 'medium',
    DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    final task = SparkTask(
      uid: _uuid.v4(),
      projectId: projectId,
      title: title,
      description: description,
      status: 'todo',
      priority: priority,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
    await _db.saveTask(task);

    // 更新项目的 taskIds
    final project = await _db.getProjectByUid(projectId);
    if (project != null) {
      project.taskIds = [...project.taskIds, task.uid];
      project.updatedAt = now;
      await _db.saveProject(project);
    }

    return task;
  }

  Future<void> updateTaskStatus(SparkTask task, String newStatus) async {
    task.status = newStatus;
    task.isCompleted = newStatus == 'done';
    task.updatedAt = DateTime.now();
    await _db.saveTask(task);

    // 更新项目进度
    await _updateProjectProgress(task.projectId);
  }

  Future<void> _updateProjectProgress(String projectId) async {
    final project = await _db.getProjectByUid(projectId);
    if (project == null) return;

    final tasks = await _db.getTasksByProject(projectId);
    if (tasks.isEmpty) {
      project.progress = 0.0;
    } else {
      final completed = tasks.where((t) => t.isCompleted).length;
      project.progress = completed / tasks.length;
    }
    await _db.saveProject(project);
  }

  Future<void> updateProjectStatus(String uid, String status) async {
    final project = await _db.getProjectByUid(uid);
    if (project != null) {
      project.status = status;
      project.updatedAt = DateTime.now();
      await _db.saveProject(project);
    }
  }

  Future<void> delete(int id) async {
    final project = await _db.isar.sparkProjects.get(id);
    if (project != null) {
      await _db.deleteTasksByProject(project.uid);
    }
    await _db.deleteProject(id);
  }

  Future<void> deleteTask(int id) => _db.deleteTask(id);
}
