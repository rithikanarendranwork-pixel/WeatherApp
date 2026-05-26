import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../errors/failures.dart';

/// Thin, testable wrapper around [http.Client].
/// All callers receive decoded [Map<String, dynamic>]; exceptions bubble up.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String> queryParams = const {},
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint').replace(
      queryParameters: {
        'appid': AppConstants.apiKey,
        'units': AppConstants.units,
        'lang':  AppConstants.lang,
        ...queryParams,
      },
    );

    try {
      final res = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(AppConstants.httpTimeout);

      return _parseResponse(res);
    } on SocketException {
      throw const NetworkException(
          message: 'No internet connection. Check your network and try again.');
    } on HttpException {
      throw const NetworkException(message: 'A network error occurred.');
    } on FormatException {
      throw const ServerException(message: 'Invalid data received from server.');
    }
  }

  Map<String, dynamic> _parseResponse(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return switch (res.statusCode) {
      200      => body,
      400      => throw ServerException(message: body['message'] ?? 'Bad request.', statusCode: 400),
      401      => throw const ServerException(message: 'Invalid API key.', statusCode: 401),
      404      => throw NotFoundException(message: body['message'] ?? 'City not found.'),
      429      => throw const ServerException(message: 'Rate limit reached. Try again later.', statusCode: 429),
      int s when s >= 500 => throw ServerException(message: 'Server error ($s).', statusCode: s),
      _        => throw ServerException(message: 'Unexpected status ${res.statusCode}.'),
    };
  }

  void dispose() => _client.close();
}
