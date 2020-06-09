import 'package:deeptex/providers/strokes_history.dart';
import 'package:deeptex/stroke.dart';
import 'package:deeptex/strokes_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class TrainingCanvas extends StatefulWidget {
  final Widget child;

  final void Function(img.Image image) callback;
  TrainingCanvas({Key key, this.child, @required this.callback})
      : super(key: key);

  @override
  _TrainingCanvasState createState() => _TrainingCanvasState();
}

class _TrainingCanvasState extends State<TrainingCanvas> {
  List<Offset> points = [];

  @override
  Widget build(BuildContext context) {
    List<Stroke> strokes = InheritedStrokesHistory.of(context).trainingStrokes;
    var deviceData = MediaQuery.of(context);

    return Container(
      child: SizedBox(
        width: deviceData.size.width.toDouble(),
        height: deviceData.size.height.toDouble(),
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onPanStart: (DragStartDetails details) {
                print("start draw");
                points.add(details.localPosition);
                setState(() {
                  strokes.add(Stroke(points: points));
                });
              },
              onPanUpdate: (DragUpdateDetails details) {
                print("still drawing");
                points.add(details.delta);
                print("Stroke length: ${strokes.length}");
                setState(() {
                  strokes[strokes.length - 1] = (Stroke(points: points));
                });
              },
              onPanEnd: (DragEndDetails details) {
                print("end draw");
                setState(() {
                  strokes[strokes.length - 1] = (Stroke(points: points));
                });
                points = [];
              },
              child: CustomPaint(
                painter: StrokesPainter(strokes: strokes),
                size: Size.infinite,
              ),
            ),
            // Positioned(
            //   bottom: 0,
            //   child: Container(
            //     // alignment: Alignment.center,
            //     child: Text("Information"),
            //   ),
            // ),
            widget.child,
          ],
        ),
      ),
    );
  }
}
