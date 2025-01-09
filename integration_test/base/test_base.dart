import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fluffychat/main.dart' as app;

class TestBase {
  void runPatrolTest({
    required String description,
    required Function(PatrolIntegrationTester $) test,
  }) {
    patrolTest(description,
        config: const PatrolTesterConfig(
          printLogs: true,
          visibleTimeout: Duration(minutes: 1),
        ),
        nativeAutomatorConfig: const NativeAutomatorConfig(
          connectionTimeout: Duration(minutes: 1, seconds: 10),
          findTimeout: Duration(seconds: 60),
          keyboardBehavior: KeyboardBehavior.alternative,
        ),
        framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
        ($) async {
      await initTwakeChat();
      final originalOnError = FlutterError.onError!;
      FlutterError.onError = (FlutterErrorDetails details) {
        originalOnError(details);
      };
      await test($);
    });
  }

  Future<void> initTwakeChat() async {
    app.main();
  }
}
