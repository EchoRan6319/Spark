// lib/main_prod.dart
// 🚀 正式版入口 — flutter run -t lib/main_prod.dart --flavor prod
import 'flavors/flavor_config.dart';
import 'main.dart' as runner;

void main() async {
  FlavorConfig.initialize(flavor: Flavor.prod);
  await runner.mainWithFlavor();
}
