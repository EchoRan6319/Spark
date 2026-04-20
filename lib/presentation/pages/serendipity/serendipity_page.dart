// lib/presentation/pages/serendipity/serendipity_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/inspiration_card.dart';

class SerendipityPage extends ConsumerWidget {
  const SerendipityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final randomAsync = ref.watch(randomInspirationProvider);

    return AnimatedGradientBackground(
      colors: AppColors.serendipityGradient,
      child: SafeArea(
        child: Column(
          children: [
            // 顶部标题
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [AppColors.pink, AppColors.accent],
                    ).createShader(b),
                    child: Text('🌟 灵感拾遗',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 4),
                  Text('重新发现你的创意时光', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            Expanded(
              child: randomAsync.when(
                loading: () => Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const CircularProgressIndicator(color: AppColors.pink),
                    const SizedBox(height: 12),
                    Text('正在翻找灵感...', style: Theme.of(context).textTheme.bodyMedium),
                  ]),
                ),
                error: (e, _) => Center(child: Text('加载失败: $e')),
                data: (inspiration) {
                  if (inspiration == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📭', style: TextStyle(fontSize: 64)).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                          const SizedBox(height: 20),
                          Text('还没有灵感可以拾遗', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text('快去记录你的第一个灵感！', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          GlassButton(
                            onPressed: () => context.push('/capture'),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.add_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text('记录灵感', style: TextStyle(color: Colors.white)),
                            ]),
                          ),
                        ],
                      ),
                    );
                  }

                  final color = Color(inspiration.colorValue);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 来自多久以前的提示
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.history_rounded, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text('来自 ${AppUtils.formatRelativeDate(inspiration.createdAt)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                          ]),
                        ).animate().fadeIn(duration: 300.ms),

                        const SizedBox(height: 20),

                        // 灵感卡片（大号）
                        InspirationHeroCard(
                          inspiration: inspiration,
                          onTap: () => context.push('/detail/${inspiration.uid}'),
                        ).animate()
                            .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                            .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOut),

                        const SizedBox(height: 24),

                        // 操作按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GlassButton(
                              onPressed: () => context.push('/detail/${inspiration.uid}'),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.open_in_new_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('查看详情', style: TextStyle(color: Colors.white)),
                              ]),
                            ),
                            const SizedBox(width: 12),
                            GlassButton(
                              onPressed: () => ref.read(randomInspirationProvider.notifier).loadRandom(),
                              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.shuffle_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('换一个', style: TextStyle(color: Colors.white)),
                              ]),
                            ),
                          ],
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
