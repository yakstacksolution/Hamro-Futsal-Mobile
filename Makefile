# Environment switching for Hamro Futsal.
#
# The app reads one compile-time constant, ENV, and loads `env_<ENV>.env` from the
# bundled assets at start-up. Nothing else selects an environment, so every
# target below differs only in `--dart-define=ENV=…`.
#
#   make run-staging          # debug run against staging
#   make run-prod             # debug run against production
#   make apk-staging          # release APK, staging
#   make aab-prod             # Play Store bundle, production
#   make ipa-staging / ipa-prod
#   make env-check            # compare the two env files key by key
#   make secret-scan          # fail if committed files contain key material
#   make prepare-firebase     # copy local/CI Firebase config secrets into place

FLUTTER ?= flutter

# Icons are picked at runtime in several screens, so the release tree-shaker is
# kept off — the same flag CI uses.
BUILD_FLAGS := --release --no-tree-shake-icons

.PHONY: run-staging run-prod apk-staging apk-prod aab-staging aab-prod \
        ipa-staging ipa-prod env-check secret-scan prepare-firebase help

help:
	@grep -E '^#   make' Makefile | sed 's/^#   //'

run-staging: prepare-firebase
	$(FLUTTER) run --dart-define=ENV=staging

run-prod: prepare-firebase
	$(FLUTTER) run --dart-define=ENV=production

apk-staging: prepare-firebase
	$(FLUTTER) build apk $(BUILD_FLAGS) --dart-define=ENV=staging

apk-prod: prepare-firebase
	$(FLUTTER) build apk $(BUILD_FLAGS) --dart-define=ENV=production

aab-staging: prepare-firebase
	$(FLUTTER) build appbundle $(BUILD_FLAGS) --dart-define=ENV=staging

aab-prod: prepare-firebase
	$(FLUTTER) build appbundle $(BUILD_FLAGS) --dart-define=ENV=production

ipa-staging: prepare-firebase
	@dart tool/firebase_config_check.dart ios/Runner/GoogleService-Info.plist
	$(FLUTTER) build ipa $(BUILD_FLAGS) --dart-define=ENV=staging

ipa-prod: prepare-firebase
	@dart tool/firebase_config_check.dart ios/Runner/GoogleService-Info.plist
	$(FLUTTER) build ipa $(BUILD_FLAGS) --dart-define=ENV=production

env-check:
	@dart run tool/env_check.dart

secret-scan:
	@dart run tool/secret_scan.dart

prepare-firebase:
	@dart tool/prepare_firebase_config.dart
