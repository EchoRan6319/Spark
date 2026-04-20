// lib/presentation/providers/app_providers.dart
// 集中管理所有 Riverpod Providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/isar_datasource.dart';
import '../../data/models/inspiration.dart';
import '../../data/models/spark_project.dart';
import '../../data/models/spark_task.dart';
import '../../data/models/app_settings.dart';
import '../../data/repositories/inspiration_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../services/ai/ai_service.dart';
import '../../services/storage/settings_service.dart';

// ============================================================
// Infrastructure Providers
// ============================================================

final isarDatasourceProvider = Provider<IsarDatasource>((ref) {
  return IsarDatasource.instance;
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final aiServiceProvider = Provider<AiService>((ref) {
  final settings = ref.watch(settingsProvider).value;
  if (settings == null) return AiService();
  return AiService(
    apiKey: settings.aiApiKey,
    apiBaseUrl: settings.aiApiBaseUrl,
    model: settings.aiModel,
  );
});

// ============================================================
// Repository Providers
// ============================================================

final inspirationRepositoryProvider = Provider<InspirationRepository>((ref) {
  return InspirationRepository(ref.read(isarDatasourceProvider));
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(ref.read(isarDatasourceProvider));
});

// ============================================================
// Settings Provider
// ============================================================

final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  return SettingsNotifier(ref.read(settingsServiceProvider));
});

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsService _service;

  SettingsNotifier(this._service) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await _service.load();
      state = AsyncValue.data(settings);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> update(AppSettings settings) async {
    await _service.save(settings);
    state = AsyncValue.data(settings);
  }

  Future<void> updateApiConfig({
    required String apiKey,
    required String apiBaseUrl,
    required String model,
  }) async {
    final current = state.value ?? const AppSettings();
    await update(current.copyWith(
      aiApiKey: apiKey,
      aiApiBaseUrl: apiBaseUrl,
      aiModel: model,
    ));
  }
}

// ============================================================
// Inspiration Providers
// ============================================================

final inspirationsProvider = StateNotifierProvider<InspirationNotifier, AsyncValue<List<Inspiration>>>((ref) {
  return InspirationNotifier(ref.read(inspirationRepositoryProvider));
});

class InspirationNotifier extends StateNotifier<AsyncValue<List<Inspiration>>> {
  final InspirationRepository _repo;

  InspirationNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repo.getAll();
      state = AsyncValue.data(list);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> add({
    required String content,
    required List<String> tags,
    required String emotion,
    required int colorValue,
  }) async {
    await _repo.create(
      content: content,
      tags: tags,
      emotion: emotion,
      colorValue: colorValue,
    );
    await loadAll();
  }

  Future<void> update(Inspiration inspiration) async {
    await _repo.update(inspiration);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await loadAll();
  }

  Future<void> toggleFavorite(String uid) async {
    await _repo.toggleFavorite(uid);
    await loadAll();
  }

  Future<void> addSupplement(String uid, String supplement) async {
    await _repo.addSupplement(uid, supplement);
    await loadAll();
  }

  Future<void> saveAiAnalysis(String uid, String analysisJson) async {
    await _repo.saveAiAnalysis(uid, analysisJson);
    await loadAll();
  }
}

// 搜索和过滤
final searchQueryProvider = StateProvider<String>((ref) => '');
final filterEmotionProvider = StateProvider<String?>((ref) => null);

final filteredInspirationsProvider = Provider<AsyncValue<List<Inspiration>>>((ref) {
  final all = ref.watch(inspirationsProvider);
  final query = ref.watch(searchQueryProvider);
  final emotion = ref.watch(filterEmotionProvider);

  return all.whenData((list) {
    var filtered = list;
    if (query.isNotEmpty) {
      filtered = filtered.where((i) =>
        i.content.toLowerCase().contains(query.toLowerCase()) ||
        i.tags.any((t) => t.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }
    if (emotion != null && emotion.isNotEmpty) {
      filtered = filtered.where((i) => i.emotion == emotion).toList();
    }
    return filtered;
  });
});

// 随机灵感
final randomInspirationProvider = StateNotifierProvider<RandomInspirationNotifier, AsyncValue<Inspiration?>>((ref) {
  return RandomInspirationNotifier(ref.read(inspirationRepositoryProvider));
});

class RandomInspirationNotifier extends StateNotifier<AsyncValue<Inspiration?>> {
  final InspirationRepository _repo;

  RandomInspirationNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadRandom();
  }

  Future<void> loadRandom() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 300));
    final inspiration = await _repo.getRandom();
    state = AsyncValue.data(inspiration);
  }
}

