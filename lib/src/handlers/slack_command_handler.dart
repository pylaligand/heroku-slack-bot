// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart';

import '../utils/context_params.dart' as param;
import '../utils/slack_format.dart';

export '../utils/context_params.dart';
export '../utils/slack_format.dart';

const _RESPONSE_TIMEOUT = const Duration(seconds: 2, milliseconds: 500);

/// Base class for command handlers.
///
/// Takes care of SSL check queries.
abstract class SlackCommandHandler extends Routeable {
  final _log = new Logger('SlackCommandHandler');

  @override
  createRoutes(Router router) {
    router.get('/', _handleSslCheck);
    router.post('/', _handleRequest);
  }

  shelf.Response _handleSslCheck(shelf.Request request) {
    if (request.url.queryParameters['ssl_check'] == '1') {
      _log.info('SSL check');
      return new shelf.Response.ok('All systems clear!');
    }
    return new shelf.Response.notFound('Not sure what you are looking for...');
  }

  Future<shelf.Response> _handleRequest(shelf.Request request) async {
    final params = request.context;
    if (!params[param.USE_DELAYED_RESPONSES]) {
      return _callHandler(request);
    }
    final completer = new Completer();
    _callHandler(request).then((response) {
      if (!completer.isCompleted) {
        completer.complete(response);
      } else {
        // A reply to the request was already sent, so dial back using the
        // response URL instead.
        _forwardToUrl(params[param.SLACK_RESPONSE_URL], response);
      }
    });
    new Future.delayed(_RESPONSE_TIMEOUT, () {
      if (!completer.isCompleted) {
        // No result was returned, send a canned reply to prevent a timeout.
        completer
            .complete(_createStallingResponse(params[param.STALLING_MESSAGES]));
      }
    });
    return completer.future;
  }

  shelf.Response _createStallingResponse(List<String> messages) {
    _log.info('Stalling');
    return createTextResponse(messages[new Random().nextInt(messages.length)]);
  }

  _forwardToUrl(String url, shelf.Response response) async {
    _log.info('Forwarding answer');
    final postResponse = await http.post(url,
        body: await response.readAsString(),
        headers: {'content-type': 'application/json'});
    if (postResponse.statusCode != 200) {
      _log.warning('Failed to send follow-up message: $postResponse');
    }
  }

  /// Calls the request handler, handling any exception that may occur.
  Future<shelf.Response> _callHandler(shelf.Request request) =>
      handle(request).catchError((Exception e) {
        _log.severe('Encountered handler error: $e');
        return createTextResponse(request.context[param.ERROR_MESSAGE]);
      });

  /// Called to process a command.
  Future<shelf.Response> handle(shelf.Request request);
}
