// lib/core/utils/app_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class AppUtils {
  /// 格式化日期为相对时间（今天、昨天、x天前等）
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) return '刚刚';
        return '${diff.inMinutes}分钟前';
      }
      return '${diff.inHours}小时前';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}周前';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}个月前';
    } else {
      return DateFormat('yyyy年MM月dd日').format(date);
    }
  }

  /// 格式化日期为完整日期字符串
  static String formatFullDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日 HH:mm').format(date);
  }

  /// 格式化日期为短格式
  static String formatShortDate(DateTime date) {
    return DateFormat('MM/dd').format(date);
  }

  /// 获取情绪颜色
  static Color getEmotionColor(String emotion) {
    return AppColors.emotionColors[emotion] ?? AppColors.primary;
  }

  /// 获取情绪 Emoji
  static String getEmotionEmoji(String emotion) {
    return AppColors.emotionEmojis[emotion] ?? '💡';
  }

  /// 获取情绪标签
  static String getEmotionLabel(String emotion) {
    return AppColors.emotionLabels[emotion] ?? emotion;
  }

  /// 根据索引获取卡片颜色
  static Color getCardColor(int index) {
    return AppColors.cardColors[index % AppColors.cardColors.length];
  }

  /// 截取文字，超过指定长度加省略号
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// 计算文字摘要（取前两行或前100个字符）
  static String getSummary(String content) {
    final lines = content.split('\n');
    if (lines.isNotEmpty && lines.first.isNotEmpty) {
      final firstLine = lines.first.trim();
      if (firstLine.length > 80) {
        return '${firstLine.substring(0, 80)}...';
      }
      return firstLine;
    }
    return truncateText(content, 80);
  }

  /// 计算连续记录天数
  static int calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sortedDates = dates.map((d) {
      return DateTime(d.year, d.month, d.day);
    }).toSet().toList()..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    for (final date in sortedDates) {
      if (date == checkDate || date == checkDate.subtract(const Duration(days: 1))) {
        streak++;
        checkDate = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// 显示自定义 SnackBar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        margin: const EdgeInsets.all(AppSizes.paddingL),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }
}
