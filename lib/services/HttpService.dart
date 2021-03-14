import 'package:dio/dio.dart';
import 'GetItLocator.dart';
import 'LocalStorageService.dart';
import '../constants.dart';

class HttpService {
  LocalStorageService _localStorageService = locator<LocalStorageService>();
  Future<Dio> getAuthenticatedApiClient() async {
    final Map<String, dynamic> tokens =
    await _localStorageService.getAuthToken();
    BaseOptions options = new BaseOptions(baseUrl: '$baseAddress/');
    final _dio = new Dio(options);
    final dio = new Dio(options);
    _dio.interceptors.clear();
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      String accessToken = tokens['accessToken'];
      if (accessToken != null) {
        options.headers['Authorization'] = "Bearer " + accessToken;
      }
      return options;
    }, onResponse: (Response response) {
      return response;
    }, onError: (DioError error) async {
      if (error.response?.statusCode == 401) {
        RequestOptions options = error.response.request;
        String refreshToken = tokens['refreshToken'];
        _dio.interceptors.requestLock.lock();
        _dio.interceptors.responseLock.lock();
        try {
          final tokenResponse = await dio
              .post('api/token/refresh/', data: {"refresh": refreshToken});
          if (tokenResponse.statusCode == 200) {
            final String newAccessToken = tokenResponse.data['access'];
            await _localStorageService.setAuthToken(
                accessToken: newAccessToken, refreshToken: refreshToken);
            options.headers["Authorization"] = "Bearer " + newAccessToken;
            _dio.interceptors.requestLock.unlock();
            _dio.interceptors.responseLock.unlock();
            String url = options.path.startsWith(options.baseUrl)
                ? options.path
                : '${options.baseUrl}${options.path}';
            try {
              final response = await dio.request(url,
                  data: options.data,
                  queryParameters: options.queryParameters,
                  options: options);
              return response;
            } on DioError catch (e) {
              return e;
            }
          } else {
            return error;
          }
        } on DioError catch (e) {
          return e;
        }
      } else {
        return error;
      }
    }));
    return _dio;
  }

  Future<Dio> getApiClient() async {
    BaseOptions options = new BaseOptions(baseUrl: '$baseAddress/');
    final _dio = new Dio(options);
    return _dio;
  }
}
