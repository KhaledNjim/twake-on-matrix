import 'package:fluffychat/pages/chat/chat_input_row_style.dart';
import 'package:fluffychat/resource/image_paths.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/twake_components/twake_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ChatInputRowSendBtn extends StatelessWidget {
  final ValueListenable<String> inputText;
  final void Function() onTap;

  const ChatInputRowSendBtn({
    Key? key,
    required this.inputText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: inputText,
      builder: (context, textInput, child) {
        if (PlatformInfos.isWeb && textInput.isEmpty) {
          return IgnorePointer(
            ignoring: true,
            child: Opacity(
              opacity: ChatInputRowStyle.inputComposerOpacity,
              child: child!,
            ),
          );
        }

        if (textInput.isNotEmpty) {
          return child!;
        }

        return const SizedBox();
      },
      child: Padding(
        padding: ChatInputRowStyle.sendIconPadding,
        child: TwakeIconButton(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          size: ChatInputRowStyle.sendIconBtnSize,
          onTap: onTap,
          tooltip: L10n.of(context)!.send,
          imagePath: ImagePaths.icSend,
          paddingAll: 0,
        ),
      ),
    );
  }
}
