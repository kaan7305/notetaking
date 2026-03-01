import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:study_notebook/core/models/result.dart';
import 'package:study_notebook/core/utils/app_logger.dart';

class ApiClient {
  final SupabaseClient _supabaseClient;
  final http.Client _httpClient;
  final Duration _defaultTimeout;
  final Duration _uploadTimeout;

  ApiClient({
    required SupabaseClient supabaseClient,
    http.Client? httpClient,
    Duration? defaultTimeout,
    Duration? uploadTimeout,
  })  : _supabaseClient = supabaseClient,
        _httpClient = httpClient ?? http.Client(),
        _defaultTimeout = defaultTimeout ?? const Duration(seconds: 30),
        _uploadTimeout = uploadTimeout ?? const Duration(seconds: 120);

  String? get _authToken => _supabaseClient.auth.currentSession?.accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<Result<Map<String, dynamic>>> get(
    String url, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await _httpClient
          .get(uri, headers: _headers)
          .timeout(_defaultTimeout);
      return _handleResponse(response);
    } on SocketException catch (e, st) {
      AppLogger.warning('GET network error', tag: 'ApiClient', error: e, stackTrace: st);
      return const Failure('Network error. Please check your connection.');
    } on TimeoutException catch (e, st) {
      AppLogger.warning('GET timeout', tag: 'ApiClient', error: e, stackTrace: st);
      return const Failure('Request timed out. Please try again.');
    } catch (e, st) {
      AppLogger.error('GET unexpected error', tag: 'ApiClient', error: e, stackTrace: st);
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<Result<Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? body,
    bool isUpload = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      final response = await _httpClient
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(isUpload ? _uploadTimeout : _defaultTimeout);
      return _handleResponse(response);
    } on SocketException catch (e, st) {
      AppLogger.warning('POST network error', tag: 'ApiClient', error: e, stackTrace: st);
      return const Failure('Network error. Please check your connection.');
    } on TimeoutException catch (e, st) {
      AppLogger.warning('POST timeout', tag: 'ApiClient', error: e, stackTrace: st);
      return const Failure('Request timed out. Please try again.');
    } catch (e, st) {
      AppLogger.error('POST unexpected error', tag: 'ApiClient', error: e, stackTrace: st);
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<Result<Map<String, dynamic>>> put(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse(url);
      final response = await _httpClient
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_defaultTimeout);
      return _handleResponse(response);
    } on SocketException catch (e, st) {
      AppLogger.warning('PUT network error', tag: 'ApiClient', error: e, stackTrace: st);
      return const Failure('Network error. Please check your connection.');
    } on TimeoutException catch (e, st) {
      AppLogger.warning('PUT timeout', tag: 'ApiClient', error: e, stackTrace: st);
      return const Failure('Request timed out. Please try again.');
    } catch (e, st) {
      AppLogger.error('PUT unexpected error', tag: 'ApiClient', error: e, stackTrace: st);
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<Result<Map<String, dynamic>>> delete(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse(url);
      final response = await _httpClient
          .delete(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_defaultTimeout);
      return _handleResponse(response);
    } on SocketException catch (e, st) {
      AppLogger.warning('DELETE network error', tag: 'ApiClient', error: e, stackTrace: st);
      return const Failure('Network error. Please check your connection.');
    } on TimeoutException catch (e, st) {
      AppLogger.warning('DELETE timeout', tag: 'ApiClient', error: e, stackTrace: st);
      return const Failure('Request timed out. Please try again.');
    } catch (e, st) {
      AppLogger.error('DELETE unexpected error', tag: 'ApiClient', error: e, stackTrace: st);
      return Failure('Unexpected error: ${e.toString()}');
    }
  }

  Future<Result<Map<String, dynamic>>> uploadFile(
    String url,
    String filePath,
    String fieldName, {
    Map<String, String>? fields,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });
      request.files
          .add(await http.MultipartFile.fromPath(fieldName, filePath));
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(_uploadTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException catch (e, st) {
      AppLogger.warning('Upload network error', tag: 'ApiClient', error: e, stackTrace: st);
      return const Failure('Network error. Please check your connection.');
    } on TimeoutException catch (e, st) {
      AppLogger.warning('Upload timeout', tag: 'ApiClient', error: e, stackTrace: st);
      return const Failure('Upload timed out. Please try again.');
    } catch (e, st) {
      AppLogger.error('Upload failed', tag: 'ApiClient', error: e, stackTrace: st);
      return Failure('Upload failed: ${e.toString()}');
    }
  }

  Result<Map<String, dynamic>> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return const Success(<String, dynamic>{});
      }
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return Success(data);
        }
        return Success({'data': data});
      } catch (_) {
        return Success({'raw': response.body});
      }
    } else if (response.statusCode == 401) {
      AppLogger.warning('HTTP 401 Unauthorized', tag: 'ApiClient');
      return const Failure('Authentication failed. Please sign in again.');
    } else if (response.statusCode == 404) {
      AppLogger.warning('HTTP 404 Not Found', tag: 'ApiClient');
      return const Failure('Resource not found.');
    } else {
      String message;
      try {
        final errorBody = jsonDecode(response.body);
        message = errorBody['error'] ??
            errorBody['message'] ??
            'Server error (${response.statusCode})';
      } catch (_) {
        message = 'Server error (${response.statusCode})';
      }
      AppLogger.error(
        'HTTP ${response.statusCode}: $message',
        tag: 'ApiClient',
      );
      return Failure(message);
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
