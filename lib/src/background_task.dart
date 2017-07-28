// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:logging/logging.dart';

import 'utils/environment.dart';
import 'utils/slack_client.dart';

/// A task executed in the background.
///
/// Can be used for periodic or long-running tasks.
abstract class BackgroundTask {
  /// Returns a client to interact with the Slack API.
  SlackClient get slackClient =>
      new SlackClient(getEnv(SLACK_OAUTH_ACCESS_TOKEN));

  /// Returns a client to interact with the Slack API as a bot.
  SlackClient get slackBotClient =>
      new SlackClient(getEnv(SLACK_BOT_OAUTH_ACCESS_TOKEN));

  // TODO(pylaligand): support for extracting env variables.
  // This would allow us to hide the environment manipulation API.

  /// Runs the task.
  run() async {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print(
          '${rec.level.name}: ${rec.time}: ${rec.loggerName}: ${rec.message}');
    });
    execute();
  }

  /// The content of the task.
  Future<Null> execute();
}
