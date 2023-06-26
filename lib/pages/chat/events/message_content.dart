import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pages/chat/events/message_content_style.dart';
import 'package:fluffychat/pages/chat/events/sending_image_widget.dart';
import 'package:fluffychat/widgets/twake_link_text.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart' hide Visibility;

import 'package:fluffychat/pages/chat/events/video_player.dart';
import 'package:fluffychat/utils/adaptive_bottom_sheet.dart';
import 'package:fluffychat/utils/date_time_extension.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/event_extension.dart';
import 'package:fluffychat/widgets/avatar/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
import '../../../config/app_config.dart';
import '../../../utils/platform_infos.dart';
import '../../../utils/url_launcher.dart';
import '../../bootstrap/bootstrap_dialog.dart';
import 'audio_player.dart';
import 'cute_events.dart';
import 'html_message.dart';
import 'image_bubble.dart';
import 'map_bubble.dart';
import 'message_download_content.dart';
import 'sticker.dart';

class MessageContent extends StatelessWidget {
  final Event event;
  final Color textColor;
  final void Function(Event)? onInfoTab;
  final Widget endOfBubbleWidget;
  final Color backgroundColor;
  final Function()? onTapPreview;
  final Function()? onTapSelectMode;
  final ChatController controller;

  const MessageContent(
    this.event, {
    this.onInfoTab,
    Key? key,
    required this.controller,
    required this.textColor,
    required this.endOfBubbleWidget,
    required this.backgroundColor,
    this.onTapPreview,
    this.onTapSelectMode
  }) : super(key: key);

