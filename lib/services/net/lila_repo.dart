import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '/services/env.dart';

typedef RspFactory<T> = T Function(Map<String, dynamic> data);

class LilaResult<T> {
  final int status;
  final Map<String, List<String>>? headers;
  final T? object;
  final dynamic body;
  /*const*/ LilaResult({required this.status, this.headers, this.object, this.body});

  String get message => body?.toString() ?? '';
  bool get ok => status >= 200 && status < 300;

  @override
  String toString() {
    return "status: $status\nheaders: ${headers?.toString()}\nbody: $body\n";
  }
}

class LilaRepo {
  LilaRepo() {
    _dio.options.baseUrl = env.origin;
    _dio.options.connectTimeout = 5000;
    _dio.options.receiveTimeout = 5000;
    _dio.options.headers = {
      'User-Agent': 'lichess-mobile',
      'Accept': 'application/vnd.lichess.v5+json',
      'Origin': 'capacitor://localhost',
      "X-Requested-With": "XMLHttpRequest"
    };
    if (kDebugMode) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (opts, h) => {_logRequest(opts), h.next(opts)},
        onResponse: (rsp, h) => {_logResponse(rsp), h.next(rsp)},
        onError: (err, h) => {_logError(err), h.next(err)},
      ));
    }
  }

  Future<LilaResult<T>> get<T>(String path, {RspFactory<T>? rspFactory}) async {
    return request('GET', path, rspFactory: rspFactory);
  }

  Future<LilaResult<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    RspFactory<T>? rspFactory,
  }) async {
    return request('POST', path, body: body, rspFactory: rspFactory);
  }

  Future<LilaResult<T>> request<T>(
    String method,
    String path, {
    Map<String, dynamic>? urlParams,
    Map<String, dynamic>? headers,
    dynamic body,
    RspFactory<T>? rspFactory,
    bool useForm = true,
  }) async {
    Uri uri = Uri.parse(env.url(path)).replace(queryParameters: urlParams);
    try {
      body = useForm ? FormData.fromMap(body ?? {}) : (body ?? {});

      final rsp = await _dio.requestUri(
        uri,
        options: _options(method, headers),
        data: body,
      );
      return LilaResult(
        status: rsp.statusCode!,
        object: rspFactory?.call(rsp.data),
        body: rspFactory == null ? rsp.data : null,
        headers: rsp.headers.map,
      );
    } on DioError catch (e) {
      return LilaResult(
        status: e.response?.statusCode ?? 500,
        body: e.response?.data ?? e.message,
        headers: e.response?.headers.map,
      );
    } on Error catch (e, s) {
      return LilaResult(status: 400, body: 'LilaRepo.request: ${env.url(path)} $e $s');
    }
  }

  Options _options(String method, Map<String, dynamic>? headers) {
    String? sessionId = env.store.sessionId;
    headers ??= {};
    if (sessionId != null) {
      headers['sessionId'] = sessionId;
    } else {
      headers.remove('sessionId');
    }
    return Options(method: method, headers: headers);
  }

  void _logRequest(RequestOptions opts) {
    // formatted for flutter debug console
    final sb = StringBuffer('Request: ${opts.method} ${opts.uri.path}');
    if (opts.uri.query.isNotEmpty) sb.write('?${opts.uri.query}');
    opts.headers.forEach((k, v) => sb.write('\n  $k: $v'));
    if (opts.data != null) sb.write('\nBody:\n  ${opts.data}');

    debugPrint(sb.toString());
  }

  void _logResponse(Response rsp) {
    // formatted for flutter debug console
    final sb = StringBuffer('Response: ${rsp.statusCode} from ${rsp.requestOptions.path}');
    rsp.headers.forEach((k, l) => {for (var v in l) sb.write('\n  $k: $v')});
    if (rsp.data != null) sb.write('\nBody:\n  ${rsp.data}');

    debugPrint(sb.toString());
  }

  void _logError(DioError err) {
    debugPrint('Error: ${err.message} ${err.stackTrace ?? ''}');
  }

  final _dio = Dio();
}
