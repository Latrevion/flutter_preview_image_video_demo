library interactiveviewer_gallery;

import 'package:flutter/material.dart';
import './custom_dismissible.dart';
import './interactive_viewer_boundary.dart';

/// 用于构建带有焦点状态的索引小部件的函数类型
/// context: 构建上下文
/// index: 当前项目的索引
/// isFocus: 是否为当前焦点项目
typedef IndexedFocusedWidgetBuilder = Widget Function(
    BuildContext context, int index, bool isFocus);

/// 用于根据索引构建标签字符串的函数类型
typedef IndexedTagStringBuilder = String Function(int index);

/// InteractiveviewerGallery 小部件
///
/// 这个小部件构建了一个由PageView控制的轮播图，用于显示媒体源的全屏视图。
/// 用户可以通过InteractiveViewer交互式地平移和缩放源。
/// 使用InteractiveViewerBoundary来检测放大后是否触及源的边界，以禁用或启用PageView的滑动手势。
class InteractiveviewerGallery<T> extends StatefulWidget {
  const InteractiveviewerGallery({
    required this.sources,
    required this.initIndex,
    required this.itemBuilder,
    this.maxScale = 2.5,
    this.minScale = 1.0,
    this.onPageChanged,
  });

  /// 要显示的源列表，类型为泛型T
  final List<T> sources;

  /// 要显示的第一个源在sources中的索引
  final int initIndex;

  /// 用于构建每个项目内容的构建器函数
  final IndexedFocusedWidgetBuilder itemBuilder;

  /// 最大缩放比例，默认为2.5
  final double maxScale;

  /// 最小缩放比例，默认为1.0
  final double minScale;

  /// 页面改变时的回调函数，接收新的页面索引作为参数
  final ValueChanged<int>? onPageChanged;

  @override
  _TweetSourceGalleryState createState() => _TweetSourceGalleryState();
}