// ============================================================
// Project Providers
// ============================================================

final projectsProvider = StateNotifierProvider<ProjectNotifier, AsyncValue<List<SparkProject>>>((ref) {
  return ProjectNotifier(ref.read(projectRepositoryProvider));
});

class ProjectNotifier extends StateNotifier<AsyncValue<List<SparkProject>>> {
  final ProjectRepository _repo;

  ProjectNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repo.getAll();
      state = AsyncValue.data(list);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<SparkProject> create({
    required String title,
    String? description,
    String? inspirationId,
    int? colorValue,
  }) async {
    final project = await _repo.create(
      title: title,
      description: description,
      inspirationId: inspirationId,
      colorValue: colorValue,
    );
    await loadAll();
    return project;
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await loadAll();
  }

  Future<void> updateStatus(String uid, String status) async {
    await _repo.updateProjectStatus(uid, status);
    await loadAll();
  }
}

// Tasks per project
final projectTasksProvider = FutureProvider.family<List<SparkTask>, String>((ref, projectId) {
  return ref.read(projectRepositoryProvider).getTasksForProject(projectId);
});

// ============================================================
// AI Providers
// ============================================================

class AiAnalysisState {
  final bool isLoading;
  final AiAnalysisResult? result;
  final String? error;

  const AiAnalysisState({
    this.isLoading = false,
    this.result,
    this.error,
  });
}

final aiAnalysisProvider = StateNotifierProvider.family<AiAnalysisNotifier, AiAnalysisState, String>(
  (ref, inspirationUid) => AiAnalysisNotifier(
    ref.read(aiServiceProvider),
    ref.read(inspirationRepositoryProvider),
    inspirationUid,
  ),
);

class AiAnalysisNotifier extends StateNotifier<AiAnalysisState> {
  final AiService _aiService;
  final InspirationRepository _inspirationRepo;
  final String _inspirationUid;

  AiAnalysisNotifier(this._aiService, this._inspirationRepo, this._inspirationUid)
      : super(const AiAnalysisState());

  Future<void> analyze(String content) async {
    state = const AiAnalysisState(isLoading: true);
    try {
      final result = await _aiService.analyzeInspiration(content);
      await _inspirationRepo.saveAiAnalysis(
        _inspirationUid,
        result.toJson().toString(),
      );
      state = AiAnalysisState(result: result);
    } catch (e) {
      state = AiAnalysisState(error: e.toString());
    }
  }
}

// AI Chat state per inspiration
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final aiChatProvider = StateNotifierProvider.family<AiChatNotifier, ChatState, String>(
  (ref, inspirationUid) => AiChatNotifier(ref.read(aiServiceProvider), inspirationUid),
);

class AiChatNotifier extends StateNotifier<ChatState> {
  final AiService _aiService;
  final String _inspirationUid;
  String? _inspirationContent;

  AiChatNotifier(this._aiService, this._inspirationUid) : super(const ChatState());

  void setInspirationContent(String content) {
    _inspirationContent = content;
  }

  Future<void> sendMessage(String message) async {
    final userMessage = ChatMessage(
      role: 'user',
      content: message,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final reply = await _aiService.chat(
        _inspirationContent ?? '',
        state.messages,
        message,
      );
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: reply,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// MindMap generation
class MindMapState {
  final bool isLoading;
  final MindMapNode? root;
  final String? error;

  const MindMapState({this.isLoading = false, this.root, this.error});
}

final mindMapProvider = StateNotifierProvider.family<MindMapNotifier, MindMapState, String>(
  (ref, inspirationUid) => MindMapNotifier(ref.read(aiServiceProvider)),
);

class MindMapNotifier extends StateNotifier<MindMapState> {
  final AiService _aiService;

  MindMapNotifier(this._aiService) : super(const MindMapState());

  Future<void> generate(String content) async {
    state = const MindMapState(isLoading: true);
    try {
      final root = await _aiService.generateMindMap(content);
      state = MindMapState(root: root);
    } catch (e) {
      state = MindMapState(error: e.toString());
    }
  }

  void setManualRoot(MindMapNode root) {
    state = MindMapState(root: root);
  }
}
