import 'dart:async';
import '../models/Point.dart';
import '../commons/enums.dart';
class SocketStream {
  StreamController _pointStreamController = StreamController<Map<String, dynamic>>();
  void addPoint(Point point) {
    _pointStreamController.sink.add({"action": DrawAction.Draw, "point": point});
  }

  void clearDrawing() {
    _pointStreamController.sink.add({"action": DrawAction.ClearDraw, "point": null});
  }

  Stream<Map<String, dynamic>> get pointStream => _pointStreamController.stream;

  void cancelPointStream() {
    _pointStreamController.close();
  }
}
