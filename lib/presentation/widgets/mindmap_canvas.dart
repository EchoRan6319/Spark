// lib/presentation/widgets/mindmap_canvas.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/ai/ai_service.dart';

// Re-export the type for convenience
export '../../services/ai/ai_service.dart' show MindMapNode;

class MindMapCanvas extends StatefulWidget {
  final MindMapNode root;
  final Function(MindMapNode)? onNodeTap;

  const MindMapCanvas({super.key, required this.root, this.onNodeTap});

  @override
  State<MindMapCanvas> createState() => _MindMapCanvasState();
}

class _MindMapCanvasState extends State<MindMapCanvas> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TransformationController _transformController = TransformationController();
  Map<String, _NodeLayout> _layouts = {};
  double _canvasWidth = 1200;
  double _canvasHeight = 900;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _computeLayout();
      _controller.forward();
    });
  }

  @override
  void didUpdateWidget(MindMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.root != widget.root) {
      _computeLayout();
      _controller.forward(from: 0);
    }
  }

  void _computeLayout() {
    final layouts = <String, _NodeLayout>{};
    const centerX = 600.0;
    const centerY = 450.0;

    // 根节点
    layouts[widget.root.id] = _NodeLayout(dx: centerX, dy: centerY, level: 0);

    // 一级节点
    final l1 = widget.root.children;
    final l1Count = l1.length;
    for (int i = 0; i < l1Count; i++) {
      final angle = (2 * math.pi / l1Count) * i - math.pi / 2;
      final r = 200.0;
      final x = centerX + r * math.cos(angle);
      final y = centerY + r * math.sin(angle);
      layouts[l1[i].id] = _NodeLayout(dx: x, dy: y, level: 1, parentId: widget.root.id);

      // 二级节点
      final l2 = l1[i].children;
      for (int j = 0; j < l2.length; j++) {
        final childAngle = angle + (j - (l2.length - 1) / 2) * 0.4;
        final r2 = 160.0;
        final x2 = x + r2 * math.cos(childAngle);
        final y2 = y + r2 * math.sin(childAngle);
        layouts[l2[j].id] = _NodeLayout(dx: x2, dy: y2, level: 2, parentId: l1[i].id);
      }
    }

    setState(() { _layouts = layouts; });
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformController,
      boundaryMargin: const EdgeInsets.all(200),
      minScale: 0.3,
      maxScale: 2.5,
      child: SizedBox(
        width: _canvasWidth,
        height: _canvasHeight,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                // 连接线
                CustomPaint(
                  size: Size(_canvasWidth, _canvasHeight),
                  painter: _ConnectionPainter(
                    root: widget.root,
                    layouts: _layouts,
                    progress: CurvedAnimation(parent: _controller, curve: Curves.easeOut).value,
                  ),
                ),
                // 节点
                ..._buildAllNodes(widget.root),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildAllNodes(MindMapNode node) {
    final widgets = <Widget>[];
    _collectNodes(node, widgets);
    return widgets;
  }

  void _collectNodes(MindMapNode node, List<Widget> widgets) {
    final layout = _layouts[node.id];
    if (layout == null) return;

    final progress = CurvedAnimation(parent: _controller, curve: Curves.elasticOut).value;
    final scale = (progress).clamp(0.0, 1.0);

    widgets.add(
      Positioned(
        left: layout.dx - _nodeWidth(layout.level) / 2,
        top: layout.dy - _nodeHeight(layout.level) / 2,
        child: Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => widget.onNodeTap?.call(node),
            child: _buildNode(node, layout.level),
          ),
        ),
      ),
    );

    for (final child in node.children) {
      _collectNodes(child, widgets);
    }
  }

  Widget _buildNode(MindMapNode node, int level) {
    final colors = [
      const Color(0xFF6366F1), // root - 紫
      const Color(0xFFF59E0B), // L1 - 橙
      const Color(0xFF0EA5E9), // L2 - 蓝
    ];
    final color = colors[level.clamp(0, 2)];
    final w = _nodeWidth(level);
    final h = _nodeHeight(level);
    final fontSize = level == 0 ? 15.0 : (level == 1 ? 13.0 : 11.0);

    return Container(
      width: w, height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(level == 0 ? 0.4 : 0.2),
        borderRadius: BorderRadius.circular(level == 0 ? 24 : 16),
        border: Border.all(color: color.withOpacity(0.7), width: level == 0 ? 2 : 1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        node.label,
        style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: level == 0 ? FontWeight.w700 : FontWeight.w500),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  double _nodeWidth(int level) => level == 0 ? 130 : (level == 1 ? 110 : 95);
  double _nodeHeight(int level) => level == 0 ? 56 : (level == 1 ? 46 : 38);
}

class _NodeLayout {
  final double dx;
  final double dy;
  final int level;
  final String? parentId;

  const _NodeLayout({required this.dx, required this.dy, required this.level, this.parentId});
}

class _ConnectionPainter extends CustomPainter {
  final MindMapNode root;
  final Map<String, _NodeLayout> layouts;
  final double progress;

  const _ConnectionPainter({required this.root, required this.layouts, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    _drawConnections(canvas, root);
  }

  void _drawConnections(Canvas canvas, MindMapNode node) {
    final fromLayout = layouts[node.id];
    if (fromLayout == null) return;

    for (final child in node.children) {
      final toLayout = layouts[child.id];
      if (toLayout == null) continue;

      final paint = Paint()
        ..color = _levelColor(fromLayout.level).withOpacity(0.4 * progress)
        ..strokeWidth = fromLayout.level == 0 ? 2.5 : 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final p1 = Offset(fromLayout.dx, fromLayout.dy);
      final p2 = Offset(toLayout.dx, toLayout.dy);
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(mid.dx, p1.dy, p2.dx, p2.dy);

      canvas.drawPath(path, paint);
      _drawConnections(canvas, child);
    }
  }

  Color _levelColor(int level) {
    return switch (level) {
      0 => const Color(0xFF6366F1),
      1 => const Color(0xFFF59E0B),
      _ => const Color(0xFF0EA5E9),
    };
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.layouts != layouts;
}
