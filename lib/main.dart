// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/isar_datasource.dart';
import 'flavors/flavor_config.dart';
import 'presentation/routes/app_router.dart';

/// 默认入口（无 flavor，自动使用 prod 配置）
/// 推荐使用 main_dev.dart 或 main_prod.dart 启动
void main() async {
  // 若未通过 flavor 入口启动，默认初始化为 prod
  if (!FlavorConfig.isInitialized) {
    FlavorConfig.initialize(flavor: Flavor.prod);
  }
  await mainWithFlavor();
}

/// 带 Flavor 的统一启动逻辑，由 main_dev/main_prod 调用
Future<void> mainWithFlavor() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化液态玻璃
  await LiquidGlassWidgets.initialize();

  // 初始化 Isar 数据库（使用 Flavor 对应的 DB 名）
  await IsarDatasource.instance.initialize(
    dbName: FlavorConfig.instance.dbName,
  );

  runApp(
    const ProviderScope(
      child: SparkApp(),
    ),
  );
}

class SparkApp extends StatelessWidget {
  const SparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = FlavorConfig.instance;

    return LiquidGlassWidgets.wrap(
      GlassTheme(
        data: AppTheme.glassTheme,
        child: MaterialApp.router(
          title: config.appName,
          debugShowCheckedModeBanner: config.showDebugBanner,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
