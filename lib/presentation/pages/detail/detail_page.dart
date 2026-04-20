// lib/presentation/pages/detail/detail_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/inspiration.dart';
import '../../../services/ai/ai_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gradient_background.dart';

class DetailPage extends ConsumerStatefulWidget {
  final String inspirationUid;
  const DetailPage({super.key, required this.inspirationUid});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  final _supplementController = TextEditingController();
  bool _isAnalyzing = false;
  AiAnalysisResult? _analysisResult;
  String? _aiError;

  @override
  void dispose() {
    _supplementController.dispose();
    super.dispose();
  }

  Inspiration? _getInspiration(List<Inspiration> list) {
    try {
      return list.firstWhere((i) => i.uid == widget.inspirationUid);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inspirationsAsync = ref.watch(inspirationsProvider);

    return inspirationsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('错误: $e'))),
      data: (list) {
        final inspiration = _getInspiration(list);
        if (inspiration == null) {
          return Scaffold(
            body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🔍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('灵感不存在'),
              TextButton(onPressed: () => context.pop(), child: const Text('返回')),
            ])),
          );
        }

        // 如果已有 AI 分析，解析它
        if (_analysisResult == null && inspiration.aiAnalysis != null) {
          try {
            final raw = inspiration.aiAnalysis!
                .replaceAll("'", '"')
                .replaceAll('(', '')
                .replaceAll(')', '');
            _analysisResult = AiAnalysisResult.fromJson(jsonDecode(inspiration.aiAnalysis!) as Map<String, dynamic>);
          } catch (_) {}
        }

        final color = Color(inspiration.colorValue);

        return AnimatedGradientBackground(
          colors: [
            color.withOpacity(0.3),
            const Color(0xFF0D0820),
            const Color(0xFF0D0820),
          ],
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildAppBar(context, inspiration, color)),
                  SliverToBoxAdapter(child: _buildContent(context, inspiration, color)),
                  SliverToBoxAdapter(child: _buildAiAnalysis(context, inspiration, color)),
                  SliverToBoxAdapter(child: _buildSupplements(context, inspiration, color)),
                  SliverToBoxAdapter(child: _buildActions(context, inspiration, color)),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, Inspiration inspiration, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassIconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textSecondary),
          ),
          Row(children: [
            GlassIconButton(
              onPressed: () => ref.read(inspirationsProvider.notifier).toggleFavorite(inspiration.uid),
              icon: Icon(
                inspiration.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: inspiration.isFavorite ? const Color(0xFFF59E0B) : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              onPressed: () => _showDeleteDialog(context, inspiration),
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Inspiration inspiration, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 情绪 + 时间
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                border: Border.all(color: color.withOpacity(0.3), width: 0.8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(AppUtils.getEmotionEmoji(inspiration.emotion), style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(AppUtils.getEmotionLabel(inspiration.emotion),
                    style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(width: 10),
            Text(AppUtils.formatFullDate(inspiration.createdAt),
                style: Theme.of(context).textTheme.bodySmall),
          ]),

          const SizedBox(height: 20),

          // 正文内容
          GlassPanel(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SelectableText(
                inspiration.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 17, height: 1.8),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

          // 标签
          if (inspiration.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: inspiration.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                  border: Border.all(color: color.withOpacity(0.2), width: 0.5),
                ),
                child: Text('#$tag', style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiAnalysis(BuildContext context, Inspiration inspiration, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text('AI 分析', style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  if (!_isAnalyzing)
                    GlassButton(
                      onPressed: () => _runAnalysis(inspiration),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(_analysisResult == null ? '分析' : '重新分析',
                            style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ]),
                    ),
                ],
              ),

              if (_isAnalyzing) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 8),
                const Center(child: Text('AI 正在分析中...', style: TextStyle(color: AppColors.textMuted))),
              ],

              if (_aiError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Text(_aiError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ),
              ],

              if (_analysisResult != null) ...[
                const SizedBox(height: 16),
                _buildScoreRow('可行性', _analysisResult!.feasibility, AppColors.teal),
                const SizedBox(height: 8),
                _buildScoreRow('潜力', _analysisResult!.potential, AppColors.accent),
                const SizedBox(height: 8),
                _buildScoreRow('风险', _analysisResult!.risk, Colors.redAccent),
                const SizedBox(height: 12),
                if (_analysisResult!.summary.isNotEmpty) ...[
                  Text('总结', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(_analysisResult!.summary, style: Theme.of(context).textTheme.bodyMedium),
                ],
                if (_analysisResult!.actionPlan.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('行动计划', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  ..._analysisResult!.actionPlan.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 20, height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text('${e.key + 1}', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.value, style: Theme.of(context).textTheme.bodyMedium)),
                    ]),
                  )),
                ],
              ],

              if (_analysisResult == null && !_isAnalyzing && _aiError == null) ...[
                const SizedBox(height: 12),
                const Center(child: Text('点击「分析」按钮，让 AI 评估这个想法', style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
              ],
            ],
          ),
        ),
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildScoreRow(String label, double value, Color color) {
    return Row(children: [
      SizedBox(width: 48, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
      const SizedBox(width: 8),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildSupplements(BuildContext context, Inspiration inspiration, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.note_add_outlined, color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Text('补充记录 (${inspiration.supplements.length})', style: Theme.of(context).textTheme.titleMedium),
              ]),

              if (inspiration.supplements.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...inspiration.supplements.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border(left: BorderSide(color: color, width: 3)),
                    ),
                    child: Text(e.value, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                )),
              ],

              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _supplementController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: '添加补充记录...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                  ),
                ),
                GlassIconButton(
                  onPressed: () async {
                    final text = _supplementController.text.trim();
                    if (text.isNotEmpty) {
                      await ref.read(inspirationsProvider.notifier).addSupplement(inspiration.uid, text);
                      _supplementController.clear();
                    }
                  },
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 18),
                ),
              ]),
            ],
          ),
        ),
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildActions(BuildContext context, Inspiration inspiration, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Expanded(
          child: GlassButton(
            onPressed: () => context.push('/mindmap/${inspiration.uid}'),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.account_tree_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('思维导图', style: TextStyle(color: Colors.white, fontSize: 14)),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassButton(
            onPressed: () => context.push('/ai-chat/${inspiration.uid}'),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('AI 对话', style: TextStyle(color: Colors.white, fontSize: 14)),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        GlassButton(
          onPressed: () => _convertToProject(context, inspiration, color),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add_task_rounded, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text('转项目', style: TextStyle(color: Colors.white, fontSize: 14)),
          ]),
        ),
      ]),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }

  Future<void> _runAnalysis(Inspiration inspiration) async {
    final settings = ref.read(settingsProvider).value;
    if (settings == null || settings.aiApiKey.isEmpty) {
      setState(() => _aiError = '请先在设置中配置 AI API Key');
      return;
    }
    setState(() { _isAnalyzing = true; _aiError = null; });
    try {
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.analyzeInspiration(inspiration.content);
      await ref.read(inspirationsProvider.notifier).saveAiAnalysis(
        inspiration.uid,
        jsonEncode(result.toJson()),
      );
      if (mounted) setState(() { _analysisResult = result; _isAnalyzing = false; });
    } catch (e) {
      if (mounted) setState(() { _aiError = e.toString(); _isAnalyzing = false; });
    }
  }

  Future<void> _convertToProject(BuildContext context, Inspiration inspiration, Color color) async {
    final projectNotifier = ref.read(projectsProvider.notifier);
    final project = await projectNotifier.create(
      title: '来自灵感：${inspiration.content.substring(0, inspiration.content.length.clamp(0, 20))}...',
      description: inspiration.content,
      inspirationId: inspiration.uid,
      colorValue: inspiration.colorValue,
    );
    if (mounted) {
      AppUtils.showSnackBar(context, '已转化为项目！');
      context.push('/project/${project.uid}');
    }
  }

  void _showDeleteDialog(BuildContext context, Inspiration inspiration) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1040),
        title: const Text('删除灵感', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('确定要删除这条灵感吗？此操作不可撤销。', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(inspirationsProvider.notifier).delete(inspiration.id);
              if (mounted) context.pop();
            },
            child: const Text('删除', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
