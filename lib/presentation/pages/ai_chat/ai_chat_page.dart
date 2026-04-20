// lib/presentation/pages/ai_chat/ai_chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/inspiration.dart';
import '../../providers/app_providers.dart';
import '../../widgets/gradient_background.dart';

class AiChatPage extends ConsumerStatefulWidget {
  final String inspirationUid;
  const AiChatPage({super.key, required this.inspirationUid});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String inspirationContent) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    final chatNotifier = ref.read(aiChatProvider(widget.inspirationUid).notifier);
    if (!_initialized) {
      chatNotifier.setInspirationContent(inspirationContent);
      _initialized = true;
    }

    await chatNotifier.sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final inspirationsAsync = ref.watch(inspirationsProvider);
    final chatState = ref.watch(aiChatProvider(widget.inspirationUid));

    return inspirationsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('错误: $e'))),
      data: (list) {
        Inspiration? inspiration;
        try { inspiration = list.firstWhere((i) => i.uid == widget.inspirationUid); } catch (_) {}

        return GradientBackground(
          colors: const [Color(0xFF0D0820), Color(0xFF0D1A35), Color(0xFF0D0820)],
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(children: [
                      GlassIconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      const Text('🤖', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI 对话', style: Theme.of(context).textTheme.headlineSmall),
                            if (inspiration != null)
                              Text(AppUtils.truncateText(inspiration.content, 30),
                                  style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ]),
                  ).animate().fadeIn(duration: 300.ms),

                  // 灵感摘要卡
                  if (inspiration != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            AppUtils.truncateText(inspiration.content, 100),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 8),

                  // 消息列表
                  Expanded(
                    child: chatState.messages.isEmpty && !chatState.isLoading
                        ? Center(
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Text('💬', style: TextStyle(fontSize: 48)).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                              const SizedBox(height: 12),
                              Text('与 AI 探讨你的灵感', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text('可以问 AI 评估可行性、提供建议等', style: Theme.of(context).textTheme.bodySmall),
                            ]),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            physics: const BouncingScrollPhysics(),
                            itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i == chatState.messages.length) {
                                return _TypingIndicator();
                              }
                              final msg = chatState.messages[i];
                              return _MessageBubble(
                                content: msg.content,
                                isUser: msg.role == 'user',
                                index: i,
                              );
                            },
                          ),
                  ),

                  // 错误提示
                  if (chatState.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text(chatState.error!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12), textAlign: TextAlign.center),
                    ),

                  // 快捷提问
                  if (chatState.messages.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          '这个想法可行性如何？',
                          '有什么改进建议？',
                          '如何快速验证这个想法？',
                          '潜在的风险是什么？',
                        ].map((q) => GestureDetector(
                          onTap: () {
                            _messageController.text = q;
                            _send(inspiration?.content ?? '');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 0.5),
                            ),
                            child: Text(q, style: const TextStyle(color: AppColors.primaryLight, fontSize: 12)),
                          ),
                        )).toList(),
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                  // 输入框
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(children: [
                      Expanded(
                        child: GlassContainer(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            maxLines: 4,
                            minLines: 1,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: '和 AI 聊聊你的想法...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassIconButton(
                        onPressed: chatState.isLoading ? null : () => _send(inspiration?.content ?? ''),
                        icon: chatState.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                            : const Icon(Icons.send_rounded, color: AppColors.primary),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final int index;

  const _MessageBubble({required this.content, required this.isUser, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Text('🤖', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary.withOpacity(0.25)
                    : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: Border.all(
                  color: isUser ? AppColors.primary.withOpacity(0.3) : Colors.white.withOpacity(0.08),
                  width: 0.5,
                ),
              ),
              child: SelectableText(
                content,
                style: TextStyle(
                  color: isUser ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 30))
        .fadeIn(duration: 300.ms)
        .slideX(begin: isUser ? 0.1 : -0.1, end: 0, duration: 300.ms);
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
        ..repeat(reverse: true);
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) c.forward();
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), shape: BoxShape.circle),
          child: const Text('🤖', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _controllers[i],
              builder: (ctx, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: 6, height: 6 + 4 * _controllers[i].value,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.6 + 0.4 * _controllers[i].value),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          })),
        ),
      ]),
    );
  }
}
