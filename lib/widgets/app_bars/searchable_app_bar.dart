import 'package:fluffychat/pages/chat_list/chat_list_header_style.dart';
import 'package:fluffychat/pages/dialer/pip/dismiss_keyboard.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/twake_components/twake_icon_button.dart';
import 'package:fluffychat/widgets/app_bars/searchable_app_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linagora_design_flutter/colors/linagora_ref_colors.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class SearchableAppBar extends StatelessWidget {
  final ValueNotifier<bool> searchModeNotifier;
  final FocusNode focusNode;
  final String title;
  final String? hintText;
  final TextEditingController textEditingController;
  final Function() toggleSearchMode;
  final bool isFullScreen;

  const SearchableAppBar({
    super.key,
    required this.searchModeNotifier,
    required this.title,
    this.hintText,
    required this.focusNode,
    required this.textEditingController,
    required this.toggleSearchMode,
    this.isFullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: !isFullScreen
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  SearchableAppBarStyle.appBarBorderRadius,
                ),
              ),
            )
          : null,
      automaticallyImplyLeading: false,
      toolbarHeight: SearchableAppBarStyle.appBarHeight(
        isFullScreen: isFullScreen,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black.withOpacity(0.15)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 1),
                blurRadius: 80,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isFullScreen == true) ...[
                  TwakeIconButton(
                    icon: Icons.arrow_back,
                    onTap: () {
                      if (!PlatformInfos.isMobile) {
                        Navigator.of(context).maybePop();
                      } else {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/rooms');
                        }
                      }
                    },
                    tooltip: L10n.of(context)!.back,
                    paddingAll: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                ] else ...[
                  const SizedBox(width: 56.0),
                ],
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: searchModeNotifier,
                    builder: (context, searchModeNotifier, child) {
                      if (searchModeNotifier) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(top: 10.0),
                          child: _textFieldBuilder(context),
                        );
                      }
                      return Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      );
                    },
                  ),
                ),
                if (isFullScreen) ...[
                  ValueListenableBuilder(
                    valueListenable: searchModeNotifier,
                    builder: (context, searchModeNotifier, child) {
                      if (searchModeNotifier) {
                        return TwakeIconButton(
                          onTap: toggleSearchMode,
                          tooltip: L10n.of(context)!.close,
                          icon: Icons.close,
                          paddingAll: 10.0,
                          margin: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 6.0,
                          ),
                        );
                      }
                      return TwakeIconButton(
                        icon: Icons.search,
                        onTap: toggleSearchMode,
                        tooltip: L10n.of(context)!.search,
                        paddingAll: 10.0,
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                      );
                    },
                  ),
                ] else ...[
                  TwakeIconButton(
                    onTap: () => context.pop(),
                    tooltip: L10n.of(context)!.close,
                    icon: Icons.close,
                    paddingAll: 10.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 6.0,
                    ),
                  ),
                ],
              ],
            ),
            if (!isFullScreen)
              Padding(
                padding: SearchableAppBarStyle.textFieldWebPadding,
                child: _textFieldBuilder(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _textFieldBuilder(BuildContext context) {
    return TextField(
      onTapOutside: (event) {
        dismissKeyboard();
      },
      focusNode: focusNode,
      autofocus: true,
      maxLines: SearchableAppBarStyle.textFieldMaxLines,
      buildCounter: (
        BuildContext context, {
        required int currentLength,
        required int? maxLength,
        required bool isFocused,
      }) =>
          const SizedBox.shrink(),
      maxLength: SearchableAppBarStyle.textFieldMaxLength,
      cursorHeight: 26,
      scrollPadding: const EdgeInsets.all(0),
      controller: textEditingController,
      decoration: InputDecoration(
        contentPadding: SearchableAppBarStyle.textFieldContentPadding,
        isCollapsed: true,
        filled: !isFullScreen,
        hintText: hintText,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(
            ChatListHeaderStyle.searchRadiusBorder,
          ),
        ),
        prefixIcon: !isFullScreen
            ? Icon(
                Icons.search_outlined,
                color: Theme.of(context).colorScheme.onBackground,
              )
            : null,
        suffixIcon: const SizedBox.shrink(),
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: LinagoraRefColors.material().neutral[60],
            ),
      ),
    );
  }
}
