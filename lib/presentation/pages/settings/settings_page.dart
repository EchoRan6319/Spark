// lib/presentation/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gradient_background.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _modelController;
  bool _apiKeyVisible = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider).value;
    _apiKeyController = TextEditingController(text: settings?.aiApiKey ?? '');
    _baseUrlController = TextEditingController(text: settings?.aiApiBaseUrl ?? 'https://api.openai.com/v1');
    _modelController = TextEditingController(text: settings?.aiModel ?? 'gpt-4o-mini');
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    await ref.read(settingsProvider.notifier).updateApiConfig(
      apiKey: _apiKeyController.text.trim(),
      apiBaseUrl: _baseUrlController.text.trim(),
      model: _modelController.text.trim(),
    );
    if (mounted) {
      setState(() => _hasChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存 ✓'), backgroundColor: AppColors.primary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      colors: const [Color(0xFF0D0820), Color(0xFF1A0D2E), Color(0xFF0D1A35)],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // 顶部栏
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GlassIconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('设置', style: Theme.of(context).textTheme.headlineSmall)),
                    if (_hasChanges)
                      GlassButton.custom(
                        onTap: _saveSettings,
                        width: 80,
                        height: 40,
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.check_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('保存', style: TextStyle(color: Colors.white, fontSize: 13)),
                        ]),
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // AI 配置
                    _SectionHeader(title: '🤖 AI 服务配置'),
                    const SizedBox(height: 8),
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('API Key', style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                child: TextField(
                                  controller: _apiKeyController,
                                  obscureText: !_apiKeyVisible,
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                  onChanged: (_) => setState(() => _hasChanges = true),
                                  decoration: const InputDecoration(
                                    hintText: 'sk-...',
                                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              GlassIconButton(
                                onPressed: () => setState(() => _apiKeyVisible = !_apiKeyVisible),
                                icon: Icon(_apiKeyVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AppColors.textMuted, size: 18),
                              ),
                            ]),
                            const Divider(height: 20),
                            Text('API Base URL', style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _baseUrlController,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              onChanged: (_) => setState(() => _hasChanges = true),
                              decoration: const InputDecoration(
                                hintText: 'https://api.openai.com/v1',
                                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const Divider(height: 20),
                            Text('模型', style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _modelController,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              onChanged: (_) => setState(() => _hasChanges = true),
                              decoration: const InputDecoration(
                                hintText: 'gpt-4o-mini',
                                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 12),
                    // 预设服务提示
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('兼容的服务', style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(height: 8),
                            ...[
                              ['OpenAI', 'https://api.openai.com/v1', 'gpt-4o-mini'],
                              ['DeepSeek', 'https://api.deepseek.com/v1', 'deepseek-chat'],
                              ['Moonshot', 'https://api.moonshot.cn/v1', 'moonshot-v1-8k'],
                              ['Qwen (阿里云)', 'https://dashscope.aliyuncs.com/compatible-mode/v1', 'qwen-turbo'],
                            ].map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: GestureDetector(
                                onTap: () {
                                  _baseUrlController.text = item[1];
                                  _modelController.text = item[2];
                                  setState(() => _hasChanges = true);
                                },
                                child: Row(children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(item[0], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  const Spacer(),
                                  Text('点击填入', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                                ]),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 20),

                    // 应用信息
                    _SectionHeader(title: '📱 关于'),
                    const SizedBox(height: 8),
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          _InfoRow(label: '应用名称', value: '灵光 (Spark)'),
                          const Divider(height: 20),
                          _InfoRow(label: '版本', value: '1.0.0'),
                          const Divider(height: 20),
                          _InfoRow(label: 'UI 框架', value: 'Liquid Glass Widgets'),
                          const Divider(height: 20),
                          _InfoRow(label: '开发时间', value: '2026-04-20'),
                        ]),
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 20),

                    // 保存按钮
                    if (_hasChanges)
                      GlassButton.custom(
                        onTap: _saveSettings,
                        width: 180,
                        height: 48,
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.save_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text('保存设置', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                        ]),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary));
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: Theme.of(context).textTheme.bodyMedium),
      const Spacer(),
      Text(value, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
    ]);
  }
}
