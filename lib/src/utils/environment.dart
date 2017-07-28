// Copyright (c) 2017 P.Y. Laligand

import 'dart:io' show Platform;

const USE_DELAYED_RESPONSES = 'USE_DELAYED_RESPONSES';
const SLACK_CLIENT_ID = 'SLACK_CLIENT_ID';
const SLACK_CLIENT_SECRET = 'SLACK_CLIENT_SECRET';
const SLACK_VERIFICATION_TOKEN = 'SLACK_VERIFICATION_TOKEN';
const SLACK_OAUTH_ACCESS_TOKEN = 'SLACK_OAUTH_ACCESS_TOKEN';
const SLACK_BOT_OAUTH_ACCESS_TOKEN = 'SLACK_BOT_OAUTH_ACCESS_TOKEN';

/// Retrieves a configuration value from the environment.
///
/// If [failIfAbsent] is true and the given value couuld not be found, the
/// method will throw an exception.
String getEnv(String name, {bool failIfAbsent: true}) {
  final value = Platform.environment[name];
  if (value == null && failIfAbsent) {
    throw 'Missing configuration value for "$name"';
  }
  return value;
}
