import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:latex_symbol/stroke.dart';

class StrokesPainter extends CustomPainter {
  final List<Stroke> strokes;
  StrokesPainter({this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (Stroke stroke in strokes) {
      Paint paint = new Paint();
      paint.isAntiAlias = true;
      paint.strokeCap = StrokeCap.round;
      paint.strokeJoin = StrokeJoin.round;
      paint.strokeWidth = 10;
      Offset startingPoint = stroke.points[0];
      for (int i = 0; i < stroke.points.length - 1; i++) {
        Offset nextPoint = startingPoint + stroke.points[i + 1];
        print("drawLine from $startingPoint to $nextPoint");
        canvas.drawLine(startingPoint, nextPoint, paint);
        startingPoint = nextPoint;
      }
    }
  }

  @override
  bool shouldRepaint(StrokesPainter oldDelegate) {
    if (strokes.length == 0) {
      return false;
    }
    bool repaint = listEquals(strokes[strokes.length - 1].points,
        oldDelegate.strokes[strokes.length - 1].points);
    if (repaint) print("Repaiting Custom Painter");
    return repaint;
  }
}
