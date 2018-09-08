// Copyright (c) 2017 P.Y. Laligand

import 'package:shelf/shelf.dart' as shelf;

import '../utils/context_params.dart' as param;

/// Injects stalling messages into a query.
class MessageMiddleware {
  static shelf.Middleware get(
          List<String> stallingMessages, String errorMessage) =>
      (shelf.Handler handler) =>
          (shelf.Request request) => handler(request.change(context: {
                param.STALLING_MESSAGES: stallingMessages,
                param.ERROR_MESSAGE: errorMessage,
              }));
}
