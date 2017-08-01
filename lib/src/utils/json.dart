// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';
import 'dart:convert';
import 'dart:math' show max;

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

/// Thrown by [getJson].
class JsonException implements Exception {
  final String _message;
  final Exception _exception;
  final int code;

  JsonException({String message, Exception exception, this.code})
      : _message = message,
        _exception = exception;

  @override
  String toString() {
    String result = 'JsonException';
    if (code != null) {
      result += ': $code';
    }
    if (_message != null) {
      result += ': $_message';
    }
    if (_exception != null) {
      result += ': $_exception';
    }
    return result;
  }
}

/// Requests JSON data from the given URL.
/// Throws a [JsonException] if the request failed.
Future<dynamic> getJson(dynamic url, Logger log,
    {Map<String, String> headers}) async {
  final response = await http.get(url, headers: headers);
  if (response.statusCode == 429) {
    final int retryAfter =
        max(1, int.parse(response.headers['retry-after'], onError: (_) => 5));
    log.warning('Rate limited, retrying in $retryAfter second(s)');
    await new Future.delayed(new Duration(seconds: retryAfter));
    return getJson(url, log, headers: headers);
  }
  final body = response.body;
  if (response.statusCode != 200) {
    throw new JsonException(
        message: 'Request failed [${response.statusCode}]: $body',
        code: response.statusCode);
  }
  if (body == null) {
    log.warning('Empty response');
    throw new JsonException(message: 'Empty response');
  }
  try {
    return JSON.decode(body);
  } on FormatException catch (e) {
    log.warning('Failed to decode content: $e');
    throw new JsonException(message: 'Decoding failed', exception: e);
  }
}
