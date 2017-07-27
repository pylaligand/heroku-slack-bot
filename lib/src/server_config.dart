// Copyright (c) 2017 P.Y. Laligand

import 'handlers/slack_command_handler.dart';

/// Configuration of the bot server.
abstract class ServerConfig {
  /// The name of the server.
  String get name;

  /// The names of environment variables used to build the server.
  ///
  /// This will be used when constructing commands and such.
  List<String> get environmentVariables => [];

  /// Returns the supported commands indexed by command name.
  ///
  /// The name will be used in the URI path to access the command as
  /// `/commands/{name}`.
  Map<String, SlackCommandHandler> loadCommands(
      Map<String, String> environment);

  /// The temporary message displayed to the user while processing long queries.
  List<String> get stallingMessages => ['Processing request...'];
}
