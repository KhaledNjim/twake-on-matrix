import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class ChatLoadingView extends StatelessWidget {
  const ChatLoadingView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        if (index < 3) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SkeletonItem(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      shape: BoxShape.circle,
                      width: 38,
                      height: 38,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SkeletonParagraph(
                      style: SkeletonParagraphStyle(
                        padding: EdgeInsets.zero,
                        lines: index + 1,
                        spacing: 8,
                        lineStyle: SkeletonLineStyle(
                          randomLength: true,
                          width: _random(
                            MediaQuery.of(context).size.width ~/ 2,
                            MediaQuery.of(context).size.width ~/ 0.25,
                          ).toDouble(),
                          height: _random(56, 96).toDouble(),
                          borderRadius: BorderRadius.circular(16),
                          minLength: MediaQuery.of(context).size.width / 4,
                          maxLength: MediaQuery.of(context).size.width / 0.25,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SkeletonItem(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(
                    height: 46,
                    width: 46,
                  ),
                  Expanded(
                    child: SkeletonParagraph(
                      style: SkeletonParagraphStyle(
                        padding: EdgeInsets.zero,
                        lines: _random(1, 3),
                        spacing: 8,
                        lineStyle: SkeletonLineStyle(
                          alignment: AlignmentDirectional.centerEnd,
                          randomLength: true,
                          width: _random(
                            MediaQuery.of(context).size.width ~/ 2,
                            MediaQuery.of(context).size.width ~/ 0.25,
                          ).toDouble(),
                          height: _random(56, 96).toDouble(),
                          borderRadius: BorderRadius.circular(16),
                          minLength: MediaQuery.of(context).size.width / 4,
                          maxLength: MediaQuery.of(context).size.width / 0.25,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  int _random(int min, int max) {
    return min + Random().nextInt(max - min);
  }
}
