import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yun_music/commons/res/app_themes.dart';
import 'package:yun_music/commons/res/dimens.dart';

import '../../commons/values/server.dart';
import '../../utils/adapt.dart';

const double scrollSpeed = 300;

enum VideoPagePosition {
  right,
  middle,
}

class VideoScaffoldController extends ValueNotifier<VideoPagePosition> {
  VideoScaffoldController([VideoPagePosition value = VideoPagePosition.middle])
      : super(value);

  Future Function(VideoPagePosition pagePosition)? _onAnimateToPage;

  Future? animateToPage(VideoPagePosition pagePosition) {
    return _onAnimateToPage?.call(pagePosition);
  }

  Future? animateToRight() {
    return _onAnimateToPage?.call(VideoPagePosition.right);
  }

  Future? animateToMiddle() {
    return _onAnimateToPage?.call(VideoPagePosition.middle);
  }
}

class VideoScaffold extends StatefulWidget {
  final VideoScaffoldController? controller;
  final Widget header;
  final Widget rightPage;

  final int currentIndex;

  final bool? enableGesture;

  final Widget? page;

  final Function()? onPullDownRefresh;

  const VideoScaffold(
      {super.key,
      this.controller,
      required this.header,
      required this.rightPage,
      this.currentIndex = 0,
      this.enableGesture,
      this.page,
      this.onPullDownRefresh});

  @override
  State<VideoScaffold> createState() => _VideoScaffoldState();
}