class _TweetSourceGalleryState extends State<InteractiveviewerGallery>
    with SingleTickerProviderStateMixin {
  /// 控制PageView的控制器
  PageController? _pageController;

  /// 控制InteractiveViewer变换的控制器
  TransformationController? _transformationController;

  /// 用于在InteractiveViewer需要重置时动画其变换值的控制器
  late AnimationController _animationController;

  /// 用于InteractiveViewer变换动画的Animation对象
  Animation<Matrix4>? _animation;

  /// 当源被放大且不在水平边界时为true，用于禁用PageView
  bool _enablePageView = true;

  /// 当源被放大时为true，用于禁用CustomDismissible
  bool _enableDismiss = true;

  /// 双击手势的本地位置，用于实现双击缩放功能
  late Offset _doubleTapLocalPosition;

  /// 当前页面索引
  int? currentIndex;

  @override
  void initState() {
    super.initState();

    // 初始化PageController，设置初始页面
    _pageController = PageController(initialPage: widget.initIndex);

    // 初始化TransformationController
    _transformationController = TransformationController();

    // 初始化AnimationController，用于控制缩放动画
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )
      ..addListener(() {
        // 在动画过程中更新TransformationController的值
        _transformationController!.value =
            _animation?.value ?? Matrix4.identity();
      })
      ..addStatusListener((AnimationStatus status) {
        // 当动画完成且CustomDismissible被禁用时，重新启用它
        if (status == AnimationStatus.completed && !_enableDismiss) {
          setState(() {
            _enableDismiss = true;
          });
        }
      });

    // 设置当前索引为初始索引
    currentIndex = widget.initIndex;
  }

  @override
  void dispose() {
    // 释放控制器资源
    _pageController!.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// 当源被放大时，禁用上下滑动以关闭的功能
  /// 当比例重置时，启用关闭和页面视图滑动功能
  void _onScaleChanged(double scale) {
    final bool initialScale = scale <= widget.minScale;

    if (initialScale) {
      // 如果缩放比例小于或等于最小比例，启用所有功能
      if (!_enableDismiss) {
        setState(() {
          _enableDismiss = true;
        });
      }

      if (!_enablePageView) {
        setState(() {
          _enablePageView = true;
        });
      }
    } else {
      // 如果缩放比例大于最小比例，禁用滑动关闭和页面切换功能
      if (_enableDismiss) {
        setState(() {
          _enableDismiss = false;
        });
      }

      if (_enablePageView) {
        setState(() {
          _enablePageView = false;
        });
      }
    }
  }

  /// 当放大源后触及左边界时，如果有页面可以滑动到，则启用页面视图滑动
  void _onLeftBoundaryHit() {
    if (!_enablePageView && _pageController!.page!.floor() > 0) {
      setState(() {
        _enablePageView = true;
      });
    }
  }

  /// 当放大源后触及右边界时，如果有页面可以滑动到，则启用页面视图滑动
  void _onRightBoundaryHit() {
    if (!_enablePageView &&
        _pageController!.page!.floor() < widget.sources.length - 1) {
      setState(() {
        _enablePageView = true;
      });
    }
  }

  /// 当源被放大且未触及水平边界时，禁用页面视图滑动
  void _onNoBoundaryHit() {
    if (_enablePageView) {
      setState(() {
        _enablePageView = false;
      });
    }
  }

  /// 当页面视图改变页面时，如果源被放大，则将其动画回原始比例
  /// 同时启用上下滑动以关闭的功能
  void _onPageChanged(int page) {
    setState(() {
      currentIndex = page;
    });
    // 调用外部传入的onPageChanged回调
    widget.onPageChanged?.call(page);

    // 如果当前有缩放，则重置缩放
    if (_transformationController!.value != Matrix4.identity()) {
      // 为交互式查看器的变换重置动画
      _animation = Matrix4Tween(
        begin: _transformationController!.value,
        end: Matrix4.identity(),
      ).animate(
        CurveTween(curve: Curves.easeOut).animate(_animationController),
      );

      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewerBoundary(
      controller: _transformationController,
      boundaryWidth: MediaQuery.of(context).size.width,
      onScaleChanged: _onScaleChanged,
      onLeftBoundaryHit: _onLeftBoundaryHit,
      onRightBoundaryHit: _onRightBoundaryHit,
      onNoBoundaryHit: _onNoBoundaryHit,
      maxScale: widget.maxScale,
      minScale: widget.minScale,
      child: CustomDismissible(
        onDismissed: () => Navigator.of(context).pop(),
        enabled: _enableDismiss,
        child: PageView.builder(
          onPageChanged: _onPageChanged,
          controller: _pageController,
          physics:
              _enablePageView ? null : const NeverScrollableScrollPhysics(),
          itemCount: widget.sources.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onDoubleTapDown: (TapDownDetails details) {
                _doubleTapLocalPosition = details.localPosition;
              },
              onDoubleTap: onDoubleTap,
              child: widget.itemBuilder(context, index, index == currentIndex),
            );
          },
        ),
      ),
    );
  }

  /// 处理双击缩放功能
  onDoubleTap() {
    Matrix4 matrix = _transformationController!.value.clone();
    double currentScale = matrix.row0.x;

    // 确定目标缩放比例
    double targetScale = widget.minScale;
    if (currentScale <= widget.minScale) {
      targetScale = widget.maxScale * 0.7;
    }

    // 计算缩放后的偏移量，以保持双击点在屏幕上的相对位置不变
    double offSetX = targetScale == 1.0
        ? 0.0
        : -_doubleTapLocalPosition.dx * (targetScale - 1);
    double offSetY = targetScale == 1.0
        ? 0.0
        : -_doubleTapLocalPosition.dy * (targetScale - 1);

    // 构建新的变换矩阵
    matrix = Matrix4.fromList([
      targetScale,
      matrix.row1.x,
      matrix.row2.x,
      matrix.row3.x,
      matrix.row0.y,
      targetScale,
      matrix.row2.y,
      matrix.row3.y,
      matrix.row0.z,
      matrix.row1.z,
      targetScale,
      matrix.row3.z,
      offSetX,
      offSetY,
      matrix.row2.w,
      matrix.row3.w
    ]);

    // 创建并启动缩放动画
    _animation = Matrix4Tween(
      begin: _transformationController!.value,
      end: matrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController
        .forward(from: 0)
        .whenComplete(() => _onScaleChanged(targetScale));
  }
}
