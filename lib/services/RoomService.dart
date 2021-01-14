import 'dart:convert';

import 'package:dio/dio.dart';
import 'HttpService.dart';
import 'GetItLocator.dart';

class AddressService {
  HttpService _httpService = locator<HttpService>();

  Future<Map<String, dynamic>> checkRoom({int roomId}) async {
    final Dio dio = await _httpService.getApiClient();
    try {
      final response =
          await dio.post('api/room/check/', data: {"roomId": roomId});
      if (response.statusCode == 200) {
        return {'success': true, 'message': null};
      }
      return {
        'success': false,
        "message": "Faced some problem while joining room"
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
}
