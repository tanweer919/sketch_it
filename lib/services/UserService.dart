import 'dart:convert';

import 'package:dio/dio.dart';
import 'HttpService.dart';
import 'GetItLocator.dart';
import '../models/User.dart';
import '../services/LocalStorageService.dart';

class UserService {
  HttpService _httpService = locator<HttpService>();

  Future<Map<String, dynamic>> checkUser({String firebaseToken}) async {
    final Dio dio = await _httpService.getApiClient();
    try {
      final response = await dio
          .post('api/user/check/', data: {"firebaseToken": firebaseToken});
      if (response.statusCode == 200) {
        print(response.data);
        final bool registered = response.data["registered"];
        if (registered) {
          return {
            'success': true,
            'registered': true,
            'username': response.data["username"]
          };
        } else {
          return {'success': true, 'registered': false, "username": null};
        }
      }
      return {
        'success': false,
        "message": "Faced some problem during registration"
      };
    } on DioError catch (e) {
      print(e);
      final errorResponse = jsonDecode(e.response.toString()) as Map;
      if (errorResponse.containsKey("status")) {
        return {
          "success": false,
          "message": errorResponse["status"],
        };
      }
    }
  }

  Future<Map<String, dynamic>> checkUsername({String username}) async {
    final Dio dio = await _httpService.getApiClient();
    try {
      final response = await dio
          .post('api/user/username/check/', data: {"username": username});
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
      print(e);
      final errorResponse = jsonDecode(e.response.toString()) as Map;
      if (errorResponse.containsKey("status")) {
        return {
          "available": false,
          "message": errorResponse["status"],
        };
      }
    }
  }

  Future<Map<String, dynamic>> createUser(
      {String username,
      String firebaseToken,
      String email,
      String profilePicUrl}) async {
    final Dio dio = await _httpService.getApiClient();
    try {
      final response = await dio.post('api/user/create/', data: {
        "username": username,
        "firebaseToken": firebaseToken,
        "email": email,
        "profilePicUrl": profilePicUrl
      });
      if (response.statusCode == 201) {
        return {'success': true, 'message': null};
      }
      return {
        'success': false,
        'message': "Faced some problem while registration"
      };
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

  Future<User> fetchCurrentUser() async {
    LocalStorageService _localStorage = locator<LocalStorageService>();
    final String username = await _localStorage.getString('username');
    return username != null ? User(username: username) : null;
  }
}
