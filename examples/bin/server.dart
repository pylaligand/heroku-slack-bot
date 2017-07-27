// Copyright (c) 2017 P.Y. Laligand

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import '../lib/dummy_handler.dart';

class Config extends ServerConfig {
  @override
  String get name => 'ThisIsYourTestServer';

  @override
  Map<String, SlackCommandHandler> get commands => {
        'dummy': new DummyHandler(),
      };

  @override
  List<String> get stallingMessages =>
      ['Please wait a second', 'Don\'t be so impatient'];
}

main() async {
  await runServer(new Config());
}
