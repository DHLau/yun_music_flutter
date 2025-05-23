// ignore_for_file: unnecessary_overrides

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:yun_music/commons/models/song_model.dart';

class PlayerService extends GetxService {
  static PlayerService get to => Get.find();

  //当前播放的歌曲ID
  final curPlayId = Rx<int?>(null);

  //当前播放的歌曲
  final curPlay = Rx<Song?>(null);

  //刚进入下一页面PlayBar的变化
  final plarBarBottom = 0.0.obs;

  final playBarHeight = 0.0.obs;

  //以选中的歌曲
  final selectedSongList = Rx<List<Song>?>(null);
  final selectedSong = Rx<Song?>(null);

  final playingBgColor = Rx<Color?>(null);

  @override
  void onInit() {
    super.onInit();
    // player = AudioPlayer();
    // getCachePlayingList();
    // _update();
  }

  void getPlayingBgColor() {
    PaletteGenerator.fromImageProvider(
            NetworkImage(PlayerService.to.curPlay.value?.al.picUrl ?? ""))
        .then((paletteGenerator) {
      if (paletteGenerator.darkVibrantColor != null) {
        playingBgColor.value = paletteGenerator.darkMutedColor?.color;
      } else {
        playingBgColor.value = paletteGenerator.colors.first;
      }
    });
  }
}
