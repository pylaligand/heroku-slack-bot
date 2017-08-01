// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:logging/logging.dart';

import '../utils/json.dart';

/// Represents a member of a Slack team.
class SlackUser {
  final String id;
  final String name;
  final String title;

  SlackUser(
    this.id,
    this.name,
    this.title,
  );

  @override
  String toString() => '$name [$id] [$title]';

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(dynamic other) => other is SlackUser && other.id == id;
}

/// Client for the Slack API.
class SlackClient {
  final _log = new Logger('SlackClient');
  final String _token;

  SlackClient(this._token);

  /// Returns the profiles of all users in the instance.
  Future<List<SlackUser>> listUsers() async {
    final result = <List<SlackUser>>[];
    final getNextBatch = (String cursor) async {
      final url = _getUrl('users.list', {
        'cursor': cursor,
        'limit': '100',
        'presence': 'false',
      });
      return _getJson(url);
    };
    String cursor = null;
    do {
      final json = await getNextBatch(cursor);
      result.addAll(json['members']
          .where((Map member) => member['id'] != 'USLACKBOT')
          .map((dynamic member) => new SlackUser(
                member['id'],
                member['name'],
                member['profile']['title'],
              )));
      cursor = json['response_metadata']['next_cursor'];
    } while (cursor != null && cursor.isNotEmpty);
    return result;
  }

  /// Returns the given user's profile.
  Future<SlackUser> getUser(String id) async {
    final url = _getUrl('users.info', {
      'user': id,
    });
    final json = await _getJson(url);
    final user = json['user'];
    return new SlackUser(
      user['id'],
      user['name'],
      user['profile']['title'],
    );
  }

  /// Posts a message to a channel.
  Future<bool> sendMessage(String message, String channel) async {
    final content = {
      'channel': channel,
      'as_user': 'true',
      'text': message,
      'unfurl_links': 'false',
      'unfurl_media': 'false'
    };
    final url = _getUrl('chat.postMessage', content);
    final json = await _getJson(url);
    return json != null;
  }

  /// Retrieves a user's timezone, or null if the user could not be found.
  Future<String> getUserTimezone(String id) async {
    final url = _getUrl('users.info', {'user': id});
    final json = await _getJson(url);
    return json != null ? json['user']['tz'] : null;
  }

  // TODO(pylaligand): merge _getUrl and _getJson.

  /// Returns a URL encoding the given parameters.
  Uri _getUrl(String method, [Map content]) {
    final params = content ?? {};
    params['token'] = _token;
    return new Uri.https('slack.com', 'api/$method', params);
  }

  /// Requests JSON data from the given URL.
  /// Returns null if the request failed.
  Future<dynamic> _getJson(Uri url) async {
    final result = await getJson(url.toString(), _log);
    if (!result['ok']) {
      _log.warning('Error in response: ${result['error']}');
      return null;
    }
    return result;
  }
}
