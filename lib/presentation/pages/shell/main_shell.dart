// lib/presentation/pages/shell/main_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_constants.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/collection')) return 1;
    if (location.startsWith('/project')) return 2;
    if (location.startsWith('/serendipity')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      extendBody: true,
      body: child,
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(context, currentIndex),
    );
  }

  Widget _buildFab(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/capture'),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int currentIndex) {
    return GlassBottomBar(
      tabs: [
        GlassBottomBarTab(
          label: AppStrings.navHome,
          icon: Icon(
            currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
            color: currentIndex == 0 ? AppColors.primary : AppColors.textMuted,
          ),
        ),
        GlassBottomBarTab(
          label: AppStrings.navCollection,
          icon: Icon(
            currentIndex == 1 ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
            color: currentIndex == 1 ? AppColors.accent : AppColors.textMuted,
          ),
        ),
        GlassBottomBarTab(
          label: AppStrings.navProjects,
          icon: Icon(
            currentIndex == 2 ? Icons.folder_rounded : Icons.folder_outlined,
            color: currentIndex == 2 ? AppColors.teal : AppColors.textMuted,
          ),
        ),
        GlassBottomBarTab(
          label: AppStrings.navMe,
          icon: Icon(
            currentIndex == 3 ? Icons.auto_awesome_rounded : Icons.auto_awesome_outlined,
            color: currentIndex == 3 ? AppColors.pink : AppColors.textMuted,
          ),
        ),
      ],
      selectedIndex: currentIndex,
      onTabSelected: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/collection');
            break;
          case 2:
            context.go('/project');
            break;
          case 3:
            context.go('/serendipity');
            break;
        }
      },
    );
  }
}
