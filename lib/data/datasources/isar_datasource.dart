// lib/data/datasources/isar_datasource.dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/inspiration.dart';
import '../models/spark_task.dart';
import '../models/spark_project.dart';

class IsarDatasource {
  static IsarDatasource? _instance;
  late Isar _isar;

  IsarDatasource._();

  static IsarDatasource get instance {
    _instance ??= IsarDatasource._();
    return _instance!;
  }

  Future<void> initialize({String dbName = 'spark_db'}) async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        InspirationSchema,
        SparkTaskSchema,
        SparkProjectSchema,
      ],
      directory: dir.path,
      name: dbName,
    );
  }

  Isar get isar => _isar;

  // === Inspiration CRUD ===

  Future<List<Inspiration>> getAllInspirations() async {
    return _isar.inspirations
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<Inspiration?> getInspirationByUid(String uid) async {
    return _isar.inspirations.filter().uidEqualTo(uid).findFirst();
  }

  Future<List<Inspiration>> searchInspirations(String query) async {
    final lower = query.toLowerCase();
    return _isar.inspirations
        .filter()
        .contentContains(lower, caseSensitive: false)
        .findAll();
  }

  Future<List<Inspiration>> getInspirationsByEmotion(String emotion) async {
    return _isar.inspirations
        .filter()
        .emotionEqualTo(emotion)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<void> saveInspiration(Inspiration inspiration) async {
    await _isar.writeTxn(() async {
      await _isar.inspirations.put(inspiration);
    });
  }

  Future<void> deleteInspiration(int id) async {
    await _isar.writeTxn(() async {
      await _isar.inspirations.delete(id);
    });
  }

  Future<Inspiration?> getRandomInspiration() async {
    final count = await _isar.inspirations.count();
    if (count == 0) return null;
    final offset = (count * (DateTime.now().millisecond / 1000)).floor() % count;
    return _isar.inspirations.where().offset(offset).limit(1).findFirst();
  }

  // === SparkProject CRUD ===

  Future<List<SparkProject>> getAllProjects() async {
    return _isar.sparkProjects
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<SparkProject?> getProjectByUid(String uid) async {
    return _isar.sparkProjects.filter().uidEqualTo(uid).findFirst();
  }

  Future<void> saveProject(SparkProject project) async {
    await _isar.writeTxn(() async {
      await _isar.sparkProjects.put(project);
    });
  }

  Future<void> deleteProject(int id) async {
    await _isar.writeTxn(() async {
      await _isar.sparkProjects.delete(id);
    });
  }

  // === SparkTask CRUD ===

  Future<List<SparkTask>> getTasksByProject(String projectId) async {
    return _isar.sparkTasks
        .filter()
        .projectIdEqualTo(projectId)
        .sortByCreatedAt()
        .findAll();
  }

  Future<void> saveTask(SparkTask task) async {
    await _isar.writeTxn(() async {
      await _isar.sparkTasks.put(task);
    });
  }

  Future<void> deleteTask(int id) async {
    await _isar.writeTxn(() async {
      await _isar.sparkTasks.delete(id);
    });
  }

  Future<void> deleteTasksByProject(String projectId) async {
    await _isar.writeTxn(() async {
      await _isar.sparkTasks
          .filter()
          .projectIdEqualTo(projectId)
          .deleteAll();
    });
  }
}
