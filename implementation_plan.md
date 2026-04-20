# 「灵光」(Spark) 全平台创意管理应用 — 实现计划

基于 `DEVELOPMENT_SPEC.md` 开发规范，构建一款跨平台创意管理 Flutter 应用。

## 环境确认

- **Flutter**: 3.44.0-master（满足 3.24+ 需求）
- **Flutter 路径**: `D:\flutter\bin\flutter.bat`
- **项目目录**: `d:\EchoRan\Documents\GitHub\Spark`（仅含规范文档，需初始化）

## 关键修正（规范 vs 实际 API）

> [!IMPORTANT]
> 以下几处与规范描述不同，需按实际 API 调整：
>
> - `liquid_glass_widgets` 最新版为 `^0.7.17`（规范写的 0.7.7）
> - `GlassBottomBar` 使用 `tabs: [GlassBottomBarTab(...)]` + `onTabSelected`，而非 `items` + `onTap`
> - `GlassSegmentedControl` 使用 `segments: ['...']` + `onSegmentSelected`
> - Isar 当前可用稳定版为 `^3.1.0`，需配合 `isar_generator` code gen
> - 初始化改为 `LiquidGlassWidgets.wrap()` 包裹根 widget

## 开放问题

> [!NOTE]
> **AI 服务配置**：规范中提到 OpenAI API，但未指定 API Key 来源。计划中 AI 功能实现为：
> - 支持用户在设置页面输入 API Base URL 和 API Key
> - 默认使用 OpenAI Compatible API（兼容各种第三方服务如 DeepSeek、Qwen 等）
> - AI 功能降级处理：无 Key 时展示提示，不影响核心功能

> [!NOTE]
> **思维导图**：规范中提到用 AI 生成思维导图结构，然后用 `CustomPainter` 渲染。计划使用 `flutter_layout_graph` 或自实现树状布局算法。

## 实现阶段

### 阶段一：项目初始化与基础架构

#### [NEW] `pubspec.yaml`
Flutter 项目配置，包含所有依赖

#### [NEW] `lib/main.dart`
应用入口，初始化 LiquidGlassWidgets，配置 GoRouter

#### [NEW] `lib/core/constants/app_constants.dart`
颜色常量、尺寸常量、字符串常量

#### [NEW] `lib/core/theme/app_theme.dart`
Material Theme + GlassTheme 配置，支持亮色/暗色

#### [NEW] `lib/core/utils/`
日期格式化、UUID 生成等工具

---

### 阶段二：数据层

#### [NEW] `lib/data/models/inspiration.dart`
Isar 模型 — 灵感（id, content, tags, emotion, color, createdAt, updatedAt, supplements, attachments）

#### [NEW] `lib/data/models/project.dart`
Isar 模型 — 项目（id, title, description, status, inspirationId, tasks, milestones）

#### [NEW] `lib/data/models/task.dart`
Isar 模型 — 任务（id, title, status, priority, dueDate）

#### [NEW] `lib/data/models/ai_analysis.dart`
Isar 模型 — AI 分析结果（feasibility, potential, risk, actionPlan）

#### [NEW] `lib/data/models/mindmap.dart`
Isar 模型 — 思维导图节点/边数据

#### [NEW] `lib/data/datasources/isar_datasource.dart`
Isar 初始化和底层 CRUD

#### [NEW] `lib/data/repositories/`
InspirationRepository、ProjectRepository 等的实现

---

### 阶段三：领域层

#### [NEW] `lib/domain/entities/`
纯 Dart 实体类（不依赖 Isar 注解）

#### [NEW] `lib/domain/usecases/`
InspirationUsecase、ProjectUsecase 等业务逻辑

#### [NEW] `lib/domain/repositories/`
Repository 抽象接口

---

### 阶段四：状态管理

#### [NEW] `lib/presentation/providers/inspiration_provider.dart`
Riverpod StateNotifier — 灵感 CRUD 状态

#### [NEW] `lib/presentation/providers/project_provider.dart`
Riverpod StateNotifier — 项目状态

#### [NEW] `lib/presentation/providers/ai_provider.dart`
AI 服务调用状态（loading, error, result）

#### [NEW] `lib/presentation/providers/settings_provider.dart`
用户设置（API Key、主题偏好等）

---

### 阶段五：核心页面（7个）

#### [NEW] `lib/presentation/pages/home/home_page.dart`
首页仪表盘 — 统计卡片、进行中项目、快速记录入口

#### [NEW] `lib/presentation/pages/capture/capture_page.dart`
灵感捕获 — 全屏沉浸式，情绪选择，标签，自动保存草稿

#### [NEW] `lib/presentation/pages/collection/collection_page.dart`
灵感集 — 网格卡片，搜索，按标签/情绪/时间筛选

#### [NEW] `lib/presentation/pages/detail/detail_page.dart`
灵感详情 — AI 分析，补充记录，附件，转为项目按钮

#### [NEW] `lib/presentation/pages/project/project_page.dart`
项目管理 — 任务列表，进度追踪，里程碑

#### [NEW] `lib/presentation/pages/mindmap/mindmap_page.dart`
思维导图 — AI 生成节点，CustomPainter 渲染，可编辑，可导出

#### [NEW] `lib/presentation/pages/serendipity/serendipity_page.dart`
灵感拾遗 — 随机展示历史灵感，卡片翻转动画

#### [NEW] `lib/presentation/pages/settings/settings_page.dart`
设置 — AI API 配置，主题切换

---

### 阶段六：通用组件

#### [NEW] `lib/presentation/widgets/mindmap_canvas.dart`
思维导图 CustomPainter 画布

#### [NEW] `lib/presentation/widgets/inspiration_card.dart`
灵感卡片组件（复用于多个页面）

#### [NEW] `lib/presentation/widgets/emotion_selector.dart`
情绪选择器

#### [NEW] `lib/presentation/widgets/gradient_background.dart`
渐变背景组件

---

### 阶段七：服务层

#### [NEW] `lib/services/ai/ai_service.dart`
AI API 调用（创意评估、行动计划、思维导图生成、对话）

#### [NEW] `lib/services/storage/draft_service.dart`
草稿自动保存

---

### 阶段八：路由配置

#### [NEW] `lib/presentation/routes/app_router.dart`
GoRouter 配置，包含所有页面路由

---

## 验证计划

### 自动化
```bash
D:\flutter\bin\flutter.bat pub get
D:\flutter\bin\flutter.bat analyze
D:\flutter\bin\flutter.bat build windows  # 验证 Windows 构建
```

### 手动验证（浏览器）
- 使用 `flutter run -d chrome` 启动 Web 版
- 截图验证液态玻璃 UI 效果
- 测试核心功能流程：创建灵感 → 查看详情 → 转为项目

---

**文档版本**: 1.0 | **规划时间**: 2026-04-20
