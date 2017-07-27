// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:heroku_slack_bot/heroku_slack_bot.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;

/// Does not do anything useful, really.
class DummyHandler extends SlackCommandHandler {
  final Logger _log = new Logger('DummyHandler');

  final String _password;

  DummyHandler(this._password);

  @override
  Future<shelf.Response> handle(shelf.Request request) async {
    final params = request.context;
    final String userName = params[SLACK_USERNAME];
    _log.info('Request from $userName');
    return createTextResponse(
      'Hello $userName, the password is "$_password!"',
      private: true,
    );
  }
}
