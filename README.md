# A Dart library to run Slack bots on Heroku

# Initial setup

1. Create a Slack app.
  - Note the client id, client secret, and verification token assigned to your
    app.
2. Follow the steps at https://github.com/igrigorik/heroku-buildpack-dart to
   configure a new Heroku instance for a Dart app.
  - Instead of copying the example you will want to create a new Git project and
    build a skeletal server which will be needed to set up Slack.
  - Add a web/ directory to your repository (with an empty file) to ensure the
    build succeeds.
  - Add the Slack client id, client secret, and verification token to the
    instance's configuration.
3. Deploy a first version of the server to Heroku.
4. Configure the Slack app.
  - Add the desired slash commands and bot;
  - Install the app for your team (this is the step that requires a working
    server).
5. Add the OAuth tokens Slack generated for your app to your Heroku instance's
   configuration.


# Development workflow

1. Make a change, get it tested and reviewed, and make sure your master branch
   is up-to-date.
2. `git push heroku master`


# Building the bot

## Base server

The `Server` class and its configuration companion `ServerConfig` are used to
start a server supporting authentication and slash commands. See
`examples/bin/server.dart` for an example.

## Background tasks

`BackgroundTask` supports, well, background tasks. It can be used to support
periodic and long-running tasks. See `examples/bin/background.dart` for an
example.

Note that for a task to be run by Heroku you need to define it in your
`Procfile`:
```
my_task: ./dart-sdk/bin/dart bin/background.dart
```
and after re-deploying the bot you can then run the task manually with:
```
$ heroku run my_task
```
or use the Heroku scheduler to run it periodically.


# Running the bot

## Environment

A bot needs a few environment variables to function:
- `USE_DELAYED_RESPONSES`: should only be used in production where it allows
  slash commands to take more than 3 seconds to produce a result;
- `SLACK_CLIENT_ID`: the client id assigned to your Slack app;
- `SLACK_CLIENT_SECRET`: the client secret assigned to your Slack app;
- `SLACK_VERIFICATION_TOKEN`: the verification token assigned to your Slack app;
- `SLACK_OAUTH_TOKEN`: the oauth token assigned to your Slack app after it is
  installed for your team;
- (optional) `SLACK_BOT_OAUTH_TOKEN`: the oauth token assigned to your Slack
  app's bot user after the app is installed for your team.

## Local testing

The following works for both servers and background tasks:
```sh
export FOO=foo BAR=bar dart bin/something.dart
```
where `FOO`, `BAR`, etc... are the environment variables the bot needs.
