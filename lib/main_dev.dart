// lib/main_dev.dart
// 🛠️ 调试版入口 — flutter run -t lib/main_dev.dart --flavor dev
import 'package:flutter/foundation.dart';
import 'flavors/flavor_config.dart';
import 'main.dart' as runner;

void main() async {
  FlavorConfig.initialize(flavor: Flavor.dev);

  // dev 环境下输出 flavor 信息
  if (kDebugMode) {
    print('🛠️  Running with flavor: ${FlavorConfig.instance}');
  }

  await runner.mainWithFlavor();
}
