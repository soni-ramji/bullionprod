import 'package:bullionprod/environment.dart';
import 'package:dio/dio.dart';


class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15), // Enforce connection timeout
      receiveTimeout: const Duration(seconds: 30), // increased default receive timeout
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Execute GET with optional receive timeout and simple retry/backoff.
  Future<Response<T>> getWithRetry<T>(
    String path, {
    Duration? receiveTimeout,
    int retries = 2,
    Map<String, dynamic>? queryParameters,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        final options = Options(receiveTimeout: receiveTimeout ?? _dio.options.receiveTimeout);
        return await _dio.get<T>(path, options: options, queryParameters: queryParameters);
      } on DioException catch (e) {
        attempt++;
        if (attempt > retries) rethrow;
        // If server returned a client error (4xx), don't retry
        final status = e.response?.statusCode ?? 0;
        if (status >= 400 && status < 500) rethrow;

        // Otherwise assume transient network issue — exponential backoff and retry
        await Future.delayed(Duration(milliseconds: 500 * (1 << (attempt - 1))));
        continue;
      }
    }
  }

  /// Execute POST with optional receive timeout and simple retry/backoff.
  Future<Response<T>> postWithRetry<T>(
    String path, {
    Object? data,
    Duration? receiveTimeout,
    int retries = 2,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        final options = Options(receiveTimeout: receiveTimeout ?? _dio.options.receiveTimeout);
        return await _dio.post<T>(path, data: data, options: options);
      } on DioException catch (e) {
        attempt++;
        if (attempt > retries) rethrow;
        // If server returned a client error (4xx), don't retry
        final status = e.response?.statusCode ?? 0;
        if (status >= 400 && status < 500) rethrow;

        // Otherwise assume transient network issue — exponential backoff and retry
        await Future.delayed(Duration(milliseconds: 500 * (1 << (attempt - 1))));
        continue;
      }
    }
  }

  ApiClient() {
    // Register interceptors in the order you want them to execute
    //_dio.interceptors.addAll([_authInterceptor(), _loggingInterceptor()]);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Example: Add an Authorization Header automatically to requests
          //options.headers['Authorization'] = 'Bearer YOUR_TOKEN_HERE';
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Global error management strategy
          print("API Error occurred: ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }

  // Getter to expose the client safely
  Dio get dio => _dio;

  /// 1. Auth Interceptor: Automatically injects JWT Bearer tokens into headers
  // Interceptor _authInterceptor() {
  //   return InterceptorsWrapper(
  //     onRequest: (options, handler) async {
  //       // Securely fetch your saved token (e.g., from flutter_secure_storage)
  //       const String? token = 'your_stored_jwt_token';
  //
  //       if (token != null) {
  //         options.headers['Authorization'] = 'Bearer $token';
  //       }
  //
  //       // Pass the request to the next interceptor/server
  //       return handler.next(options);
  //     },
  //     onError: (DioException e, handler) async {
  //       // 2. Token Refresh: Handle expired tokens globally (HTTP 401 Unauthorized)
  //       if (e.response?.statusCode == 401) {
  //         try {
  //           final newToken = await _refreshAccessToken();
  //
  //           // Retry the original failed request with the new token
  //           e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
  //
  //           // Create a brand new clean request clone to send back
  //           final clonedResponse = await _dio.fetch(e.requestOptions);
  //           return handler.resolve(clonedResponse);
  //         } catch (refreshError) {
  //           // Refresh failed (e.g., refresh token expired) -> Force log out user
  //           return handler.next(e);
  //         }
  //       }
  //       return handler.next(e);
  //     },
  //   );
  // }

  /// 3. Logging Interceptor: Prints clean console metrics for debugging
  // Interceptor _loggingInterceptor() {
  //   return LogInterceptor(
  //     requestHeader: false,
  //     responseHeader: false,
  //     requestBody: true,
  //     responseBody: true,
  //     error: true,
  //   );
  // }

  // Mock token refresh helper function
  Future<String> _refreshAccessToken() async {
    // Perform fresh API call to fetch a new token pair using refresh tokens
    await Future.delayed(const Duration(milliseconds: 500));
    return 'new_refreshed_jwt_token';
  }
}
