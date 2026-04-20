// lib/services/storage/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/app_settings.dart';

class SettingsService {
  static const _keyApiKey = 'ai_api_key';
  static const _keyApiBaseUrl = 'ai_api_base_url';
  static const _keyAiModel = 'ai_model';
  static const _keyDarkMode = 'dark_mode';
  static const _keyNotifications = 'notifications';
  static const _keyAutoSaveDraft = 'auto_save_draft';
  static const _keyDraftContent = 'draft_content';
  static const _keyDraftTags = 'draft_tags';
  static const _keyDraftEmotion = 'draft_emotion';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      aiApiKey: prefs.getString(_keyApiKey) ?? '',
      aiApiBaseUrl: prefs.getString(_keyApiBaseUrl) ?? 'https://api.openai.com/v1',
      aiModel: prefs.getString(_keyAiModel) ?? 'gpt-4o-mini',
      isDarkMode: prefs.getBool(_keyDarkMode) ?? true,
      enableNotifications: prefs.getBool(_keyNotifications) ?? true,
      autoSaveDraft: prefs.getBool(_keyAutoSaveDraft) ?? true,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_keyApiKey, settings.aiApiKey),
      prefs.setString(_keyApiBaseUrl, settings.aiApiBaseUrl),
      prefs.setString(_keyAiModel, settings.aiModel),
      prefs.setBool(_keyDarkMode, settings.isDarkMode),
      prefs.setBool(_keyNotifications, settings.enableNotifications),
      prefs.setBool(_keyAutoSaveDraft, settings.autoSaveDraft),
    ]);
  }

  // 草稿管理
  Future<void> saveDraft({
    required String content,
    required List<String> tags,
    required String emotion,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDraftContent, content);
    await prefs.setStringList(_keyDraftTags, tags);
    await prefs.setString(_keyDraftEmotion, emotion);
  }

  Future<Map<String, dynamic>?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final content = prefs.getString(_keyDraftContent);
    if (content == null || content.isEmpty) return null;
    return {
      'content': content,
      'tags': prefs.getStringList(_keyDraftTags) ?? [],
      'emotion': prefs.getString(_keyDraftEmotion) ?? 'neutral',
    };
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDraftContent);
    await prefs.remove(_keyDraftTags);
    await prefs.remove(_keyDraftEmotion);
  }
}
