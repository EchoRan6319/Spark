// lib/data/repositories/inspiration_repository.dart
import 'package:uuid/uuid.dart';
import '../datasources/isar_datasource.dart';
import '../models/inspiration.dart';
import '../../core/constants/app_constants.dart';

class InspirationRepository {
  final IsarDatasource _db;
  final _uuid = const Uuid();

  InspirationRepository(this._db);

  Future<List<Inspiration>> getAll() => _db.getAllInspirations();

  Future<Inspiration?> getByUid(String uid) => _db.getInspirationByUid(uid);

  Future<List<Inspiration>> search(String query) => _db.searchInspirations(query);

  Future<List<Inspiration>> filterByEmotion(String emotion) =>
      _db.getInspirationsByEmotion(emotion);

  Future<Inspiration?> getRandom() => _db.getRandomInspiration();

  Future<Inspiration> create({
    required String content,
    required List<String> tags,
    required String emotion,
    required int colorValue,
  }) async {
    final now = DateTime.now();
    final inspiration = Inspiration(
      uid: _uuid.v4(),
      content: content,
      tags: tags,
      emotion: emotion,
      colorValue: colorValue,
      createdAt: now,
      updatedAt: now,
      supplements: [],
      attachments: [],
    );
    await _db.saveInspiration(inspiration);
    return inspiration;
  }

  Future<void> update(Inspiration inspiration) async {
    inspiration.updatedAt = DateTime.now();
    await _db.saveInspiration(inspiration);
  }

  Future<void> addSupplement(String uid, String supplement) async {
    final inspiration = await _db.getInspirationByUid(uid);
    if (inspiration != null) {
      inspiration.supplements = [...inspiration.supplements, supplement];
      inspiration.updatedAt = DateTime.now();
      await _db.saveInspiration(inspiration);
    }
  }

  Future<void> saveAiAnalysis(String uid, String analysisJson) async {
    final inspiration = await _db.getInspirationByUid(uid);
    if (inspiration != null) {
      inspiration.aiAnalysis = analysisJson;
      inspiration.updatedAt = DateTime.now();
      await _db.saveInspiration(inspiration);
    }
  }

  Future<void> toggleFavorite(String uid) async {
    final inspiration = await _db.getInspirationByUid(uid);
    if (inspiration != null) {
      inspiration.isFavorite = !inspiration.isFavorite;
      await _db.saveInspiration(inspiration);
    }
  }

  Future<void> delete(int id) => _db.deleteInspiration(id);

  /// 获取下一个随机卡片颜色
  Future<int> getNextCardColor() async {
    final count = await _db.isar.inspirations.count();
    return AppColors.cardColors[count % AppColors.cardColors.length].value;
  }
}
