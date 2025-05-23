import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yun_music/commons/models/song_model.dart';

class CheckSongController extends GetxController
    with GetTickerProviderStateMixin {
  //是否展示编辑
  final showCheck = false.obs;
  //以选中的歌曲
  final selectedSong = Rx<List<Song>?>(null);

  //底部歌曲控制兰动画
  late AnimationController controller;
  late Animation<Offset> animation;

  @override
  void onInit() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    //从下到上
    animation = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
        .animate(controller);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    showCheck.listen((p0) {
      selectedSong.value = null;
      if (p0) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
