import 'dart:ui';

import 'package:flutter/material.dart';

/// 一个带有半透明背景的自定义 [PageRoute]。
///
/// 这个路由类主要用于创建一个类似对话框的页面，但支持 Hero 动画。
/// 它允许背景部分可见，并且可以通过点击背景来关闭。
class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({
    required this.builder,
    this.onBackgroundTap,
  }) : super();

  /// 用于构建路由内容的构建器函数
  /// 这个函数接收一个 BuildContext 并返回一个 Widget
  final WidgetBuilder builder;

  /// 当背景被点击时调用的回调函数
  /// 可以用来自定义背景点击的行为，例如关闭对话框
  final VoidCallback? onBackgroundTap;

  @override

  /// 控制路由是否完全遮盖其下层路由
  /// 设置为 false 允许下层路由部分可见，创造半透明效果
  bool get opaque => false;

  @override

  /// 控制是否可以通过点击背景来关闭路由
  /// true 表示可以通过点击背景关闭路由
  bool get barrierDismissible => true;

  @override

  /// 障碍物（背景）的语义标签，用于辅助功能
  /// 返回 null 表示没有特定的语义标签
  String? get barrierLabel => null;

  @override

  /// 定义路由转场动画的持续时间
  /// 这里设置为 300 毫秒，可以根据需要调整
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override

  /// 控制在路由不可见时是否保持其状态
  /// true 表示即使路由不可见也保持其状态，有利于性能优化
  bool get maintainState => true;

  @override

  /// 设置背景（障碍物）的颜色
  /// 返回 null 表示背景完全透明
  Color? get barrierColor => null;

  @override

  /// 构建路由转场动画
  /// 这个方法定义了如何从一个页面过渡到另一个页面
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 使用淡入淡出效果，使页面平滑地出现和消失
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }

  @override

  /// 构建路由页面的内容
  /// 这个方法负责创建实际显示的页面内容
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // 使用提供的 builder 函数构建子 widget
    final Widget child = builder(context);
    // 添加语义信息，有助于辅助功能
    final Widget result = Semantics(
      scopesRoute: true, // 表示这是一个新的语义范围
      explicitChildNodes: true, // 子节点有自己的语义
      child: child,
    );
    return result;
  }
}
