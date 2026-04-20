// lib/presentation/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home/home_page.dart';
import '../pages/capture/capture_page.dart';
import '../pages/collection/collection_page.dart';
import '../pages/detail/detail_page.dart';
import '../pages/project/project_page.dart';
import '../pages/project/project_detail_page.dart';
import '../pages/mindmap/mindmap_page.dart';
import '../pages/serendipity/serendipity_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/ai_chat/ai_chat_page.dart';
import '../pages/shell/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _buildPage(state, const HomePage()),
        ),
        GoRoute(
          path: '/collection',
          pageBuilder: (context, state) => _buildPage(state, const CollectionPage()),
        ),
        GoRoute(
          path: '/project',
          pageBuilder: (context, state) => _buildPage(state, const ProjectPage()),
        ),
        GoRoute(
          path: '/serendipity',
          pageBuilder: (context, state) => _buildPage(state, const SerendipityPage()),
        ),
      ],
    ),
    GoRoute(
      path: '/capture',
      pageBuilder: (context, state) => _buildSlideUpPage(state, const CapturePage()),
    ),
    GoRoute(
      path: '/detail/:uid',
      pageBuilder: (context, state) {
        final uid = state.pathParameters['uid']!;
        return _buildPage(state, DetailPage(inspirationUid: uid));
      },
    ),
    GoRoute(
      path: '/project/:uid',
      pageBuilder: (context, state) {
        final uid = state.pathParameters['uid']!;
        return _buildPage(state, ProjectDetailPage(projectUid: uid));
      },
    ),
    GoRoute(
      path: '/mindmap/:uid',
      pageBuilder: (context, state) {
        final uid = state.pathParameters['uid']!;
        return _buildPage(state, MindmapPage(inspirationUid: uid));
      },
    ),
    GoRoute(
      path: '/ai-chat/:uid',
      pageBuilder: (context, state) {
        final uid = state.pathParameters['uid']!;
        return _buildPage(state, AiChatPage(inspirationUid: uid));
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _buildPage(state, const SettingsPage()),
    ),
  ],
);

CustomTransitionPage<void> _buildPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _buildSlideUpPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: offset, child: child);
    },
  );
}
