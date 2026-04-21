// lib/presentation/pages/mindmap/mindmap_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/inspiration.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/mindmap_canvas.dart';

class MindmapPage extends ConsumerWidget {
  final String inspirationUid;
  const MindmapPage({super.key, required this.inspirationUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspirationsAsync = ref.watch(inspirationsProvider);
    final mindMapState = ref.watch(mindMapProvider(inspirationUid));

    return inspirationsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('错误: $e'))),
      data: (list) {
        final textSecondary = AppColors.adaptiveTextSecondary(context);
        Inspiration? inspiration;
        try { inspiration = list.firstWhere((i) => i.uid == inspirationUid); } catch (_) {}
        if (inspiration == null) {
          return Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('灵感不存在'), TextButton(onPressed: () => context.pop(), child: const Text('返回')),
          ])));
        }

        return GradientBackground(
          colors: AppColors.mindmapGradientFor(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GlassIconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.arrow_back_ios_rounded, color: textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('思维导图', style: Theme.of(context).textTheme.headlineSmall),
                        ),
                        if (mindMapState.root == null && !mindMapState.isLoading)
                          GlassButton.custom(
                            onTap: () => ref.read(mindMapProvider(inspirationUid).notifier).generate(inspiration!.content),
                            width: 120,
                            height: 40,
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('AI 生成', style: TextStyle(color: Colors.white, fontSize: 13)),
                            ]),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  Expanded(
                    child: mindMapState.isLoading
                        ? Center(
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const CircularProgressIndicator(color: AppColors.primary),
                              const SizedBox(height: 16),
                              Text('AI 正在构建思维导图...', style: Theme.of(context).textTheme.bodyMedium),
                            ]),
                          )
                        : mindMapState.error != null
                            ? Center(
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32),
                                    child: Text(mindMapState.error!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                                  ),
                                  const SizedBox(height: 12),
                                  GlassButton.custom(
                                    onTap: () => ref.read(mindMapProvider(inspirationUid).notifier).generate(inspiration!.content),
                                    width: 80,
                                    height: 40,
                                    child: const Text('重试', style: TextStyle(color: Colors.white)),
                                  ),
                                ]),
                              )
                            : mindMapState.root != null
                                ? MindMapCanvas(root: mindMapState.root!)
                                : _buildEmptyState(context, ref, inspiration),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, Inspiration inspiration) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 64)).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(
            '还没有思维导图',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.adaptiveTextSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              '点击「AI 生成」，让 AI 将你的灵感结构化为思维导图',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          GlassButton.custom(
            onTap: () => ref.read(mindMapProvider(inspirationUid).notifier).generate(inspiration.content),
            width: 180,
            height: 44,
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('AI 生成思维导图', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}
