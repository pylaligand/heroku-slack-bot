// Copyright (c) 2017 P.Y. Laligand

import 'handlers/slack_command_handler.dart';

/// Configuration of the bot server.
abstract class ServerConfig {
  /// The name of the server.
  String get name;

  /// The supported commands indexed by command name.
  ///
  /// The name will be used in the URI path to access the command.
  Map<String, SlackCommandHandler> get commands;

  /// The temporary message displayed to the user while processing long queries.
  List<String> get stallingMessages => ['Processing request...'];
}
