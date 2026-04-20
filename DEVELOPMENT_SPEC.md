# 「灵光」(Spark) 最终开发技术规范 (已修正)

## 🎯 项目概述

### 1.1 项目简介
「灵光」是一款全平台创意管理应用，旨在通过液态玻璃 UI 风格和 AI 深度集成，帮助用户从灵光一现到项目落地的全流程管理。

### 1.2 核心技术栈 (最终版)
- **框架**：Flutter 3.44.0 (Master Channel)
- **UI 库**：`liquid_glass_widgets: ^0.7.17` (核心液态玻璃视觉实现)
- **数据库**：`isar: ^3.1.0+1` (高性能 NoSQL 本地持久化)
- **状态管理**：`flutter_riverpod: ^2.6.1` (响应式状态与异步数据流)
- **路由**：`go_router: ^14.8.1` (声明式路由与 ShellRoute 支持)
- **AI 引擎**：OpenAI 兼容协议 (支持 自定义 Base URL，兼容 DeepSeek, Moonshot, Qwen 等)
- **动画**：`flutter_animate: ^4.5.2`

### 1.3 平台支持
- ✅ iOS / Android (移动端沉浸式)
- ✅ Windows / macOS / Linux (桌面端效率工具)
- ✅ Web (轻量级访问)

---

## 🏗️ 架构设计与目录规范

### 2.1 目录结构
```
lib/
├── core/                   # 核心底层
│   ├── constants/          # AppColors, AppStrings, AppSizes
│   ├── theme/              # AppTheme (Dark Material3 + GlassThemeData)
│   └── utils/              # AppUtils (日期格式化、情绪映射)
├── data/                   # 数据层
│   ├── models/             # Isar Collections (Inspiration, Project, Task)
│   ├── datasources/        # IsarDatasource (数据库单例与初始化)
│   └── repositories/       # 业务仓库层 (封装 CRUD)
├── domain/                 # 领域层 (按需扩展)
├── flavors/                # 多环境配置 (FlavorConfig)
├── services/               # 基础设施服务
│   ├── ai/                 # AiService (分析、思维导图、对话)
│   └── storage/            # SettingsService (SharedPreferences 配置)
├── presentation/           # UI 层
│   ├── providers/          # Riverpod Providers (状态聚合中心)
│   ├── routes/             # AppRouter (路由定义)
│   ├── widgets/            # 通用玻璃组件 (InspirationCard, MindMapCanvas)
│   └── pages/              # 业务页面 (home, capture, collection, detail...)
├── main.dart               # 统一启动逻辑
├── main_dev.dart           # 开发版入口
└── main_prod.dart          # 正式版入口
```

---

## 🛠️ 多环境 (Flavor) 构建规范

### 3.1 环境区分
| 特性 | 开发版 (Dev) | 正式版 (Prod) |
| :--- | :--- | :--- |
| **入口文件** | `lib/main_dev.dart` | `lib/main_prod.dart` |
| **应用名称** | 灵光 Dev | 灵光 |
| **包名后缀** | `.dev` (Android) | 无 |
| **数据库名** | `spark_db_dev` | `spark_db` |
| **调试标识** | 显示 Debug Banner | 隐藏 |

### 3.2 构建命令
- **Android Dev**: `flutter run -t lib/main_dev.dart --flavor dev`
- **Android Prod**: `flutter run -t lib/main_prod.dart --release --flavor prod`
- **iOS/Desktop**: 同样指定对应 `-t` 即可。

---

## 🎨 UI & 组件规范 (API 修正)

### 4.1 Liquid Glass Widgets 关键用法
由于 `liquid_glass_widgets` 版本更新，部分组件参数已调整：
- **GlassBottomBar**:
  ```dart
  GlassBottomBar(
    tabs: [
      GlassBottomBarTab(label: '首页', icon: Icon(...)),
      // ...
    ],
    selectedIndex: currentIndex,
    onTabSelected: (index) => ...,
  )
  ```
- **GlassCard / GlassPanel**: 默认使用透明度与模糊效果，背景应配合 `AnimatedGradientBackground` 增强深邃感。

### 4.2 全局主题
- 统一使用 **Dark Mode**。
- 背景色：`#0D0820` (深紫色基调)。
- 主色调：`AppColors.primary` (#6366F1)。

---

## 🧠 核心逻辑实现

### 5.1 数据模型 (Isar)
- `Inspiration`: 存储内容、情绪、标签、AI 分析结果、补充记录。
- `SparkProject`: 关联灵感，存储进度、状态。
- `SparkTask`: 项目下的原子任务。

### 5.2 AI 服务
- **分析**：返回可行性、潜力、风险分数及行动建议。
- **思维导图**：返回树状结构 JSON，前端使用 `CustomPainter` 渲染。
- **对话**：支持上下文（灵感内容）关联。

### 5.3 状态管理 (Riverpod)
- 使用 `AsyncNotifier` 管理异步列表。
- `filteredInspirationsProvider`: 支持实时搜索与情绪过滤。
- `aiChatProvider`: 管理对话状态与流式响应模拟。

---

## ✅ 验证计划

### 6.1 自动化测试
- `flutter test`: 验证 Repository 逻辑。
- `flutter analyze`: 确保代码风格统一且无警告。

### 6.2 手动验证
1. 运行 `main_dev` 确认数据库名为 `spark_db_dev`。
2. 在设置页面填入 API Key，测试 AI 分析功能。
3. 测试“灵感转项目”流程，验证任务进度同步。

---
*文档生成日期：2026-04-20*
*版本：v1.1 (Final Corrected)*
