// Copyright (c) 2017 P.Y. Laligand

import 'package:shelf/shelf.dart' as shelf;

import '../utils/context_params.dart' as param;
import '../utils/slack_client.dart';

/// Injects clients to query the Slack API.
class SlackClientProvider {
  static shelf.Middleware get(String oauthToken, String botOauthToken) =>
      (shelf.Handler handler) =>
          (shelf.Request request) => handler(request.change(context: {
                param.SLACK_CLIENT: new SlackClient(oauthToken),
                param.SLACK_BOT_CLIENT: new SlackClient(botOauthToken),
              }));
}
