// Copyright (c) 2017 P.Y. Laligand

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;

import '../utils/context_params.dart' as param;

/// Verifies that requests come from Slack and makes the content of these
/// requests more accessible to handlers.
class SlackVerificationMiddleware {
  static final _log = new Logger('SlackVerificationMiddleware');

  static shelf.Middleware get(String token, bool useDelayedResponses) =>
      (shelf.Handler handler) {
        return (shelf.Request request) async {
          if (request.method != 'POST') {
            // Only perform token verification on POST requests.
            return handler(request);
          }
          final contentType = request.headers['content-type'];
          if (contentType != 'application/x-www-form-urlencoded') {
            _log.warning('Invalid content type: $contentType');
            return new shelf.Response.notFound('Invalid content type');
          }
          final body = await request.readAsString();
          final params = Uri.splitQueryString(Uri.decodeFull(body));
          final requestToken = params['token'];
          if (requestToken != token) {
            _log.warning('Invalid token: $requestToken');
            return new shelf.Response.forbidden('Invalid token');
          }
          final Map<String, String> context = {
            param.USE_DELAYED_RESPONSES: useDelayedResponses
          };
          params.forEach((key, value) => context['slack_param_$key'] = value);
          return handler(request.change(context: context));
        };
      };
}
