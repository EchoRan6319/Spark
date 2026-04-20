// lib/data/models/app_settings.dart
// 使用 shared_preferences 存储设置，不需要 Isar

class AppSettings {
  final String aiApiKey;
  final String aiApiBaseUrl;
  final String aiModel;
  final bool isDarkMode;
  final bool enableNotifications;
  final bool autoSaveDraft;

  const AppSettings({
    this.aiApiKey = '',
    this.aiApiBaseUrl = 'https://api.openai.com/v1',
    this.aiModel = 'gpt-4o-mini',
    this.isDarkMode = true,
    this.enableNotifications = true,
    this.autoSaveDraft = true,
  });

  AppSettings copyWith({
    String? aiApiKey,
    String? aiApiBaseUrl,
    String? aiModel,
    bool? isDarkMode,
    bool? enableNotifications,
    bool? autoSaveDraft,
  }) {
    return AppSettings(
      aiApiKey: aiApiKey ?? this.aiApiKey,
      aiApiBaseUrl: aiApiBaseUrl ?? this.aiApiBaseUrl,
      aiModel: aiModel ?? this.aiModel,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      autoSaveDraft: autoSaveDraft ?? this.autoSaveDraft,
    );
  }

  Map<String, dynamic> toMap() => {
    'aiApiKey': aiApiKey,
    'aiApiBaseUrl': aiApiBaseUrl,
    'aiModel': aiModel,
    'isDarkMode': isDarkMode,
    'enableNotifications': enableNotifications,
    'autoSaveDraft': autoSaveDraft,
  };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
    aiApiKey: map['aiApiKey'] ?? '',
    aiApiBaseUrl: map['aiApiBaseUrl'] ?? 'https://api.openai.com/v1',
    aiModel: map['aiModel'] ?? 'gpt-4o-mini',
    isDarkMode: map['isDarkMode'] ?? true,
    enableNotifications: map['enableNotifications'] ?? true,
    autoSaveDraft: map['autoSaveDraft'] ?? true,
  );
}
