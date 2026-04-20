// lib/flavors/flavor_config.dart
// Flavor 配置 — 区分调试版（dev）和正式版（prod）

enum Flavor { dev, prod }

class FlavorConfig {
  final Flavor flavor;

  // App 显示名称
  final String appName;

  // 包名后缀（Android applicationId 由 Gradle 控制，这里用于日志等）
  final String bundleIdSuffix;

  // 是否显示调试信息
  final bool showDebugBanner;

  // 是否允许自签名证书（仅 dev）
  final bool allowBadCertificates;

  // Isar 数据库名称（dev/prod 隔离，互不干扰）
  final String dbName;

  static FlavorConfig? _instance;

  FlavorConfig._internal({
    required this.flavor,
    required this.appName,
    required this.bundleIdSuffix,
    required this.showDebugBanner,
    required this.allowBadCertificates,
    required this.dbName,
  });

  /// 初始化 Flavor，在各 main_*.dart 中调用
  static void initialize({required Flavor flavor}) {
    switch (flavor) {
      case Flavor.dev:
        _instance = FlavorConfig._internal(
          flavor: Flavor.dev,
          appName: '灵光 Dev',
          bundleIdSuffix: '.dev',
          showDebugBanner: true,
          allowBadCertificates: true,
          dbName: 'spark_db_dev',
        );
        break;
      case Flavor.prod:
        _instance = FlavorConfig._internal(
          flavor: Flavor.prod,
          appName: '灵光',
          bundleIdSuffix: '',
          showDebugBanner: false,
          allowBadCertificates: false,
          dbName: 'spark_db',
        );
        break;
    }
  }

  /// 是否已初始化
  static bool get isInitialized => _instance != null;

  /// 获取当前配置实例
  static FlavorConfig get instance {
    assert(
      _instance != null,
      'FlavorConfig 未初始化！请在 main_dev.dart 或 main_prod.dart 中调用 FlavorConfig.initialize()',
    );
    return _instance!;
  }

  bool get isDev => flavor == Flavor.dev;
  bool get isProd => flavor == Flavor.prod;

  /// Flavor 标识字符串
  String get flavorName => flavor.name; // 'dev' | 'prod'

  @override
  String toString() =>
      'FlavorConfig(flavor: $flavorName, appName: $appName, dbName: $dbName)';
}
