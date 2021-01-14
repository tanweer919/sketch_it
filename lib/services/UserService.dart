import 'dart:convert';

import 'package:dio/dio.dart';
import 'HttpService.dart';
import 'GetItLocator.dart';

class UserService {
  HttpService _httpService = locator<HttpService>();

  Future<Map<String, dynamic>> checkUsername({String username}) async {
    final Dio dio = await _httpService.getApiClient();
    try {
      final response =
          await dio.post('api/user/check/', data: {"username": username});
      if (response.statusCode == 200) {
        final bool available = response.data["available"];
        if (available) {
          return {'available': true, 'message': null};
        } else {
          return {'available': false, 'message': "Username is not available"};
        }
      }
      return {
        'available': false,
        "message": "Faced some problem while joining room"
      };
    } on DioError catch (e) {
      final errorResponse = jsonDecode(e.response.toString()) as Map;
      if (errorResponse.containsKey("status")) {
        return {
          "available": false,
          "message": errorResponse["status"],
        };
      }
    }
  }

  Future<Map<String, dynamic>> createUser({String username}) async {
    final Dio dio = await _httpService.getApiClient();
    try {
      final response =
      await dio.post('api/user/create/', data: {"username": username});
      if (response.statusCode == 201) {
        return {'success': true, 'message': null};
      }
      return {'success': false, 'message': "Faced some problem while registering the user"};

    } on DioError catch (e) {
      final errorResponse = jsonDecode(e.response.toString()) as Map;
      if (errorResponse.containsKey("status")) {
        return {
          "success": false,
          "message": errorResponse["status"],
        };
      }
    }
  }
}
