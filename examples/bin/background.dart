// Copyright (c) 2017 P.Y. Laligand

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

const DIRECTIVE = 'DIRECTIVE';

class DummyTask extends BackgroundTask {
  @override
  List<String> get environmentVariables => const [DIRECTIVE];

  @override
  execute() async {
    final directive = environment[DIRECTIVE];
    new Logger('DummyTask').info('We must do: $directive');
  }
}

main(List<String> args) async {
  await new DummyTask().run();
}
