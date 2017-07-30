// Copyright (c) 2017 P.Y. Laligand

import 'dart:io' show Platform;
import 'dart:async' show runZoned;

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_route/shelf_route.dart';

import 'handlers/auth_handler.dart';
import 'middleware/slack_client_provider.dart';
import 'middleware/slack_verification_middleware.dart';
import 'middleware/stalling_message_provider.dart';
import 'utils/environment.dart';

import 'server_config.dart';

/// Starts a server with the given config.
runServer(ServerConfig config) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.loggerName}: ${rec.message}');
  });

  final log = new Logger(config.name);
  final portEnv = Platform.environment['PORT'];
  final port = portEnv == null ? 9999 : int.parse(portEnv);

  final useDelayedResponses = getEnv(USE_DELAYED_RESPONSES) == 'true';
  final slackClientId = getEnv(SLACK_CLIENT_ID);
  final slackClientSecret = getEnv(SLACK_CLIENT_SECRET);
  final slackVerificationToken = getEnv(SLACK_VERIFICATION_TOKEN);
  final slackOauthToken = getEnv(SLACK_OAUTH_ACCESS_TOKEN, failIfAbsent: false);
  final slackBotOauthToken =
      getEnv(SLACK_BOT_OAUTH_ACCESS_TOKEN, failIfAbsent: false);

  final environment =
      new Map.fromIterable(config.environmentVariables, value: getEnv);

  final baseMiddleware = const shelf.Pipeline()
      .addMiddleware(
          shelf.logRequests(logger: (String message, _) => log.info(message)))
      .middleware;

  shelf.Pipeline commandPipeline = const shelf.Pipeline()
      .addMiddleware(SlackVerificationMiddleware.get(
          slackVerificationToken, useDelayedResponses))
      .addMiddleware(StallingMessageMiddleware.get(config.stallingMessages))
      .addMiddleware(
          SlackClientProvider.get(slackOauthToken, slackBotOauthToken));
  for (shelf.Middleware middleware in config.loadMiddleware(environment)) {
    commandPipeline = commandPipeline.addMiddleware(middleware);
  }
  final commandMiddleware = commandPipeline.middleware;

  final rootRouter = router()
    ..addAll(
        (Router r) => r
          ..get('/', (_) => new shelf.Response.ok('Hey, I am ${config.name}!'))
          ..addAll(new AuthHandler(slackClientId, slackClientSecret),
              path: '/auth')
          ..addAll((Router r) {
            config
                .loadCommands(environment)
                .forEach((name, handler) => r.addAll(handler, path: '/$name'));
            return r;
          }, path: '/commands', middleware: commandMiddleware),
        middleware: baseMiddleware);

  runZoned(() {
    log.info('Serving on port $port');
    printRoutes(rootRouter, printer: log.info);
    io.serve(rootRouter.handler, '0.0.0.0', port);
  }, onError: (e, stackTrace) => log.severe('Oh noes! $e $stackTrace'));
}
