import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/widgets/avatar/avatar.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ChatListItemAvatar extends StatefulWidget {
  final Room room;
  final void Function()? onTap;
  final JoinedRoomUpdate? joinedRoomUpdate;

  const ChatListItemAvatar({
    required this.room,
    this.onTap,
    this.joinedRoomUpdate,
    super.key,
  });

  @override
  State<ChatListItemAvatar> createState() => _ChatListItemAvatarState();
}

class _ChatListItemAvatarState extends State<ChatListItemAvatar> {
  final ValueNotifier<Uri?> avatarUrlNotifier = ValueNotifier<Uri>(Uri());

  @override
  void initState() {
    avatarUrlNotifier.value = widget.room.avatar ?? Uri();
    super.initState();
  }

  @override
  void dispose() {
    avatarUrlNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatListItemAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.joinedRoomUpdate != widget.joinedRoomUpdate) {
      updateAvatarUrlFromJoinedRoomUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.room.getLocalizedDisplayname(
      MatrixLocals(L10n.of(context)!),
    );
    return ValueListenableBuilder(
      valueListenable: avatarUrlNotifier,
      builder: (context, avatarUrl, child) {
        return Avatar(
          mxContent: avatarUrl,
          name: displayName,
          onTap: widget.onTap,
        );
      },
    );
  }

  void updateAvatarUrlFromJoinedRoomUpdate() {
    if (isChatHaveAvatarUpdated) {
      if (isGroupChatAvatarUpdated) {
        updateGroupAvatar();
      } else if (isDirectChatAvatarUpdated) {
        updateDirectChatAvatar();
      }
    }
  }

  bool get isChatHaveAvatarUpdated =>
      widget.joinedRoomUpdate?.timeline?.events?.isNotEmpty == true;

  bool get isDirectChatAvatarUpdated {
    return widget.room.isDirectChat &&
        widget.joinedRoomUpdate?.timeline?.events?.last.type ==
            EventTypes.RoomMember;
  }

  bool get isGroupChatAvatarUpdated =>
      widget.joinedRoomUpdate?.timeline?.events?.last.type ==
      EventTypes.RoomAvatar;

  void updateDirectChatAvatar() {
    final event = widget.joinedRoomUpdate?.timeline?.events?.last;
    final avatarMxc = event?.content['avatar_url'];
    if (avatarMxc is String &&
        avatarMxc.isNotEmpty &&
        event?.senderId == widget.room.directChatMatrixID) {
      avatarUrlNotifier.value = Uri.tryParse(avatarMxc);
    }
  }

  void updateGroupAvatar() {
    final avatarMxc =
        widget.joinedRoomUpdate?.timeline?.events?.last.content['url'];

    if (avatarMxc is String && avatarMxc.isNotEmpty) {
      avatarUrlNotifier.value = Uri.tryParse(avatarMxc);
    }
  }
}
