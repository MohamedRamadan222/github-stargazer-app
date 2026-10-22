import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stargazer_app/core/utils/app_constants.dart';

import '../error/exceptions.dart';

class DioClient {
  final Dio dio;

  DioClient() : dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl)) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = dotenv.env['GITHUB_TOKEN'];
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/vnd.github.v3+json';
          return handler.next(options);
        },
        onResponse: ((response, handler) {
          final remaining = response.headers.value('x-ratelimit-remaining');
          if(remaining == '0'){
            final resetString = response.headers.value('x-ratelimit-reset');
            if(resetString != null){
              final resetTime = DateTime.fromMillisecondsSinceEpoch(int.parse(resetString) * 1000);
              throw RateLimitException(resetTime: resetTime);
            }
          }
          return handler.next(response);
        })
      ),
    );
  }
}
