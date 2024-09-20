import 'package:flutter/material.dart';

/// 当InteractiveViewerBoundary的缩放比例改变时调用的回调函数类型
typedef ScaleChanged = void Function(double scale);

/// InteractiveViewerBoundary 小部件
///
/// 这个小部件构建了一个InteractiveViewer，并提供了当触及水平边界时的回调函数。
/// 通过监听InteractiveViewer.onInteractionEnd回调，在交互结束时调用这些回调函数。
class InteractiveViewerBoundary extends StatefulWidget {
  const InteractiveViewerBoundary({
    required this.child,
    required this.boundaryWidth,
    this.controller,
    this.onScaleChanged,
    this.onLeftBoundaryHit,
    this.onRightBoundaryHit,
    this.onNoBoundaryHit,
    this.maxScale,
    this.minScale,
  });

  /// 要显示的子部件
  final Widget child;

  /// 此小部件可以拥有的最大宽度
  ///
  /// 如果InteractiveViewer可以占据整个屏幕宽度，
  /// 这应该设置为 MediaQuery.of(context).size.width
  final double boundaryWidth;

  /// InteractiveViewer的TransformationController
  final TransformationController? controller;

  /// 交互结束后，当缩放比例改变时调用的回调函数
  final ScaleChanged? onScaleChanged;

  /// 交互结束后，当触及左边界时调用的回调函数
  final VoidCallback? onLeftBoundaryHit;

  /// 交互结束后，当触及右边界时调用的回调函数
  final VoidCallback? onRightBoundaryHit;

  /// 交互结束后，当没有触及任何边界时调用的回调函数
  final VoidCallback? onNoBoundaryHit;

  /// 最大缩放比例
  final double? maxScale;

  /// 最小缩放比例
  final double? minScale;

  @override
  InteractiveViewerBoundaryState createState() =>
      InteractiveViewerBoundaryState();
}

class InteractiveViewerBoundaryState extends State<InteractiveViewerBoundary> {
  /// TransformationController，用于控制InteractiveViewer的变换
  TransformationController? _controller;

  /// 当前的缩放比例
  double? _scale;

  @override
  void initState() {
    super.initState();

    // 如果没有提供controller，则创建一个新的
    _controller = widget.controller ?? TransformationController();
  }

  @override
  void dispose() {
    // 销毁controller
    _controller!.dispose();

    super.dispose();
  }

  /// 更新边界检测
  void _updateBoundaryDetection() {
    final double scale = _controller!.value.row0[0];

    // 检查缩放比例是否改变
    if (_scale != scale) {
      _scale = scale;
      widget.onScaleChanged?.call(scale);
    }

    // 如果缩放比例接近或小于1，无法触及任何边界
    if (scale <= 1.01) {
      return;
    }

    // 计算当前位置和边界
    final double xOffset = _controller!.value.row0[3];
    final double boundaryWidth = widget.boundaryWidth;
    final double boundaryEnd = boundaryWidth * scale;
    final double xPos = boundaryEnd + xOffset;

    // 检查是否触及左边界
    if (boundaryEnd.round() == xPos.round()) {
      widget.onLeftBoundaryHit?.call();
    }
    // 检查是否触及右边界
    else if (boundaryWidth.round() == xPos.round()) {
      widget.onRightBoundaryHit?.call();
    }
    // 没有触及任何边界
    else {
      widget.onNoBoundaryHit?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: widget.maxScale!,
      minScale: widget.minScale!,
      transformationController: _controller,
      onInteractionEnd: (_) => _updateBoundaryDetection(),
      child: widget.child,
    );
  }
}
