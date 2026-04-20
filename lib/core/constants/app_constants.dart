// lib/core/constants/app_constants.dart
import 'package:flutter/material.dart';

class AppColors {
  // 主色调
  static const Color primary = Color(0xFF6366F1); // 紫色
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);

  // 辅助色
  static const Color accent = Color(0xFFF59E0B); // 橙色/琥珀色
  static const Color accentDark = Color(0xFFD97706);
  static const Color accentLight = Color(0xFFFBBF24);

  static const Color pink = Color(0xFFEC4899);
  static const Color blue = Color(0xFF0EA5E9);
  static const Color teal = Color(0xFF14B8A6);
  static const Color green = Color(0xFF10B981);

  // 情绪色彩
  static const Map<String, Color> emotionColors = {
    'excited': Color(0xFFF59E0B),   // 兴奋 - 橙色
    'calm': Color(0xFF0EA5E9),      // 平静 - 蓝色
    'curious': Color(0xFF6366F1),   // 好奇 - 紫色
    'anxious': Color(0xFFEF4444),   // 焦虑 - 红色
    'inspired': Color(0xFFEC4899),  // 灵感 - 粉色
    'neutral': Color(0xFF6B7280),   // 中性 - 灰色
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

  // 渐变背景
  static const List<Color> homeGradient = [
    Color(0xFF1A1040),
    Color(0xFF2D1B69),
    Color(0xFF11204D),
  ];

  static const List<Color> captureGradient = [
    Color(0xFF1C1505),
    Color(0xFF2D1F00),
    Color(0xFF3D2A00),
  ];

  static const List<Color> collectionGradient = [
    Color(0xFF0D0D2B),
    Color(0xFF1A1040),
    Color(0xFF0D1A35),
  ];

  static const List<Color> serendipityGradient = [
    Color(0xFF1A0D2E),
    Color(0xFF2D1040),
    Color(0xFF1A0D35),
  ];

  // 文字颜色
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF94A3B8);

  // 卡片颜色列表（灵感卡片随机颜色）
  static const List<Color> cardColors = [
    Color(0xFF6366F1),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFF14B8A6),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
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
