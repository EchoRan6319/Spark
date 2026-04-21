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
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0820) : AppColors.bgLight,
      extendBody: true,
      body: child,
      bottomNavigationBar: _buildBottomBar(context, currentIndex),
    );
  }

  Widget _buildBottomBar(BuildContext context, int currentIndex) {
    final isDark = AppColors.isDark(context);

    Widget tabIcon({
      required bool selected,
      required IconData selectedIcon,
      required IconData icon,
      required Color selectedColor,
    }) {
      return AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        scale: selected ? 1.15 : 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selected)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      selectedColor.withOpacity(isDark ? 0.45 : 0.28),
                      selectedColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            Icon(
              selected ? selectedIcon : icon,
              color: selected ? selectedColor : AppColors.adaptiveTextMuted(context),
            ),
            if (selected)
              Positioned(
                top: 3,
                child: Container(
                  width: 16,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(isDark ? 0.38 : 0.48),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return GlassBottomBar(
      tabs: [
        GlassBottomBarTab(
          label: AppStrings.navHome,
          icon: tabIcon(
            selected: currentIndex == 0,
            selectedIcon: Icons.home_rounded,
            icon: Icons.home_outlined,
            selectedColor: AppColors.primary,
          ),
        ),
        GlassBottomBarTab(
          label: AppStrings.navCollection,
          icon: tabIcon(
            selected: currentIndex == 1,
            selectedIcon: Icons.lightbulb_rounded,
            icon: Icons.lightbulb_outline_rounded,
            selectedColor: AppColors.accent,
          ),
        ),
        GlassBottomBarTab(
          label: '添加',
          icon: Transform.translate(
            offset: const Offset(0, -9),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(isDark ? 0.28 : 0.52),
                  width: 0.9,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.55),
                    blurRadius: 18,
                    spreadRadius: 1.5,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 7,
                    child: Container(
                      width: 22,
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(isDark ? 0.46 : 0.64),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                ],
              ),
            ),
          ),
        ),
        GlassBottomBarTab(
          label: AppStrings.navProjects,
          icon: tabIcon(
            selected: currentIndex == 2,
            selectedIcon: Icons.folder_rounded,
            icon: Icons.folder_outlined,
            selectedColor: AppColors.teal,
          ),
        ),
        GlassBottomBarTab(
          label: AppStrings.navMe,
          icon: tabIcon(
            selected: currentIndex == 3,
            selectedIcon: Icons.auto_awesome_rounded,
            icon: Icons.auto_awesome_outlined,
            selectedColor: AppColors.pink,
          ),
        ),
      ],
      selectedIndex: currentIndex >= 2 ? currentIndex + 1 : currentIndex,
      onTabSelected: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/collection');
            break;
          case 2:
            context.push('/capture');
            break;
          case 3:
            context.go('/project');
            break;
          case 4:
            context.go('/serendipity');
            break;
        }
      },
    );
  }
}
