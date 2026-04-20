// lib/presentation/pages/project/project_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/spark_project.dart';
import '../../../data/models/spark_task.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gradient_background.dart';

class ProjectDetailPage extends ConsumerStatefulWidget {
  final String projectUid;
  const ProjectDetailPage({super.key, required this.projectUid});

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  SparkProject? _getProject(List<SparkProject> list) {
    try { return list.firstWhere((p) => p.uid == widget.projectUid); } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectUid));

    return projectsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('错误: $e'))),
      data: (projects) {
        final project = _getProject(projects);
        if (project == null) {
          return Scaffold(
            body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('项目不存在'),
              TextButton(onPressed: () => context.pop(), child: const Text('返回')),
            ])),
          );
        }

        final color = Color(project.colorValue);

        return AnimatedGradientBackground(
          colors: [color.withOpacity(0.25), const Color(0xFF0D0820), const Color(0xFF0D0820)],
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // 顶部栏
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GlassIconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textSecondary),
                        ),
                        GlassPullDownButton(
                          items: [
                            GlassPullDownItem(
                              title: '标记为进行中',
                              icon: const Icon(Icons.play_arrow_rounded, size: 16),
                              onTap: () => ref.read(projectsProvider.notifier).updateStatus(project.uid, 'in_progress'),
                            ),
                            GlassPullDownItem(
                              title: '标记为已完成',
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                              onTap: () => ref.read(projectsProvider.notifier).updateStatus(project.uid, 'completed'),
                            ),
                            GlassPullDownItem(
                              title: '归档项目',
                              icon: const Icon(Icons.archive_outlined, size: 16),
                              onTap: () => ref.read(projectsProvider.notifier).updateStatus(project.uid, 'archived'),
                            ),
                            GlassPullDownItem(
                              title: '删除项目',
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                              onTap: () => _deleteProject(context, project),
                              isDestructive: true,
                            ),
                          ],
                          child: GlassIconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _buildHeader(context, project, color)),
                        SliverToBoxAdapter(
                          child: tasksAsync.when(
                            loading: () => const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
                            error: (e, _) => Padding(padding: const EdgeInsets.all(20), child: Text('加载任务失败: $e')),
                            data: (tasks) => _buildTasks(context, ref, project, tasks, color),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, SparkProject project, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GlassPanel(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
              if (project.description != null) ...[
                const SizedBox(height: 8),
                Text(project.description!, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(project.progress * 100).toInt()}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
              ]),
              const SizedBox(height: 8),
              Text('创建于 ${AppUtils.formatRelativeDate(project.createdAt)}', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildTasks(BuildContext context, WidgetRef ref, SparkProject project, List<SparkTask> tasks, Color color) {
    final todo = tasks.where((t) => !t.isCompleted).toList();
    final done = tasks.where((t) => t.isCompleted).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('任务 (${done.length}/${tasks.length})', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 12),

              // 添加任务
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: '添加新任务...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                    onSubmitted: (v) => _addTask(ref, project, v),
                  ),
                ),
                GlassIconButton(
                  onPressed: () => _addTask(ref, project, _taskController.text),
                  icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                ),
              ]),

              if (tasks.isNotEmpty) ...[
                const Divider(height: 20),
                ...todo.map((task) => _TaskItem(task: task, color: color, projectUid: project.uid)),
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('已完成 (${done.length})', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  ...done.map((task) => _TaskItem(task: task, color: color, projectUid: project.uid)),
                ],
              ] else ...[
                const SizedBox(height: 16),
                const Center(child: Text('还没有任务，添加第一个！', style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
              ],
            ],
          ),
        ),
      ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
    );
  }

  Future<void> _addTask(WidgetRef ref, SparkProject project, String title) async {
    final text = title.trim();
    if (text.isEmpty) return;
    _taskController.clear();
    final repo = ref.read(projectRepositoryProvider);
    await repo.addTask(projectId: project.uid, title: text);
    ref.invalidate(projectTasksProvider(project.uid));
    ref.invalidate(projectsProvider);
  }

  Future<void> _deleteProject(BuildContext context, SparkProject project) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1040),
        title: const Text('删除项目', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('确定要删除这个项目吗？包含的所有任务也会被删除。', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(projectsProvider.notifier).delete(project.id);
              if (mounted) context.pop();
            },
            child: const Text('删除', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends ConsumerWidget {
  final SparkTask task;
  final Color color;
  final String projectUid;

  const _TaskItem({required this.task, required this.color, required this.projectUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final repo = ref.read(projectRepositoryProvider);
              await repo.updateTaskStatus(task, task.isCompleted ? 'todo' : 'done');
              ref.invalidate(projectTasksProvider(projectUid));
              ref.invalidate(projectsProvider);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted ? color.withOpacity(0.3) : Colors.transparent,
                border: Border.all(color: task.isCompleted ? color : AppColors.textMuted, width: 1.5),
              ),
              child: task.isCompleted
                  ? Icon(Icons.check_rounded, size: 13, color: color)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                fontSize: 14,
              ),
            ),
          ),
          _PriorityDot(priority: task.priority),
        ],
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final String priority;
  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      'high' => Colors.redAccent,
      'medium' => AppColors.accent,
      _ => AppColors.textMuted,
    };
    return Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}
