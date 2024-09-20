import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_preview_image_video_demo/display_gesture_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_preview_image_video_demo/common/hero_dialog_route.dart';
import 'package:flutter_preview_image_video_demo/common/interactiveviewer_gallery.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer';

// 应用程序入口点
void main() {
  runApp(const MyApp());
}

// 应用程序的根Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'InteraGallery Demo',
      // DisplayGesture 仅用于调试，实际使用时应移除
      home: DisplayGesture(
        child: InteractiveviewDemoPage(),
      ),
    );
  }
}

// 定义演示用的数据实体类
class DemoSourceEntity {
  int id;
  String url;
  String? previewUrl;
  String type;

  DemoSourceEntity(this.id, this.type, this.url, {this.previewUrl});
}

// 交互式查看器演示页面
class InteractiveviewDemoPage extends StatefulWidget {
  static const String sName = "/";

  const InteractiveviewDemoPage({super.key});

  @override
  InteractiveviewDemoPageState createState() => InteractiveviewDemoPageState();
}

class InteractiveviewDemoPageState extends State<InteractiveviewDemoPage> {
  // 定义演示用的数据源列表
  List<DemoSourceEntity> sourceList = [
    DemoSourceEntity(0, 'image',
        'https://img.zcool.cn/community/010d5c5b9d17c9a8012099c8781b7e.jpg@1280w_1l_2o_100sh.jpg'),
    DemoSourceEntity(1, 'image',
        'https://boot-img.xuexi.cn/image/1006/process/b5e3a02d382649ff8565323f48320b36.jpg'),
    DemoSourceEntity(2, 'image',
        'https://bpic.588ku.com/back_pic/06/11/77/75621df811753bb.jpg'),
    DemoSourceEntity(3, 'image',
        'https://pic.616pic.com/bg_w1180/00/00/81/zi58oHApHm.jpg!/fw/880'),
    DemoSourceEntity(4, 'video',
        'https://vdept3.bdstatic.com/mda-qi53va8kshx38i11/360p/h264/1725590729994440709/mda-qi53va8kshx38i11.mp4?v_from_s=hkapp-haokan-hnb&auth_key=1726808914-0-0-015b2c8bdc73730d84411de283417954&bcevod_channel=searchbox_feed&cr=0&cd=0&pd=1&pt=3&logid=0514486819&vid=8928758202794709822&klogid=0514486819&abtest=',
        previewUrl:
            'https://f7.baidu.com/it/u=3500985206,1234947441&fm=222&app=106&f=JPEG?x-bce-process=image/quality,q_100/resize,m_fill,w_681,h_381/format,f_auto'),
    DemoSourceEntity(5, 'video',
        'https://vdept3.bdstatic.com/mda-qhugjv0pwgr1mexz/cae_h264/1724932126917200045/mda-qhugjv0pwgr1mexz.mp4?v_from_s=hkapp-haokan-hnb&auth_key=1726809249-0-0-599c9a181d15e95f258b543f38dd8205&bcevod_channel=searchbox_feed&cr=0&cd=0&pd=1&pt=3&logid=0849490885&vid=8632165288336430437&klogid=0849490885&abtest=',
        previewUrl:
            'https://f7.baidu.com/it/u=632968689,1916843631&fm=222&app=106&f=JPEG?x-bce-process=image/quality,q_100/resize,m_fill,w_454,h_256/format,f_auto'),
    DemoSourceEntity(6, 'image',
        'https://img.cgmol.com/excellentwork/20150729/191501_20150729103856ql7wk9qchh2lijy.jpg'),
    DemoSourceEntity(7, 'image',
        'https://scpic.chinaz.net/files/pic/pic9/202009/apic27883.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InteractiveviewerGallery Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Wrap(
          children: sourceList.map((source) => _buildItem(source)).toList(),
        ),
      ),
    );
  }

  // 构建单个项目的Widget
  Widget _buildItem(DemoSourceEntity source) {
    return Hero(
      tag: source.id,
      placeholderBuilder: (BuildContext context, Size heroSize, Widget child) {
        // 保持构建图像，因为图像可能在图库背景中可见
        return child;
      },
      child: GestureDetector(
        onTap: () => _openGallery(source),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CachedNetworkImage(
              imageUrl:
                  source.type == 'video' ? source.previewUrl! : source.url,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
            source.type == 'video'
                ? const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  // 打开图库
  void _openGallery(DemoSourceEntity source) {
    Navigator.of(context).push(
      HeroDialogRoute<void>(
        // DisplayGesture 仅用于调试，实际使用时应移除
        builder: (BuildContext context) => DisplayGesture(
          child: InteractiveviewerGallery<DemoSourceEntity>(
            sources: sourceList,
            initIndex: sourceList.indexOf(source),
            itemBuilder: itemBuilder,
            onPageChanged: (int pageIndex) {
              log("nell-pageIndex:$pageIndex");
            },
          ),
        ),
      ),
    );
  }

  // 构建图库中的单个项目
  Widget itemBuilder(BuildContext context, int index, bool isFocus) {
    DemoSourceEntity sourceEntity = sourceList[index];
    if (sourceEntity.type == 'video') {
      return DemoVideoItem(
        sourceEntity,
        isFocus: isFocus,
      );
    } else {
      return DemoImageItem(sourceEntity);
    }
  }
}

// 演示用的图片项目Widget
class DemoImageItem extends StatefulWidget {
  final DemoSourceEntity source;

  const DemoImageItem(this.source, {super.key});

  @override
  DemoImageItemState createState() => DemoImageItemState();
}

class DemoImageItemState extends State<DemoImageItem> {
  @override
  void initState() {
    super.initState();
    log('initState: ${widget.source.id}');
  }

  @override
  void dispose() {
    super.dispose();
    log('dispose: ${widget.source.id}');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Center(
        child: Hero(
          tag: widget.source.id,
          child: CachedNetworkImage(
            imageUrl: widget.source.url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// 演示用的视频项目Widget
class DemoVideoItem extends StatefulWidget {
  final DemoSourceEntity source;
  final bool? isFocus;

  const DemoVideoItem(this.source, {super.key, this.isFocus});

  @override
  DemoVideoItemState createState() => DemoVideoItemState();
}

class DemoVideoItemState extends State<DemoVideoItem> {
  VideoPlayerController? _controller;
  late VoidCallback listener;
  String? localFileName;

  DemoVideoItemState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    log('initState: ${widget.source.id}');
    init();
  }

  // 初始化视频控制器
  init() async {
    _controller = VideoPlayerController.network(widget.source.url);
    // 循环播放
    _controller!.setLooping(true);
    await _controller!.initialize();
    setState(() {});
    _controller!.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    log('dispose: ${widget.source.id}');
    _controller!.removeListener(listener);
    _controller?.pause();
    _controller?.dispose();
  }

  @override
  void didUpdateWidget(covariant DemoVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isFocus! && !widget.isFocus!) {
      // 暂停
      _controller?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller!.value.isInitialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                child: Hero(
                  tag: widget.source.id,
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
              _controller!.value.isPlaying == true
                  ? const SizedBox()
                  : const IgnorePointer(
                      ignoring: true,
                      child: Icon(
                        Icons.play_arrow,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
            ],
          )
        : Theme(
            data: ThemeData(
                cupertinoOverrideTheme:
                    const CupertinoThemeData(brightness: Brightness.dark)),
            child: const CupertinoActivityIndicator(radius: 30));
  }
}
