// lib/presentation/pages/project/project_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/spark_project.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gradient_background.dart';

class ProjectPage extends ConsumerWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return GradientBackground(
      colors: const [Color(0xFF0D1A2E), Color(0xFF0D0820), Color(0xFF071A1A)],
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('🚀 项目管理', style: Theme.of(context).textTheme.headlineLarge),
                  GlassIconButton(
                    onPressed: () => _showCreateDialog(context, ref),
                    icon: const Icon(Icons.add_rounded, color: AppColors.teal),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms),

            Expanded(
              child: projectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('加载失败: $e')),
                data: (projects) {
                  if (projects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🚀', style: TextStyle(fontSize: 56)).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                          const SizedBox(height: 16),
                          Text('还没有项目', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text('从灵感详情页转化，或点击右上角创建', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }

                  final active = projects.where((p) => p.status != 'archived').toList();
                  final archived = projects.where((p) => p.status == 'archived').toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (active.isNotEmpty) ...[
                        _SectionLabel(label: '进行中 (${active.length})'),
                        ...active.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ProjectCard(project: e.value, index: e.key),
                        )),
                      ],
                      if (archived.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _SectionLabel(label: '已归档 (${archived.length})'),
                        ...archived.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ProjectCard(project: e.value, index: e.key, isArchived: true),
                        )),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1040),
        title: const Text('创建项目', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: '项目名称', hintStyle: TextStyle(color: AppColors.textMuted)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: const InputDecoration(hintText: '项目描述（可选）', hintStyle: TextStyle(color: AppColors.textMuted)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                final project = await ref.read(projectsProvider.notifier).create(
                  title: titleController.text.trim(),
                  description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                  colorValue: AppColors.teal.value,
                );
                if (context.mounted) context.push('/project/${project.uid}');
              }
            },
            child: const Text('创建', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      )),
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  final SparkProject project;
  final int index;
  final bool isArchived;

  const _ProjectCard({required this.project, required this.index, this.isArchived = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(project.colorValue);

    return GestureDetector(
      onTap: () => context.push('/project/${project.uid}'),
      child: GlassCard(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.15), color.withOpacity(0.02)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(project.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  _StatusBadge(status: project.status, color: color),
                ],
              ),
              if (project.description != null) ...[
                const SizedBox(height: 6),
                Text(AppUtils.truncateText(project.description!, 60),
                    style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${(project.progress * 100).toInt()}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
              const SizedBox(height: 8),
              Text(AppUtils.formatRelativeDate(project.updatedAt),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: index * 60))
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.1, end: 0),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  static const _labels = {
    'planning': '规划中',
    'in_progress': '进行中',
    'completed': '已完成',
    'archived': '已归档',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
      ),
      child: Text(_labels[status] ?? status,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
