import 'package:fluffychat/di/global/get_it_initializer.dart';
import 'package:fluffychat/pages/chat_list/chat_list.dart';
import 'package:fluffychat/pages/chat_list/chat_list_body_view.dart';
import 'package:fluffychat/pages/chat_list/chat_list_bottom_navigator.dart';
import 'package:fluffychat/pages/chat_list/chat_list_bottom_navigator_style.dart';
import 'package:fluffychat/pages/chat_list/chat_list_header.dart';
import 'package:fluffychat/pages/chat_list/chat_list_view_style.dart';
import 'package:fluffychat/utils/responsive/responsive_utils.dart';
import 'package:fluffychat/widgets/twake_components/twake_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_shortcuts/keyboard_shortcuts.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ChatListView extends StatelessWidget {
  final ChatListController controller;
  final Widget? bottomNavigationBar;
  final VoidCallback? onOpenSearchPage;
  final ChatListBottomNavigatorBarIcon onTapBottomNavigation;

  final responsiveUtils = getIt.get<ResponsiveUtils>();

  ChatListView({
    Key? key,
    required this.controller,
    this.bottomNavigationBar,
    this.onOpenSearchPage,
    required this.onTapBottomNavigation,
  }) : super(key: key);

  static const ValueKey bottomNavigationKey = ValueKey('BottomNavigation');

  static const ValueKey primaryNavigationKey =
      ValueKey('AdaptiveScaffoldPrimaryNavigation');

  static const ValueKey contacts = ValueKey('Contacts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: ChatListViewStyle.preferredSizeAppBar(context),
        child: ChatListHeader(
          selectModeNotifier: controller.selectModeNotifier,
          openSelectMode: controller.toggleSelectMode,
          onOpenSearchPage: onOpenSearchPage,
          conversationSelectionNotifier:
              controller.conversationSelectionNotifier,
          onClearSelection: controller.onClickClearSelection,
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: controller.conversationSelectionNotifier,
        builder: (context, conversationSelection, __) {
          if (conversationSelection.isNotEmpty) {
            return ChatListBottomNavigator(
              bottomNavigationActionsWidget:
                  controller.bottomNavigationActionsWidget(
                paddingIcon: ChatListBottomNavigatorStyle.paddingIcon,
                iconSize: ChatListBottomNavigatorStyle.iconSize,
                width: ChatListBottomNavigatorStyle.width,
              ),
            );
          } else {
            return bottomNavigationBar ?? const SizedBox();
          }
        },
      ),
      body: ChatListBodyView(controller),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: controller.selectModeNotifier,
        builder: (context, _, __) {
          if (controller.isSelectMode) return const SizedBox();
          return KeyBoardShortcuts(
            keysToPress: {
              LogicalKeyboardKey.controlLeft,
              LogicalKeyboardKey.keyN,
            },
            onKeysPressed: () => controller.goToNewPrivateChatMobile(),
            helpLabel: L10n.of(context)!.newChat,
            child: responsiveUtils.isTwoColumnLayout(context)
                ? MenuAnchor(
                    menuChildren: [
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.chat),
                        child: Text(L10n.of(context)!.newDirectMessage),
                        onPressed: () =>
                            controller.goToNewPrivateChatTwoColumnMode(),
                      ),
                      MenuItemButton(
                        leadingIcon: const Icon(Icons.group),
                        onPressed: () =>
                            controller.goToNewGroupChatTwoColumnMode(),
                        child: Text(L10n.of(context)!.newChat),
                      ),
                    ],
                    style: const MenuStyle(
                      alignment: Alignment.topLeft,
                    ),
                    builder: (context, menuController, child) {
                      return TwakeFloatingActionButton(
                        icon: Icons.mode_edit_outline_outlined,
                        size: ChatListViewStyle.editIconSize,
                        onTap: () => menuController.open(),
                      );
                    },
                  )
                : TwakeFloatingActionButton(
                    icon: Icons.mode_edit_outline_outlined,
                    size: ChatListViewStyle.editIconSize,
                    onTap: controller.goToNewPrivateChatMobile,
                  ),
          );
        },
      ),
    );
  }
}
