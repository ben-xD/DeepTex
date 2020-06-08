import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class ImagePreview extends StatelessWidget {
  ImagePreview(this.image);
  ByteData image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Image.memory(image.buffer.asUint8List()));
  }
}
