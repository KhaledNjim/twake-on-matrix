import 'package:fluffychat/pages/homeserver_picker/homeserver_picker_view.dart';
import 'package:patrol/patrol.dart';

import '../base/core_robot.dart';

class LoginRobot extends CoreRobot {
  LoginRobot(super.$);

  Future<void> grantNotificationPermission(
    NativeAutomator nativeAutomator,
  ) async {
    if (await nativeAutomator.isPermissionDialogVisible(
      timeout: const Duration(seconds: 15),
    )) {
      await nativeAutomator.grantPermissionWhenInUse();
    }
  }

  Future<void> tapOnUseYourCompanyServer() async {
    await $('Use your company server').tap();
  }

  Future<void> enterServerUrl(String serverUrl) async {
    await $.enterText($(HomeserverTextField), serverUrl);
  }

  Future<void> confirmServerUrl() async {
    await $.tap($('Continue'));
  }

  Future<void> enterUsernameSsoLogin(String username) async {
    await $.native.enterText(
      Selector(resourceId: 'login'),
      text: username,
    );
  }

  Future<void> enterPasswordSsoLogin(String password) async {
    await $.native.enterText(
      Selector(resourceId: 'password'),
      text: password,
    );
  }

  Future<void> pressSignInSsoLogin() async {
    await $.native.tap(
      Selector(
        text: 'Sign in',
        instance: 1,
      ),
    );
  }
}