class _VideoScaffoldState extends State<VideoScaffold>
    with TickerProviderStateMixin {
  AnimationController? animationControllerX;
  AnimationController? animationControllerY;
  late Animation<double> animationX;
  late Animation<double> animationY;
  double offsetX = 0.0;
  double offsetY = 0.0;
  double inMiddle = 0;
  double? screenWidth;

  @override
  void initState() {
    widget.controller!._onAnimateToPage = animateToPage;
    super.initState();
  }

  Future animateToPage(VideoPagePosition p) async {
    if (screenWidth == null) {
      return null;
    }
    switch (p) {
      case VideoPagePosition.middle:
        await animateTo();
        break;
      case VideoPagePosition.right:
        await animateTo(-screenWidth!);
        break;
    }
    widget.controller!.value = p;
  }

  Future animateTo([double end = 0.0]) {
    final curve = curvedAnimation();
    animationX = Tween(begin: offsetX, end: end).animate(curve)
      ..addListener(() {
        setState(() {
          offsetX = animationX.value;
        });
      });
    inMiddle = end;
    return animationControllerX!.animateTo(1);
  }

  CurvedAnimation curvedAnimation() {
    animationControllerX = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: max(offsetX.abs(), 60) * 1000 ~/ 500));
    return CurvedAnimation(
        parent: animationControllerX!, curve: Curves.easeInCubic);
  }

  /// 计算[offsetY]
  ///
  /// 手指上滑,[absorbing]为false，不阻止事件，事件交给底层PageView处理
  /// 处于第一页且是下拉，则拦截滑动
  void calculateOffsetY(DragUpdateDetails details) {
    if (!widget.enableGesture!) return;
    final tempY = offsetY + details.delta.dy / 2;
    if (widget.currentIndex == 0) {
      if (tempY > 0) {
        if (tempY < 40) {
          offsetY = tempY;
        } else if (offsetY != 40) {
          offsetY = 40;
          // vibrate();
        }
      }
      setState(() {});
    } else {
      offsetY = 0;
      setState(() {});
    }
  }

  // 水平方向滑动中
  void onHorizontalDragUpdate(DragUpdateDetails details, double screenWidth) {
    if (!widget.enableGesture!) return;
    // 控制 offsetX 的值在 -screenWidth 到 screenWidth 之间
    if (offsetX + details.delta.dx >= screenWidth) {
      setState(() {
        offsetX = screenWidth;
      });
    } else if (offsetX + details.delta.dx <= -screenWidth) {
      setState(() {
        offsetX = -screenWidth;
      });
    } else {
      setState(() {
        offsetX += details.delta.dx;
      });
    }
  }

  // 水平方向滑动结束
  onHorizontalDragEnd(DragEndDetails details, double screenWidth) {
    if (!widget.enableGesture!) {
      return;
    }
    logger.d('velocity:${details.velocity}');
    final vOffset = details.velocity.pixelsPerSecond.dx;

    // 速度很快时
    if (vOffset < -scrollSpeed && inMiddle == 0) {
      // 去左边页面
      return animateToPage(VideoPagePosition.right);
    } else if (inMiddle > 0 && vOffset < -scrollSpeed) {
      return animateToPage(VideoPagePosition.middle);
    } else if (inMiddle < 0 && vOffset > scrollSpeed) {
      return animateToPage(VideoPagePosition.middle);
    }
    // 当滑动停止的时候 根据 offsetX 的偏移量进行动画
    if (offsetX.abs() < screenWidth * 0.5) {
      // 中间页面
      return animateToPage(VideoPagePosition.middle);
    } else {
      // 去右边页面
      return animateToPage(VideoPagePosition.right);
    }
  }

  /// 滑动到顶部
  ///
  /// [offsetY] to 0.0
  Future animateToTop() {
    animationControllerY = AnimationController(
        duration: Duration(milliseconds: offsetY.abs() * 1000 ~/ 60),
        vsync: this);
    final curve = CurvedAnimation(
        parent: animationControllerY!, curve: Curves.easeOutCubic);
    animationY = Tween(begin: offsetY, end: 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          offsetY = animationY.value;
        });
      });
    return animationControllerY!.forward();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = context.width;
    Widget body = Stack(
      children: [
        _MiddlePage(
            offsetX: offsetX,
            offsetY: offsetY,
            header: widget.header,
            page: widget.page),
        _RightPageTransform(
            offsetX: offsetX, offsetY: offsetY, content: widget.rightPage),
      ],
    );
    // 增加手势控制
    body = GestureDetector(
      onVerticalDragUpdate: calculateOffsetY,
      onVerticalDragEnd: (_) async {
        if (!widget.enableGesture!) return;
        if (offsetY != 0) {
          await animateToTop();
          widget.onPullDownRefresh?.call();
          setState(() {});
        }
      },
      // onHorizontalDragEnd: (details) => onHorizontalDragEnd(
      //   details,
      //   screenWidth!,
      // ),
      // // 水平方向滑动开始
      // onHorizontalDragStart: (_) {
      //   if (!widget.enableGesture!) return;
      //   animationControllerX?.stop();
      //   animationControllerY?.stop();
      // },
      // onHorizontalDragUpdate: (details) => onHorizontalDragUpdate(
      //   details,
      //   screenWidth!,
      // ),
      child: body,
    );
    body = WillPopScope(
      onWillPop: () async {
        if (!widget.enableGesture!) return true;
        if (inMiddle == 0) {
          return true;
        }
        widget.controller!.animateToMiddle();
        return false;
      },
      child: Scaffold(
        body: body,
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
      ),
    );
    return body;
  }
}

class _MiddlePage extends StatelessWidget {
  final Widget? page;
  final double? offsetX;
  final double? offsetY;
  final Widget header;
  const _MiddlePage(
      {this.page, this.offsetX, this.offsetY, required this.header});

  @override
  Widget build(BuildContext context) {
    final Widget _mainVideoList = Container(
      color: AppThemes.back1,
      child: page,
    );
    final Widget _headerContain = SafeArea(
        child: SizedBox(
      height: Dimens.gap_dp44,
      child: header,
    ));
    final Widget middle = Transform.translate(
      offset: Offset(offsetX! > 0 ? offsetX! : offsetX! / 5, 0),
      child: Stack(
        children: [
          _mainVideoList,
          _headerContain,
        ],
      ),
    );

    return middle;
  }
}

// ignore: unused_element
class _RightPageTransform extends StatelessWidget {
  final double? offsetX;
  final double? offsetY;
  final Widget content;

  const _RightPageTransform(
      {this.offsetX, this.offsetY, required this.content});

  @override
  Widget build(BuildContext context) {
    final screenWidth = Adapt.screenW();
    final screenHeight = Adapt.screenH();
    return Transform.translate(
      offset: Offset(max(0, offsetX! + screenWidth), 0),
      child: Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.transparent,
          child: content),
    );
  }
}
