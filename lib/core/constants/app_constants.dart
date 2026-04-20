// lib/core/constants/app_constants.dart
import 'package:flutter/material.dart';

class AppColors {
  // --- 核心品牌色 (iOS 26 Liquid 风格) ---
  static const Color primary = Color(0xFF007AFF); // Apple Blue
  static const Color primaryLight = Color(0xFF47A1FF);
  static const Color primaryDark = Color(0xFF0056B3);

  // --- 功能色 ---
  static const Color accent = Color(0xFFFF9500); // Apple Orange
  static const Color success = Color(0xFF34C759); // Apple Green
  static const Color error = Color(0xFFFF3B30); // Apple Red
  static const Color warning = Color(0xFFFFCC00); // Apple Yellow
  
  static const Color pink = Color(0xFFFF2D55);
  static const Color blue = Color(0xFF5AC8FA);
  static const Color teal = Color(0xFF5856D6); // Indigo-ish for some elements
  static const Color mint = Color(0xFF00C7BE);

  // --- 语义化背景色 (Dark Mode 默认) ---
  static const Color bgDark = Color(0xFF000000);
  static const Color bgDarkSecondary = Color(0xFF1C1C1E);
  static const Color bgDarkTertiary = Color(0xFF2C2C2E);

  // --- 语义化背景色 (Light Mode) ---
  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color bgLightSecondary = Color(0xFFF2F2F7);
  static const Color bgLightTertiary = Color(0xFFE5E5EA);

  // --- 文字颜色 (Dark Mode) ---
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFEBEBF5); // 60% opacity look
  static const Color textMuted = Color(0xFF8E8E93);

  // --- 文字颜色 (Light Mode) ---
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF3C3C43);
  static const Color textMutedLight = Color(0xFF8E8E93);

  // 情绪色彩 (适配 iOS 26 精致感)
  static const Map<String, Color> emotionColors = {
    'excited': Color(0xFFFF9500),   // 兴奋
    'calm': Color(0xFF007AFF),      // 平静
    'curious': Color(0xFF5856D6),   // 好奇
    'anxious': Color(0xFFFF3B30),   // 焦虑
    'inspired': Color(0xFFFF2D55),  // 灵感
    'neutral': Color(0xFF8E8E93),   // 中性
  };

  static const Map<String, String> emotionEmojis = {
    'excited': '🔥',
    'calm': '😌',
    'curious': '🤔',
    'anxious': '😰',
    'inspired': '✨',
    'neutral': '😐',
  };

  static const Map<String, String> emotionLabels = {
    'excited': '兴奋',
    'calm': '平静',
    'curious': '好奇',
    'anxious': '焦虑',
    'inspired': '灵感',
    'neutral': '中性',
  };

  // 渐变背景 (iOS 26 深邃感)
  static const List<Color> homeGradient = [
    Color(0xFF000000),
    Color(0xFF0A0A1F),
    Color(0xFF000000),
  ];

  static const List<Color> captureGradient = [
    Color(0xFF000000),
    Color(0xFF1F1A00),
    Color(0xFF000000),
  ];

  static const List<Color> collectionGradient = [
    Color(0xFF000000),
    Color(0xFF0A1F1F),
    Color(0xFF000000),
  ];

  static const List<Color> serendipityGradient = [
    Color(0xFF000000),
    Color(0xFF1F0A1F),
    Color(0xFF000000),
  ];

  // 卡片颜色列表 (iOS 系统色)
  static const List<Color> cardColors = [
    Color(0xFF007AFF),
    Color(0xFFFF9500),
    Color(0xFFFF2D55),
    Color(0xFF5AC8FA),
    Color(0xFF34C759),
    Color(0xFF5856D6),
    Color(0xFFAF52DE),
    Color(0xFFFF3B30),
  ];
}

class AppSizes {
  static const double paddingXS = 8.0;
  static const double paddingS = 12.0;
  static const double paddingM = 16.0;
  static const double paddingL = 20.0;
  static const double paddingXL = 24.0;
  static const double paddingXXL = 32.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 28.0;
  static const double radiusCircle = 100.0;

  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;

  // 响应式断点
  static const double mobileMax = 600.0;
  static const double tabletMax = 1024.0;
}

class AppStrings {
  static const String appName = '灵光';
  static const String appSubtitle = 'Spark your creativity';

  // 导航标签
  static const String navHome = '首页';
  static const String navCollection = '灵感集';
  static const String navProjects = '项目';
  static const String navMe = '我的';

  // 页面标题
  static const String titleCapture = '记录灵感';
  static const String titleCollection = '灵感集';
  static const String titleDetail = '灵感详情';
  static const String titleProject = '项目管理';
  static const String titleMindmap = '思维导图';
  static const String titleSerendipity = '灵感拾遗';
  static const String titleSettings = '设置';
  static const String titleAiChat = 'AI 对话';

  // 提示文字
  static const String captureHint = '在这里记录你的灵光一现...';
  static const String searchHint = '搜索灵感...';
  static const String tagHint = '添加标签...';
  static const String noInspirations = '还没有灵感\n点击右下角的 ✨ 按钮开始记录';
  static const String noProjects = '还没有项目\n从灵感详情页转化第一个项目';

  // 操作按钮
  static const String btnSave = '保存灵感';
  static const String btnAnalyze = 'AI 分析';
  static const String btnMindmap = '生成导图';
  static const String btnConvert = '转为项目';
  static const String btnAnother = '换一个';
  static const String btnCancel = '取消';
  static const String btnDelete = '删除';
  static const String btnEdit = '编辑';
  static const String btnExport = '导出';
}

class AppRoutes {
  static const String home = '/';
  static const String capture = '/capture';
  static const String collection = '/collection';
  static const String detail = '/detail/:id';
  static const String project = '/project';
  static const String projectDetail = '/project/:id';
  static const String mindmap = '/mindmap/:id';
  static const String serendipity = '/serendipity';
  static const String settings = '/settings';
  static const String aiChat = '/ai-chat/:id';
}
