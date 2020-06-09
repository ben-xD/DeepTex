import 'dart:math';

import 'package:deeptex/providers/strokes_history.dart';
import 'package:deeptex/strokes_painter.dart';
import 'package:deeptex/ui/screens/draw/drawing_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class TrainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  String nickname;
  int trainingCounter;

  final snackBar = SnackBar(
    duration: Duration(milliseconds: 2000),
    behavior: SnackBarBehavior.floating,
    content: Text('Set your nickname to get on the leaderboards.'),
    action: SnackBarAction(
      label: 'Set nickname',
      onPressed: () {
        print("Renaming");
      },
    ),
  );

  @override
  void initState() {
    // Make request from backend for
    asyncInitState();
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    var deviceData = MediaQuery.of(context);

    Future<img.Image> getDrawnImage() async {
      ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas canvas = Canvas(recorder);
      canvas.drawColor(Colors.white, BlendMode.src);
      StrokesPainter painter = StrokesPainter(
          // refactor long function below into a variable?
          strokes: InheritedStrokesHistory.of(context).strokes);
      painter.paint(canvas, deviceData.size);
      ui.Image screenImage = await (recorder.endRecording().toImage(
          deviceData.size.width.floor(), deviceData.size.height.floor()));

      ByteData imgBytes =
          await screenImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      return img.Image.fromBytes(deviceData.size.width.floor(),
          deviceData.size.height.floor(), imgBytes.buffer.asUint8List());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Train the brain."),
      ),
      body: TrainingCanvas(
          callback: (image) {
            print("Captured image, send it off to the interwebs");
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nick:"),
                      Text(
                        "@$nickname",
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )),
                  Expanded(
                    child: Text(
                      "LaTex character goes here",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Training"),
                      Text(
                        "#$trainingCounter",
                        textAlign: TextAlign.right,
                      ),
                    ],
                  )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ButtonTheme(
                          height: 60,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            color: Colors.red,
                            onPressed: () {
                              InheritedStrokesHistory.of(context)
                                  .resetTrainingStrokes();
                            },
                            child: Column(
                              children: [
                                Icon(Icons.delete,
                                    color: Colors.white, size: 32),
                                Text("Cancel",
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ButtonTheme(
                          height: 80,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            color: Colors.green,
                            onPressed: () async {
                              // how to get drawing from canvas?
                              var image = await getDrawnImage();
                              print(image);
                            },
                            child: Column(
                              children: [
                                Icon(Icons.check,
                                    color: Colors.white, size: 32),
                                Text("Looks good!",
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }

  void asyncInitState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    nickname = prefs.getString("nickname");
    trainingCounter = prefs.getInt("trainingCounter");
    if (nickname == null) {
      Scaffold.of(context).showSnackBar(snackBar);
      nickname = createRandomNick();
      prefs.setString("nickname", nickname);
    }
    if (trainingCounter == null) {
      trainingCounter = 0;
      prefs.setInt("trainingCounter", 0);
    }
    print("Nickname is $nickname");
    setState(() {});
  }

  String createRandomNick() {
    var rng = Random();
    return (rng.nextInt(9000) + 1000).toString();
  }
}
