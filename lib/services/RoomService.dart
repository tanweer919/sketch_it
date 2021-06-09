import 'dart:convert';
import 'package:dio/dio.dart';
import 'HttpService.dart';
import 'GetItLocator.dart';
import '../models/PublicRoom.dart';

class RoomService {
  HttpService _httpService = locator<HttpService>();

  Future<Map<String, dynamic>> checkRoom({String roomId}) async {
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

  Future<List<PublicRoom>> fetchAllPublicRooms() async {
    final Dio dio = await _httpService.getApiClient();
    try {
      List<PublicRoom> rooms = [];
      final response = await dio.get('api/room/public/all/');
      if (response.statusCode == 200) {
        final parsedJson = response.data["rooms"].toList();
        for(int i = 0; i < parsedJson.length; i++) {
          rooms.add(PublicRoom.fromJson(parsedJson[i]));
        }
      }
      return rooms;
//      return {
//        'success': false,
//        "message": "Faced some problem while fetching public rooms",
//      };
    } on DioError catch (e) {
      final errorResponse = jsonDecode(e.response.toString()) as Map;
      if (errorResponse.containsKey("status")) {
//        return {
//          "success": false,
//          "message": "Faced some problem while fetching public rooms",
//        };
      throw Exception("Faced some problem while fetching public room");
      }
    }
  }
}
