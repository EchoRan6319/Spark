// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/inspiration.dart';
import '../../../data/models/spark_project.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gradient_background.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspirationsAsync = ref.watch(inspirationsProvider);
    final projectsAsync = ref.watch(projectsProvider);

    return AnimatedGradientBackground(
      colors: AppColors.homeGradientFor(context),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(
              child: inspirationsAsync.when(
                loading: () => const SizedBox(),
                error: (e, _) => const SizedBox(),
                data: (list) => _buildStats(context, list, ref),
              ),
            ),
            SliverToBoxAdapter(
              child: projectsAsync.when(
                loading: () => const SizedBox(),
                error: (e, _) => const SizedBox(),
                data: (projects) => _buildProjects(context, projects),
              ),
            ),
            SliverToBoxAdapter(
              child: inspirationsAsync.when(
                loading: () => const SizedBox(),
                error: (e, _) => const SizedBox(),
                data: (list) => _buildRecent(context, list),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isDark
                      ? const [AppColors.primaryLight, AppColors.pink]
                      : const [AppColors.primaryDark, AppColors.pink],
                ).createShader(bounds),
                child: Text('✨ 灵光',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.adaptiveTextPrimary(context),
                          fontWeight: FontWeight.w800,
                        )),
              ),
              Text(
                '${AppUtils.formatShortDate(DateTime.now())} · 今天是充满灵光的一天',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          GlassIconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings_outlined,
                color: AppColors.adaptiveTextSecondary(context)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildStats(
      BuildContext context, List<Inspiration> list, WidgetRef ref) {
    final streak =
        AppUtils.calculateStreak(list.map((i) => i.createdAt).toList());
    final projectCount = ref.watch(projectsProvider).value?.length ?? 0;
    final dividerColor = AppColors.isDark(context)
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.08);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.bar_chart_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('创意统计', style: Theme.of(context).textTheme.titleMedium),
              ]),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                      value: '${list.length}',
                      label: '灵感数',
                      color: AppColors.primary),
                  Container(width: 1, height: 40, color: dividerColor),
                  _StatItem(
                      value: '$projectCount',
                      label: '项目数',
                      color: AppColors.teal),
                  Container(width: 1, height: 40, color: dividerColor),
                  _StatItem(
                      value: '$streak', label: '连续天', color: AppColors.accent),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildProjects(BuildContext context, List<SparkProject> projects) {
    final active = projects
        .where((p) => p.status == 'in_progress' || p.status == 'planning')
        .toList();
    if (active.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: '🚀 进行中的项目',
              color: AppColors.teal,
              onMore: () => context.go('/project')),
          const SizedBox(height: 8),
          ...active.take(3).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => context.push('/project/${p.uid}'),
                  child: GlassListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(p.colorValue).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.folder_rounded,
                          color: Color(p.colorValue), size: 18),
                    ),
                    title: Text(p.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.adaptiveTextPrimary(context),
                        )),
                    subtitle: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: p.progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(p.colorValue)),
                        minHeight: 4,
                      ),
                    ),
                    trailing: Text('${(p.progress * 100).toInt()}%',
                        style: TextStyle(
                            color: Color(p.colorValue),
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ),
                ),
              )),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildRecent(BuildContext context, List<Inspiration> list) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Text('✨', style: TextStyle(fontSize: 64))
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text('还没有灵感',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('点击下方 + 按钮开始记录你的第一个灵感！',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: '💡 最近的灵感',
              color: AppColors.accent,
              onMore: () => context.go('/collection')),
          const SizedBox(height: 8),
          ...list.take(3).map((insp) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => context.push('/detail/${insp.uid}'),
                  child: GlassListTile(
                    leading: Text(AppUtils.getEmotionEmoji(insp.emotion),
                        style: const TextStyle(fontSize: 22)),
                    title: Text(AppUtils.getSummary(insp.content),
                        style: TextStyle(
                          color: AppColors.adaptiveTextPrimary(context),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    subtitle: Text(AppUtils.formatRelativeDate(insp.createdAt),
                        style: TextStyle(
                            color: Color(insp.colorValue).withOpacity(0.7),
                            fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 12, color: AppColors.textMuted),
                  ),
                ),
              )),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatItem(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 2),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onMore;
  const _SectionHeader({required this.title, required this.color, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (onMore != null)
          GestureDetector(
            onTap: onMore,
            child: Text('查看全部 →',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.primary)),
          ),
      ],
    );
  }
}
