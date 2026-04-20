// lib/presentation/pages/capture/capture_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gradient_background.dart';

class CapturePage extends ConsumerStatefulWidget {
  const CapturePage({super.key});

  @override
  ConsumerState<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends ConsumerState<CapturePage> {
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final _contentFocus = FocusNode();
  List<String> _tags = [];
  String _emotion = 'inspired';
  Timer? _autosaveTimer;

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _contentController.addListener(_onContentChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentFocus.requestFocus();
    });
  }

  Future<void> _loadDraft() async {
    final settings = ref.read(settingsProvider).value;
    if (settings?.autoSaveDraft == true) {
      final settingsService = ref.read(settingsServiceProvider);
      final draft = await settingsService.loadDraft();
      if (draft != null && mounted) {
        setState(() {
          _contentController.text = draft['content'] as String;
          _tags = List<String>.from(draft['tags'] as List);
          _emotion = draft['emotion'] as String;
        });
      }
    }
  }

  void _onContentChanged() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 2), _saveDraft);
  }

  Future<void> _saveDraft() async {
    final settingsService = ref.read(settingsServiceProvider);
    await settingsService.saveDraft(
      content: _contentController.text,
      tags: _tags,
      emotion: _emotion,
    );
  }

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      AppUtils.showSnackBar(context, '请先写下你的灵感 ✨', isError: true);
      return;
    }

    final colorValue = await ref.read(inspirationRepositoryProvider).getNextCardColor();
    await ref.read(inspirationsProvider.notifier).add(
      content: content,
      tags: _tags,
      emotion: _emotion,
      colorValue: colorValue,
    );

    // 清除草稿
    final settingsService = ref.read(settingsServiceProvider);
    await settingsService.clearDraft();

    if (mounted) {
      AppUtils.showSnackBar(context, '灵感已保存！✨');
      context.pop();
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _contentController.dispose();
    _tagController.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      colors: AppColors.captureGradient,
      child: SafeArea(
        child: Column(
          children: [
            // 顶部栏
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassIconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  ),
                  Text('记录灵感', style: Theme.of(context).textTheme.headlineSmall),
                  GlassButton.custom(
                    onTap: _save,
                    width: 80,
                    height: 40,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      const Text('保存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 灵感输入区
                    GlassContainer(
                      child: TextField(
                        controller: _contentController,
                        focusNode: _contentFocus,
                        maxLines: null,
                        minLines: 8,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.textPrimary,
                          height: 1.7,
                        ),
                        decoration: const InputDecoration(
                          hintText: '✨ 在这里记录你的灵光一现...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(20),
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 18),
                        ),
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 16),

                    // 情绪选择
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('当前心情', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: AppColors.emotionColors.keys.map((emotion) {
                                final isSelected = _emotion == emotion;
                                final color = AppColors.emotionColors[emotion]!;
                                return GestureDetector(
                                  onTap: () => setState(() => _emotion = emotion),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? color.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                                      border: Border.all(
                                        color: isSelected ? color : Colors.white.withOpacity(0.1),
                                        width: isSelected ? 1.5 : 0.5,
                                      ),
                                    ),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Text(AppUtils.getEmotionEmoji(emotion), style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 4),
                                      Text(AppUtils.getEmotionLabel(emotion),
                                          style: TextStyle(
                                            color: isSelected ? color : AppColors.textMuted,
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                          )),
                                    ]),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 16),

                    // 标签输入
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('标签', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            if (_tags.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _tags.map((tag) => GestureDetector(
                                  onTap: () => setState(() => _tags.remove(tag)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                                      border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 0.5),
                                    ),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Text('#$tag', style: const TextStyle(color: AppColors.primaryLight, fontSize: 12)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.close_rounded, size: 12, color: AppColors.primaryLight),
                                    ]),
                                  ),
                                )).toList(),
                              ),
                            if (_tags.isNotEmpty) const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _tagController,
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                    decoration: const InputDecoration(
                                      hintText: '添加标签，按回车确认...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                                    ),
                                    onSubmitted: _addTag,
                                  ),
                                ),
                                GlassIconButton(
                                  onPressed: () => _addTag(_tagController.text),
                                  icon: const Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTag(String value) {
    final tag = value.trim().replaceAll('#', '');
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _tagController.clear();
    }
  }
}
