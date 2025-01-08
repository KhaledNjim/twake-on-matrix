#!/bin/bash

dart pub global activate patrol_cli
flutter build apk --config-only


patrol build android \
  --target integration_test/tests/login/login_test.dart \
  -v \
  --dart-define=USERNAME="$USERNAME" \
  --dart-define=SERVER_URL="$SERVER_URL" \
  --dart-define=PASSWORD="$PASSWORD"

# 3. Run tests on Firebase Test Lab
gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --device model=MediumPhone.arm,version=34 \
  --timeout 5m \
  --use-orchestrator \
  --environment-variables clearPackageData=true