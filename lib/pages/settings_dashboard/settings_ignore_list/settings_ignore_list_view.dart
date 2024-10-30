import 'package:fluffychat/utils/dialog/twake_dialog.dart';
import 'package:fluffychat/widgets/app_bars/twake_app_bar.dart';
import 'package:fluffychat/widgets/context_menu_builder_ios_paste_without_permission.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';

import 'package:matrix/matrix.dart';

import 'package:fluffychat/widgets/avatar/avatar.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'settings_ignore_list.dart';

class SettingsIgnoreListView extends StatelessWidget {
  final SettingsIgnoreListController controller;

  const SettingsIgnoreListView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    return Scaffold(
      backgroundColor: LinagoraSysColors.material().onPrimary,
      appBar: TwakeAppBar(
        title: L10n.of(context)!.ignoredUsers,
        context: context,
      ),
      body: MaxWidthBody(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller.controller,
                    contextMenuBuilder: mobileTwakeContextMenuBuilder,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => controller.ignoreUser(context),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'bad_guy:domain.abc',
                      prefixText: '@',
                      labelText: L10n.of(context)!.ignoreUsername,
                      suffixIcon: IconButton(
                        tooltip: L10n.of(context)!.ignore,
                        icon: const Icon(Icons.done_outlined),
                        onPressed: () => controller.ignoreUser(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    L10n.of(context)!.ignoreListDescription,
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<Object>(
                stream: client.onAccountData.stream
                    .where((a) => a.type == 'm.ignored_user_list'),
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: client.ignoredUsers.length,
                    itemBuilder: (c, i) => FutureBuilder<Profile>(
                      future:
                          client.getProfileFromUserId(client.ignoredUsers[i]),
                      builder: (c, s) => ListTile(
                        leading: Avatar(
                          mxContent: s.data?.avatarUrl ?? Uri.parse(''),
                          name: s.data?.displayName ?? client.ignoredUsers[i],
                        ),
                        title: Text(
                          s.data?.displayName ?? client.ignoredUsers[i],
                        ),
                        trailing: IconButton(
                          tooltip: L10n.of(context)!.delete,
                          icon: const Icon(Icons.delete_forever_outlined),
                          onPressed: () =>
                              TwakeDialog.showFutureLoadingDialogFullScreen(
                            future: () =>
                                client.unignoreUser(client.ignoredUsers[i]),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
