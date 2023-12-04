import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pages/chat/chat_event_list.dart';
import 'package:fluffychat/pages/chat/chat_loading_view.dart';
import 'package:fluffychat/pages/chat/chat_view_body_style.dart';
import 'package:fluffychat/pages/chat/chat_view_style.dart';
import 'package:fluffychat/pages/chat/events/message_content_mixin.dart';
import 'package:fluffychat/pages/chat/chat_pinned_events/pinned_events_view.dart';
import 'package:fluffychat/pages/chat/reply_display.dart';
import 'package:fluffychat/pages/chat/tombstone_display.dart';
import 'package:fluffychat/widgets/connection_status_header.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';
import 'chat_emoji_picker.dart';
import 'chat_input_row.dart';

class ChatViewBody extends StatelessWidget with MessageContentMixin {
  final ChatController controller;

  const ChatViewBody(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) => controller.handleDragDone(details),
      onDragEntered: controller.onDragEntered,
      onDragExited: controller.onDragExited,
      child: Stack(
        children: <Widget>[
          if (Matrix.of(context).wallpaper != null)
            Image.file(
              Matrix.of(context).wallpaper!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    if (controller.room!.pinnedEventIds.isNotEmpty)
                      const SizedBox(
                        height: ChatViewStyle.pinnedMessageHintHeight,
                      ),
                    Expanded(
                      child: GestureDetector(
                        onTap: controller.clearSingleSelectedEvent,
                        child: Builder(
                          builder: (context) {
                            if (controller.timeline == null) {
                              return const ChatLoadingView();
                            }
                            return ChatEventList(
                              controller: controller,
                            );
                          },
                        ),
                      ),
                    ),
                    if (controller.room!.canSendDefaultMessages &&
                        controller.room!.membership == Membership.join)
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: TwakeThemes.columnWidth * 2.5,
                        ),
                        alignment: Alignment.center,
                        child: controller.room?.isAbandonedDMRoom == true
                            ? Padding(
                                padding: EdgeInsets.only(
                                  bottom: ChatViewBodyStyle.bottomSheetPadding(
                                    context,
                                  ),
                                  left: ChatViewBodyStyle.bottomSheetPadding(
                                    context,
                                  ),
                                  right: ChatViewBodyStyle.bottomSheetPadding(
                                    context,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.all(16),
                                        foregroundColor:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      icon: const Icon(
                                        Icons.archive_outlined,
                                      ),
                                      onPressed: controller.leaveChat,
                                      label: Text(
                                        L10n.of(context)!.leave,
                                      ),
                                    ),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.all(16),
                                      ),
                                      icon: const Icon(
                                        Icons.chat_outlined,
                                      ),
                                      onPressed: controller.recreateChat,
                                      label: Text(
                                        L10n.of(context)!.reopenChat,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _inputMessageWidget(
                                ChatViewBodyStyle.bottomSheetPadding(context),
                              ),
                      ),
                  ],
                ),
                TombstoneDisplay(controller),
                PinnedEventsView(controller),
              ],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller.draggingNotifier,
            builder: (context, dragging, _) {
              if (!dragging) return const SizedBox.shrink();
              return Container(
                color:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.upload_outlined,
                  size: 100,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _inputMessageWidget(double bottomSheetPadding) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...[
          const ConnectionStatusHeader(),
          // Currently we can't support reactions
          // ReactionsPicker(controller),
          ReplyDisplay(controller),
          ChatInputRow(controller),
        ].map(
          (widget) => Padding(
            padding: EdgeInsets.only(
              left: bottomSheetPadding,
              right: bottomSheetPadding,
            ),
            child: widget,
          ),
        ),
        SizedBox(height: bottomSheetPadding),
        ChatEmojiPicker(controller),
      ],
    );
  }
}
