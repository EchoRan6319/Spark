// lib/presentation/widgets/inspiration_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../data/models/inspiration.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';

class InspirationCard extends StatelessWidget {
  final Inspiration inspiration;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final int animationIndex;

  const InspirationCard({
    super.key,
    required this.inspiration,
    this.onTap,
    this.onDelete,
    this.onFavorite,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(inspiration.colorValue);
    final emotion = inspiration.emotion;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.05),
              ],
            ),
          ),
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部：情绪 + 收藏
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _EmotionBadge(emotion: emotion, color: color),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (inspiration.isFavorite)
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                      if (inspiration.aiAnalysis != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary.withOpacity(0.8)),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 内容摘要
              Text(
                AppUtils.getSummary(inspiration.content),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // 标签
              if (inspiration.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: inspiration.tags
                      .take(3)
                      .map((tag) => _TagChip(tag: tag, color: color))
                      .toList(),
                ),

              const SizedBox(height: 8),

              // 底部：时间
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppUtils.formatRelativeDate(inspiration.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withOpacity(0.7),
                    ),
                  ),
                  if (inspiration.supplements.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Text(
                          '${inspiration.supplements.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: animationIndex * 60))
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }
}

class _EmotionBadge extends StatelessWidget {
  final String emotion;
  final Color color;

  const _EmotionBadge({required this.emotion, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppUtils.getEmotionEmoji(emotion), style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            AppUtils.getEmotionLabel(emotion),
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  final Color color;

  const _TagChip({required this.tag, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          fontSize: 10,
          color: color.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 大尺寸灵感卡片（用于灵感拾遗页面）
class InspirationHeroCard extends StatelessWidget {
  final Inspiration inspiration;
  final VoidCallback? onTap;

  const InspirationHeroCard({
    super.key,
    required this.inspiration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(inspiration.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(AppUtils.getEmotionEmoji(inspiration.emotion),
                      style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppUtils.getEmotionLabel(inspiration.emotion),
                        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        AppUtils.formatFullDate(inspiration.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                inspiration.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
              if (inspiration.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: inspiration.tags
                      .map((tag) => _TagChip(tag: tag, color: color))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