  void _verifyOrRequestKey(BuildContext context) async {
    final l10n = L10n.of(context)!;
    if (event.content['can_request_session'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            event.type == EventTypes.Encrypted
                ? l10n.needPantalaimonWarning
                : event.calcLocalizedBodyFallback(
                    MatrixLocals(l10n),
                  ),
          ),
        ),
      );
      return;
    }
    final client = Matrix.of(context).client;
    if (client.isUnknownSession && client.encryption!.crossSigning.enabled) {
      final success = await BootstrapDialog(
        client: Matrix.of(context).client,
      ).show(context);
      if (success != true) return;
    }
    event.requestKey();
    final sender = event.senderFromMemoryOrFallback;
    await showAdaptiveBottomSheet(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          leading: CloseButton(onPressed: Navigator.of(context).pop),
          title: Text(
            l10n.whyIsThisMessageEncrypted,
            style: TextStyle(fontSize: MessageContentStyle.appBarFontSize),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Avatar(
                  mxContent: sender.avatarUrl,
                  name: sender.calcDisplayname(),
                ),
                title: Text(sender.calcDisplayname()),
                subtitle: Text(event.originServerTs.localizedTime(context)),
                trailing: const Icon(Icons.lock_outlined),
              ),
              const Divider(),
              Text(
                event.calcLocalizedBodyFallback(
                  MatrixLocals(l10n),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = AppConfig.messageFontSize * AppConfig.fontSizeFactor;
    final buttonTextColor =
        event.senderId == Matrix.of(context).client.userID ? textColor : null;
    switch (event.type) {
      case EventTypes.Message:
      case EventTypes.Encrypted:
      case EventTypes.Sticker:
        switch (event.messageType) {
          case MessageTypes.Image:
            if (event.status == EventStatus.error) {
              return SizedBox(
                width: MessageContentStyle.imageBubbleWidth,
                height: MessageContentStyle.imageBubbleHeight,
                child: const Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              );
            }

            final sendingImageData = event.getSendingImageData();
            if (sendingImageData != null) {
              return SendingImageWidget(
                sendingImageData: sendingImageData,
                event: event,
                onTapPreview: onTapPreview,
              );
            }
            return ImageBubble(
              event,
              width: MessageContentStyle.imageBubbleWidth,
              height: MessageContentStyle.imageBubbleHeight,
              fit: BoxFit.cover,
              onTapSelectMode: onTapSelectMode,
              onTapPreview: onTapPreview,
            );
          case MessageTypes.Sticker:
            if (event.redacted) continue textmessage;
            return Sticker(event);
          case CuteEventContent.eventType:
            return CuteContent(event);
          case MessageTypes.Audio:
            if (PlatformInfos.isMobile ||
                    PlatformInfos.isMacOS ||
                    PlatformInfos.isWeb
                // Disabled until https://github.com/bleonard252/just_audio_mpv/issues/3
                // is fixed
                //   || PlatformInfos.isLinux
                ) {
              return AudioPlayerWidget(
                event,
                color: textColor,
              );
            }
            return MessageDownloadContent(event, textColor, controller: controller);
          case MessageTypes.Video:
            if (PlatformInfos.isMobile || PlatformInfos.isWeb) {
              return EventVideoPlayer(event);
            }
            return MessageDownloadContent(event, textColor, controller: controller);
          case MessageTypes.File:
            return MessageDownloadContent(event, textColor, controller: controller);

          case MessageTypes.Text:
          case MessageTypes.Notice:
          case MessageTypes.Emote:
            if (AppConfig.renderHtml &&
                !event.redacted &&
                event.isRichMessage) {
              var html = event.formattedText;
              if (event.messageType == MessageTypes.Emote) {
                html = '* $html';
              }
              final bigEmotes = event.onlyEmotes &&
                  event.numberEmotes > 0 &&
                  event.numberEmotes <= 10;
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: HtmlMessage(
                    html: html,
                    defaultTextStyle: TextStyle(
                      color: textColor,
                      fontSize: bigEmotes ? fontSize * 3 : fontSize,
                    ),
                    linkStyle: TextStyle(
                      color: textColor.withAlpha(150),
                      fontSize: bigEmotes ? fontSize * 3 : fontSize,
                      decoration: TextDecoration.underline,
                      decorationColor: textColor.withAlpha(150),
                    ),
                    room: event.room,
                    emoteSize: bigEmotes ? fontSize * 3 : fontSize * 1.5,
                    bottomWidgetSpan: Visibility(
                      visible: false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: endOfBubbleWidget),
                  ),
              );
            }
            // else we fall through to the normal message rendering
            continue textmessage;
          case MessageTypes.BadEncrypted:
          case EventTypes.Encrypted:
            return _ButtonContent(
              textColor: buttonTextColor,
              onPressed: () => _verifyOrRequestKey(context),
              icon: const Icon(Icons.lock_outline),
              label: L10n.of(context)!.encrypted,
            );
          case MessageTypes.Location:
            final geoUri =
                Uri.tryParse(event.content.tryGet<String>('geo_uri')!);
            if (geoUri != null && geoUri.scheme == 'geo') {
              final latlong = geoUri.path
                  .split(';')
                  .first
                  .split(',')
                  .map((s) => double.tryParse(s))
                  .toList();
              if (latlong.length == 2 &&
                  latlong.first != null &&
                  latlong.last != null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MapBubble(
                      latitude: latlong.first!,
                      longitude: latlong.last!,
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      icon: Icon(Icons.location_on_outlined, color: textColor),
                      onPressed:
                          UrlLauncher(context, geoUri.toString()).launchUrl,
                      label: Text(
                        L10n.of(context)!.openInMaps,
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ],
                );
              }
            }
            continue textmessage;
          case MessageTypes.None:
          textmessage:
          default:
            if (event.redacted) {
              return FutureBuilder<User?>(
                future: event.redactedBecause?.fetchSenderUser(),
                builder: (context, snapshot) {
                  return _ButtonContent(
                    label: L10n.of(context)!.redactedAnEvent(
                      snapshot.data?.calcDisplayname() ??
                          event.senderFromMemoryOrFallback.calcDisplayname(),
                    ),
                    icon: const Icon(Icons.delete_outlined),
                    textColor: buttonTextColor,
                    onPressed: () => onInfoTab!(event),
                  );
                },
              );
            }
            
            final bigEmotes = event.onlyEmotes &&
                event.numberEmotes > 0 &&
                event.numberEmotes <= 10;
            return FutureBuilder<String>(
              future: event.calcLocalizedBody(
                MatrixLocals(L10n.of(context)!),
                hideReply: true,
              ),
              builder: (context, snapshot) {
                final text = snapshot.data ??
                  event.calcLocalizedBodyFallback(
                    MatrixLocals(L10n.of(context)!),
                    hideReply: true,
                  );

                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TwakeLinkText(
                    text: text,
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      letterSpacing: MessageContentStyle.letterSpacingMessageContent
                    ),
                    linkStyle: TextStyle(
                      color: textColor.withAlpha(150),
                      fontSize: bigEmotes ? fontSize * 3 : fontSize,
                      decoration: TextDecoration.underline,
                      decorationColor: textColor.withAlpha(150),), 
                      childWidget: Visibility(
                        visible: false,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: endOfBubbleWidget,),
                    onLinkTap: (url) => UrlLauncher(context, url).launchUrl(),
                  ),
                );
              },
            );
        }
      case EventTypes.CallInvite:
        return FutureBuilder<User?>(
          future: event.fetchSenderUser(),
          builder: (context, snapshot) {
            return _ButtonContent(
              label: L10n.of(context)!.startedACall(
                snapshot.data?.calcDisplayname() ??
                    event.senderFromMemoryOrFallback.calcDisplayname(),
              ),
              icon: const Icon(Icons.phone_outlined),
              textColor: buttonTextColor,
              onPressed: () => onInfoTab!(event),
            );
          },
        );
      default:
        return FutureBuilder<User?>(
          future: event.fetchSenderUser(),
          builder: (context, snapshot) {
            return _ButtonContent(
              label: L10n.of(context)!.userSentUnknownEvent(
                snapshot.data?.calcDisplayname() ??
                    event.senderFromMemoryOrFallback.calcDisplayname(),
                event.type,
              ),
              icon: const Icon(Icons.info_outlined),
              textColor: buttonTextColor,
              onPressed: () => onInfoTab!(event),
            );
          },
        );
    }
  }
}

class _ButtonContent extends StatelessWidget {
  final void Function() onPressed;
  final String label;
  final Icon icon;
  final Color? textColor;

  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: MessageContentStyle.backgroundColorButton,
      ),
    );
  }
}

