import 'package:flutter/material.dart';

/// DisplayGesture 小部件
///
/// 这个小部件用于显示用户的触摸手势。它会在触摸点的位置显示一个圆形指示器。
class DisplayGesture extends StatefulWidget {
  /// 要显示的子部件
  final Widget? child;

  /// 构造函数
  const DisplayGesture({super.key, this.child});

  @override
  _DisplayGestureState createState() => _DisplayGestureState();
}

class _DisplayGestureState extends State<DisplayGesture> {
  /// 存储当前活跃的触摸点事件
  List<PointerEvent> displayModelList = [];

  @override
  Widget build(BuildContext context) {
    return Listener(
      // 监听触摸开始事件
      onPointerDown: (PointerDownEvent event) {
        // 将新的触摸点添加到列表中
        displayModelList.add(event);
        // 触发重建以显示新的触摸点
        setState(() {});
      },
      // 监听触摸移动事件
      onPointerMove: (PointerMoveEvent event) {
        // 更新已存在的触摸点位置
        for (int i = 0; i < displayModelList.length; i++) {
          if (displayModelList[i].pointer == event.pointer) {
            displayModelList[i] = event;
            // 触发重建以更新触摸点位置
            setState(() {});
            return;
          }
        }
      },
      // 监听触摸结束事件
      onPointerUp: (PointerUpEvent event) {
        // 移除结束的触摸点
        for (int i = 0; i < displayModelList.length; i++) {
          if (displayModelList[i].pointer == event.pointer) {
            displayModelList.removeAt(i);
            // 触发重建以移除触摸点显示
            setState(() {});
            return;
          }
        }
      },
      child: Stack(
        children: [
          // 显示传入的子部件
          widget.child!,
          // 为每个触摸点创建一个指示器
          ...displayModelList.map((PointerEvent e) {
            return Positioned(
              // 将指示器定位到触摸点的位置，考虑指示器的大小进行偏移
              left: e.position.dx - 30,
              top: e.position.dy - 30,
              child: Container(
                // 指示器的大小
                width: 60,
                height: 60,
                alignment: Alignment.center,
                // 指示器的样式
                decoration: const BoxDecoration(
                    color: Color(0x99ffffff), // 半透明白色背景
                    borderRadius:
                        BorderRadius.all(Radius.circular(30))), // 圆形边框
                // 指示器的图标
                child: const Icon(
                  Icons.adjust,
                  size: 40,
                  color: Colors.greenAccent,
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}
