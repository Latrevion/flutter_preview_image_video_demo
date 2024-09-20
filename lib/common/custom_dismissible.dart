import 'package:flutter/material.dart';

/// 一个用于实现可滑动消失效果的自定义 Widget。
///
/// 这个 Widget 类似于 Flutter 的 [Dismissible]，但提供了更多的自定义选项。
/// 它允许通过垂直拖动来使子组件消失，并提供了动画效果。
class CustomDismissible extends StatefulWidget {
  const CustomDismissible({
    required this.child,
    this.onDismissed,
    this.dismissThreshold = 0.2,
    this.enabled = false,
  });

  /// 要被包裹的子组件，这是将要显示并可能被滑动消失的内容
  final Widget child;

  /// 定义触发消失效果的阈值，默认为 0.2（20%）
  /// 当拖动距离超过这个阈值时，会触发消失效果
  final double dismissThreshold;

  /// 当组件被成功消失时调用的回调函数
  /// 可以用来执行一些清理操作或状态更新
  final VoidCallback? onDismissed;

  /// 控制是否启用消失功能，默认为 true
  /// 设置为 false 时，组件将无法被拖动
  final bool enabled;

  @override
  _CustomDismissibleState createState() => _CustomDismissibleState();
}

class _CustomDismissibleState extends State<CustomDismissible>
    with SingleTickerProviderStateMixin {
  /// 控制整体动画效果的控制器
  late AnimationController _animateController;

  /// 控制移动效果的动画，用于实现滑动效果
  late Animation<Offset> _moveAnimation;

  /// 控制缩放效果的动画，使组件在消失时变小
  late Animation<double> _scaleAnimation;

  /// 控制透明度效果的动画，使组件在消失时逐渐透明
  late Animation<Decoration> _opacityAnimation;

  /// 记录当前拖动的距离
  double _dragExtent = 0;

  /// 标记是否正在进行拖动操作
  bool _dragUnderway = false;

  /// 判断组件是否处于活动状态（正在拖动或动画进行中）
  bool get _isActive => _dragUnderway || _animateController.isAnimating;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器，设置动画持续时间为 300 毫秒
    _animateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _updateMoveAnimation();
  }

  @override
  void dispose() {
    // 释放动画控制器资源，防止内存泄漏
    _animateController.dispose();
    super.dispose();
  }

  /// 更新移动动画的相关参数
  void _updateMoveAnimation() {
    // 根据拖动方向确定结束位置
    final double end = _dragExtent.sign;

    // 设置移动动画，从原位置移动到结束位置
    _moveAnimation = _animateController.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: Offset(0, end),
      ),
    );

    // 设置缩放动画，使组件在消失时缩小到原来的一半
    _scaleAnimation = _animateController.drive(Tween<double>(
      begin: 1,
      end: 0.5,
    ));

    // 设置透明度动画，使组件从不透明变为完全透明
    _opacityAnimation = DecorationTween(
      begin: BoxDecoration(color: const Color(0xFF000000)),
      end: BoxDecoration(color: const Color(0x00000000)),
    ).animate(_animateController);
  }

  /// 处理拖动开始事件
  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;

    if (_animateController.isAnimating) {
      // 如果动画正在进行，停止动画并记录当前拖动距离
      _dragExtent =
          _animateController.value * context.size!.height * _dragExtent.sign;
      _animateController.stop();
    } else {
      // 否则重置拖动距离和动画控制器
      _dragExtent = 0.0;
      _animateController.value = 0.0;
    }
    setState(_updateMoveAnimation);
  }

  /// 处理拖动更新事件
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isActive || _animateController.isAnimating) {
      return;
    }

    //原有的计算方式 start
    // // 计算新的拖动距离
    // final double delta = details.primaryDelta!;
    // final double oldDragExtent = _dragExtent;

    // // 更新拖动距离
    // if (_dragExtent + delta < 0) {
    //   _dragExtent += delta;
    // } else if (_dragExtent + delta > 0) {
    //   _dragExtent += delta;
    // }
    //
    // // 如果拖动方向改变，更新动画
    // if (oldDragExtent.sign != _dragExtent.sign) {
    //   setState(_updateMoveAnimation);
    // }
    //
    // // 更新动画控制器的值
    // if (!_animateController.isAnimating) {
    //   _animateController.value = _dragExtent.abs() / context.size!.height;
    // }
    //原有的计算方式 end

    // 只处理向下拖动
    final double delta = details.primaryDelta!;
    if (delta > 0) {
      final double oldDragExtent = _dragExtent;
      _dragExtent += delta;

      if (oldDragExtent.sign != _dragExtent.sign) {
        setState(_updateMoveAnimation);
      }

      if (!_animateController.isAnimating) {
        _animateController.value = _dragExtent.abs() / context.size!.height;
      }
    }
  }

  /// 处理拖动结束事件(原有的方式)
  // void _handleDragEnd(DragEndDetails details) {
  //   if (!_isActive || _animateController.isAnimating) {
  //     return;
  //   }
  //
  //   _dragUnderway = false;
  //
  //   if (_animateController.isCompleted) {
  //     return;
  //   }
  //
  //   if (!_animateController.isDismissed) {
  //     // 如果拖动值超过 dismissThreshold，调用 onDismissed 回调
  //     // 否则，将组件动画回到初始位置
  //     if (_animateController.value > widget.dismissThreshold) {
  //       widget.onDismissed?.call();
  //     } else {
  //       _animateController.reverse();
  //     }
  //   }
  // }

  /// 处理拖动结束事件
  void _handleDragEnd(DragEndDetails details) {
    if (!_isActive || _animateController.isAnimating) {
      return;
    }

    _dragUnderway = false;

    if (_animateController.isCompleted) {
      return;
    }

    if (!_animateController.isDismissed) {
      // 如果拖动值超过 dismissThreshold，调用 onDismissed 回调
      // 否则，将组件动画回到初始位置
      if (_animateController.value > widget.dismissThreshold) {
        widget.onDismissed?.call();
      } else {
        _animateController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 构建带有动画效果的内容
    final Widget content = DecoratedBoxTransition(
      decoration: _opacityAnimation,
      child: SlideTransition(
        position: _moveAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );

    // 返回带有手势检测的小部件
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: widget.enabled ? _handleDragStart : null,
      onVerticalDragUpdate: widget.enabled ? _handleDragUpdate : null,
      onVerticalDragEnd: widget.enabled ? _handleDragEnd : null,
      child: content,
    );
  }
}
