import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yun_music/utils/adapt.dart';

import '../../commons/res/app_routes.dart';
import '../../commons/res/dimens.dart';
import '../../utils/image_utils.dart';

class PlayingNavBar extends StatelessWidget implements PreferredSizeWidget {
  const PlayingNavBar({super.key, this.song});

  final MediaItem? song;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: Get.theme.appBarTheme.toolbarHeight,
      width: double.infinity,
      // padding: EdgeInsets.only(left: Adapt.px(2), right: Adapt.px(10)),
      margin: EdgeInsets.only(top: Adapt.topPadding()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              // final controller = Get.find<PlayerController>();
              // controller.animationController.reverse();
              Get.back();
            },
            child: Container(
              color: Colors.transparent,
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: Image.asset(
                ImageUtils.getImagePath('cm8_nav_icn_down'),
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  maxLines: 1,
                  song!.title.fixAutoLines(),
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
                GestureDetector(
                  onTap: () {
                    if (song?.extras?["artist_id"] == null) {
                      return;
                    }
                    final List<dynamic>? artIds = song?.extras?["artist_id"];
                    final artId = artIds!.isNotEmpty ? artIds.first : 0;
                    Get.toNamed(RouterPath.Artist_Detail,
                        arguments: {"artist_id": artId});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(
                          (song?.artist ?? "").fixAutoLines(),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: Dimens.font_sp10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: Dimens.gap_dp18,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            color: Colors.transparent,
            margin: const EdgeInsets.only(right: 16, left: 16),
            child: Image.asset(
              ImageUtils.getImagePath('cm6_nav_icn_share'),
              width: 26,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(Get.theme.appBarTheme.toolbarHeight ?? 56);
}

extension FixAutoLines on String {
  String fixAutoLines() {
    return Characters(this).join('\u{200B}');
  }
}
