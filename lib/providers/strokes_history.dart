import 'package:deeptex/stroke.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InheritedStrokesHistory extends StatefulWidget {
  final Widget child;

  static InheritedStrokesHistoryData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedStrokesHistoryData>();
  }

  InheritedStrokesHistory({Key key, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InheritedStrokesHistoryState();
}

class _InheritedStrokesHistoryState extends State<InheritedStrokesHistory> {
  List<Stroke> trainingStrokes = [];
  List<Stroke> strokes = [];

  void resetTrainingStrokes() {
    setState(() {
      trainingStrokes = [];
    });
  }

  void resetStrokes() {
    setState(() {
      strokes = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedStrokesHistoryData(
      strokes: strokes,
      trainingStrokes: trainingStrokes,
      child: widget.child,
      resetStrokes: resetStrokes,
      resetTrainingStrokes: resetTrainingStrokes,
    );
  }
}

class InheritedStrokesHistoryData extends InheritedWidget {
  final List<Stroke> strokes;
  final List<Stroke> trainingStrokes;
  final void Function() resetStrokes;
  final void Function() resetTrainingStrokes;

  InheritedStrokesHistoryData(
      {this.strokes,
      Key key,
      Widget child,
      this.resetStrokes,
      this.resetTrainingStrokes,
      this.trainingStrokes})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static InheritedStrokesHistoryData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedStrokesHistoryData>();
}
