import 'package:fluffychat/widgets/twake_app.dart';
import 'package:fluffychat/widgets/twake_components/twake_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linagora_design_flutter/colors/linagora_sys_colors.dart';

mixin PopupMenuWidgetMixin {
  Widget popupItem(
    BuildContext context,
    String nameAction, {
    IconData? iconAction,
    String? imagePath,
    Color? colorIcon,
    double? iconSize,
    TextStyle? styleName,
    EdgeInsets? padding,
    OnTapIconButtonCallbackAction? onCallbackAction,
    bool isClearCurrentPage = true,
  }) {
    return InkWell(
      onTap: () {
        /// Pop the current page, snackbar, dialog or bottomsheet in the stack
        /// will close the currently open snackbar/dialog/bottomsheet AND the current page
        if (isClearCurrentPage) {
          TwakeApp.router.routerDelegate.pop();
        }
        onCallbackAction!.call();
      },
      child: Padding(
        padding: padding ?? const EdgeInsetsDirectional.all(12),
        child: SizedBox(
          child: Row(
            children: [
              if (iconAction != null)
                Icon(
                  iconAction,
                  size: iconSize ?? 20,
                  color: colorIcon ?? Colors.black,
                ),
              if (imagePath != null)
                SvgPicture.asset(
                  imagePath,
                  width: iconSize ?? 20,
                  height: iconSize ?? 20,
                  fit: BoxFit.fill,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nameAction,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: LinagoraSysColors.material().onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
