// lib/presentation/pages/collection/collection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/inspiration_card.dart';

class CollectionPage extends ConsumerStatefulWidget {
  const CollectionPage({super.key});

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(filteredInspirationsProvider);
    final currentEmotion = ref.watch(filterEmotionProvider);

    return GradientBackground(
      colors: AppColors.collectionGradient,
      child: SafeArea(
        child: Column(
          children: [
            // 标题 + 搜索
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 灵感集', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 12),
                  GlassSearchBar(
                    controller: _searchController,
                    placeholder: AppStrings.searchHint,
                    onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                    onSubmitted: (v) => ref.read(searchQueryProvider.notifier).state = v,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms),

            // 情绪筛选
            _buildEmotionFilter(context, ref, currentEmotion),

            // 灵感网格
            Expanded(
              child: filtered.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('加载失败: $e')),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            ref.watch(searchQueryProvider).isEmpty
                                ? '还没有灵感，点击 + 开始记录'
                                : '没有匹配的灵感',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) => InspirationCard(
                      inspiration: list[i],
                      animationIndex: i,
                      onTap: () => context.push('/detail/${list[i].uid}'),
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

  Widget _buildEmotionFilter(BuildContext context, WidgetRef ref, String? currentEmotion) {
    final emotions = ['', ...AppColors.emotionColors.keys];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: emotions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final emotion = emotions[i];
          final isSelected = currentEmotion == (emotion.isEmpty ? null : emotion);
          final color = emotion.isEmpty ? AppColors.primary : AppColors.emotionColors[emotion]!;

          return GestureDetector(
            onTap: () => ref.read(filterEmotionProvider.notifier).state =
                emotion.isEmpty ? null : emotion,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.25) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                border: Border.all(
                  color: isSelected ? color : Colors.white.withOpacity(0.1),
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Text(
                emotion.isEmpty
                    ? '全部'
                    : '${AppColors.emotionEmojis[emotion]} ${AppColors.emotionLabels[emotion]}',
                style: TextStyle(
                  color: isSelected ? color : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 350.ms);
  }
}
