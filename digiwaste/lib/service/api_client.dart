import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiClient._internal(this.dio) {
    dio.options.baseUrl = 'http://10.100.200.209:3000';
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, handler) async {
        final token = await storage.read(key: 'accessToken');
        if (token != null) {
          opts.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(opts);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401) {
          // coba refresh token
          final refresh = await storage.read(key: 'refreshToken');
          if (refresh != null) {
            try {
              final resp = await dio.post('/users/refresh',
                data: {'refreshToken': refresh});
              final at = resp.data['accessToken'];
              final rt = resp.data['refreshToken'];
              await storage.write(key: 'accessToken', value: at);
              await storage.write(key: 'refreshToken', value: rt);

              // ulangi request yang gagal
              final opts = err.requestOptions;
              opts.headers['Authorization'] = 'Bearer $at';
              final clone = await dio.fetch(opts);
              return handler.resolve(clone);
            } catch (_) { /* kalau gagal, jatuh ke logout di bawah */ }
          }
          // kalau tetap gagal, clear storage
          await storage.delete(key: 'accessToken');
          await storage.delete(key: 'refreshToken');
        }
        return handler.next(err);
      },
    ));
  }

  static final ApiClient _instance = ApiClient._internal(Dio());
  factory ApiClient() => _instance;
}