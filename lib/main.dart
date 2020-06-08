import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:gallery_saver/gallery_saver.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deeptex/stroke.dart';
import 'package:deeptex/strokes_painter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text("Draw a LaTex Character"),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.history,
                    color: Colors.white,
                  ),
                  onPressed: null,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_sweep,
                    color: Colors.white,
                  ),
                  onPressed: null,
                ),
              ],
            ),
            body: Home()));
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State {
  // debounce after 500ms
  List<Stroke> strokes = [];
  List<Offset> points = [];
  Timer debouncedRecognition;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _busy = true;
    asyncInitState();
  }

  void asyncInitState() async {
    Tflite.close();
    try {
      String result = await Tflite.loadModel(
        model: "assets/tflite/model_1.tflite",
        labels: "assets/tflite/labels.txt",
        numThreads: 1,
        isAsset: true,
      );
      print(result);
    } on PlatformException {
      print("Failed to load model.");
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  void clearStrokes() {
    setState(() {
      strokes = [];
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  void saveImageHandler(img.Image image) async {
    // trim white side
    img.Image trimmedImage = img.trim(image,
        mode: img.TrimMode.bottomRightColor, sides: img.Trim.all);

    trimmedImage = img.copyResize(trimmedImage, width: 128, height: 128);
    print("width: ${trimmedImage.width}, height: ${trimmedImage.height}");

    // Upload image to google storage

    Directory dir = await getApplicationDocumentsDirectory();
    // why do file names need to be unique
    String imagePath = dir.path +
        "/trimmedImage-${new DateTime.now().millisecondsSinceEpoch}.jpg";
    await File(imagePath).writeAsBytes(img.encodeJpg(trimmedImage));

    // Remove saving to library
    bool saved = await GallerySaver.saveImage(imagePath);
    // savedFile.deleteSync();
    print("Saved?: $saved as $imagePath");
    print("Saved as $imagePath");
    return;
  }

  @override
  Widget build(BuildContext context) {
    var deviceData = MediaQuery.of(context);

    Uint8List imageToByteListUint8(
        img.Image image, int inputSize, double mean, double std) {
      var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
      var buffer = Float32List.view(convertedBytes.buffer);
      int pixelIndex = 0;
      for (var i = 0; i < inputSize; i++) {
        for (var j = 0; j < inputSize; j++) {
          int pixel = image.getPixel(j, i);

          // measure the perf for 111, vs without
          double Y = 0.299 * img.getRed(pixel) +
              0.587 * img.getGreen(pixel) +
              0.114 * img.getBlue(pixel);

          buffer[pixelIndex++] = Y - mean / std;
        }
      }
      return convertedBytes.buffer.asUint8List();
    }

    Future<img.Image> getImage() async {
      var deviceData = MediaQuery.of(context);
      ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas canvas = Canvas(recorder);
      canvas.drawColor(Colors.white, BlendMode.src);
      StrokesPainter painter = StrokesPainter(strokes: strokes);
      painter.paint(canvas, deviceData.size);
      ui.Image screenImage = await (recorder.endRecording().toImage(
          deviceData.size.width.floor(), deviceData.size.height.floor()));

      ByteData imgBytes =
          await screenImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      return img.Image.fromBytes(deviceData.size.width.floor(),
          deviceData.size.height.floor(), imgBytes.buffer.asUint8List());
    }

    void predictCharacterFromImage() async {
      // resize to small shape. say, 32x32. arbitrary
      img.Image resizedImage =
          img.copyResize(await getImage(), width: 32, height: 32);

      // var recognitions = await Tflite.runModelOnBinary(
      //     binary:
      //         imageToByteListUint8(resizedImage, 32, 127.5, 127.5), // required
      //     numResults: 6, // defaults to 5
      //     threshold: 0.05, // defaults to 0.1
      //     asynch: true // defaults to true
      //     );
      // print(recognitions);
    }

    return SizedBox(
      width: deviceData.size.width.toDouble(),
      height: deviceData.size.height.toDouble(),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onPanStart: (DragStartDetails details) {
              debouncedRecognition?.cancel();
              print("start draw");
              points.add(details.localPosition);
              setState(() {
                strokes.add(Stroke(points: points));
              });
            },
            onPanUpdate: (DragUpdateDetails details) {
              debouncedRecognition?.cancel();
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
              // start counting for debounce?
              debouncedRecognition =
                  Timer(Duration(milliseconds: 500), predictCharacterFromImage);
              // cancel in onPanStart or onPanUpdate
            },
            child: CustomPaint(
              painter: StrokesPainter(strokes: strokes),
              size: Size.infinite,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              // alignment: Alignment.center,
              child: Text("Information"),
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () async {
                  saveImageHandler(await getImage());
                },
              ),
              if (_busy)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
            ],
          )
        ],
      ),
    );
  }
}
