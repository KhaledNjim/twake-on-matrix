import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/search/recent_item_widget_style.dart';
import 'package:fluffychat/pages/search/search.dart';
import 'package:fluffychat/presentation/model/search/presentation_search.dart';
import 'package:fluffychat/widgets/avatar/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:fluffychat/presentation/extensions/room_summary_extension.dart';
import 'package:matrix/matrix.dart';

class RecentItemWidget extends StatelessWidget {
  final PresentationSearch presentationSearch;
  final SearchController searchController;
  final void Function()? onTap;

  const RecentItemWidget({
    required this.presentationSearch,
    required this.searchController,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: Padding(
        padding: RecentItemStyle.paddingRecentItem,
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title:  Row(
              crossAxisAlignment: presentationSearch.isContact
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: RecentItemStyle.avatarSize,
                  child: FutureBuilder<ProfileInformation?>(
                    future: searchController.getProfile(context, presentationSearch),
                    builder: (context, snapshot) {
                      return Avatar(
                        mxContent: snapshot.data?.avatarUrl,
                        name: presentationSearch.displayName,
                      );
                    }
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        presentationSearch.displayName ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                        style: Theme.of(context).textTheme.titleMedium?.merge(
                          TextStyle(
                            overflow: TextOverflow.ellipsis,
                            letterSpacing: 0.15,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      _buildInformationWidget(context),
                    ],
                  ),
                ),
              ],
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  Widget _buildInformationWidget(BuildContext context) {
    if (presentationSearch.isContact) {
      return _ContactInformation(presentationSearch: presentationSearch);
    } else {
      if (presentationSearch.directChatMatrixID == null) {
        return _GroupChatInformation(presentationSearch: presentationSearch);
      } else {
        return _DirectChatInformation(presentationSearch: presentationSearch);
      }
    }
  }
}

class _GroupChatInformation extends StatelessWidget {
  final PresentationSearch presentationSearch;
  const _GroupChatInformation({required this.presentationSearch});

  @override
  Widget build(BuildContext context) {
    final actualMembersCount = presentationSearch.roomSummary?.actualMembersCount ?? 0;
    return Text(
      L10n.of(context)!.membersCount(actualMembersCount),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      softWrap: false,
      style: Theme.of(context).textTheme.bodyMedium?.merge(
        TextStyle(
          overflow: TextOverflow.ellipsis,
          letterSpacing: 0.15,
          color: LinagoraRefColors.material().tertiary[30],
        ),
      ),
    );
  }
}


class _DirectChatInformation extends StatelessWidget {
  final PresentationSearch presentationSearch;
  const _DirectChatInformation({required this.presentationSearch});

  @override
  Widget build(BuildContext context) {
    return Text(
      presentationSearch.roomSummary?.mHeroes?.first ?? "",
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      softWrap: false,
      style: Theme.of(context).textTheme.bodyMedium?.merge(
        TextStyle(
          overflow: TextOverflow.ellipsis,
          letterSpacing: 0.15,
          color: LinagoraRefColors.material().tertiary[30],
        ),
      ),
    );
  }
}

class _ContactInformation extends StatelessWidget {
  final PresentationSearch presentationSearch;
  const _ContactInformation({required this.presentationSearch});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (presentationSearch.email != null)
          Text(
          presentationSearch.email ?? "",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: false,
          style: Theme.of(context).textTheme.bodyMedium?.merge(
            TextStyle(
              overflow: TextOverflow.ellipsis,
              letterSpacing: 0.15,
              color: LinagoraRefColors.material().tertiary[30],
            ),
          ),
        ),
        if (presentationSearch.directChatMatrixID != null)
          Text(
          presentationSearch.directChatMatrixID ?? "",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: false,
          style: Theme.of(context).textTheme.bodyMedium?.merge(
            TextStyle(
              overflow: TextOverflow.ellipsis,
              letterSpacing: 0.15,
              color: LinagoraRefColors.material().tertiary[30],
            ),
          ),
        ),
      ],
    );
  }
}
