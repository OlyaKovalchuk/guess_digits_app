import 'dart:math';

import 'package:digits_app/digits_recognizer.dart';
import 'package:digits_app/drawing_points.dart';
import 'package:digits_app/painter.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class PainterPage extends StatefulWidget {
  const PainterPage({Key? key}) : super(key: key);

  @override
  State<PainterPage> createState() => _PainterPageState();
}

class _PainterPageState extends State<PainterPage> {
  List<DrawingPoints> points = [];
  Size size = const Size(0, 0);
  double left = 0;
  double top = 0;
  final recognizerManager = DigitsRecognizer();

  @override
  void initState() {
    super.initState();
    recognizerManager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text('Please draw a digit'),
              const SizedBox(height: 30),
              Stack(
                children: [
                  Container(
                    width: 300,
                    height: 400,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                  ),
                  Positioned(
                    top: top,
                    left: left,
                    child: Container(
                      width: size.width,
                      height: size.height,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                    ),
                  ),
                  GestureDetector(
                    onPanStart: onPanStart,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanEnd,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(200, 400),
                        painter: Painter(
                            pointsList: points, ink: recognizerManager.ink),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FutureBuilder(
                  future: recognizerManager.recognizeText(),
                  builder: (_, data) {
                    return data.hasData
                        ? Text(
                            data.data.toString(),
                            style: const TextStyle(fontSize: 40),
                          )
                        : const SizedBox();
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Clear'),
                  ),
                  ElevatedButton(
                    onPressed: _checkDigit,
                    child: const Text('Check'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<Uint8List?> _renderImage() async {
  //   final renderedImage = await _controller.renderImage(const Size(200, 400));
  //   final byteData = await renderedImage.pngBytes;
  //   List<String> binaryArray = [];
  //   if (byteData != null)
  //     // ignore: curly_braces_in_flow_control_structures
  //     for (final bit in byteData) {
  //       binaryArray.add(intTo8bitString(bit));
  //     }
  //
  //   return byteData;
  // }

  void _checkDigit() {
    // _clearPainter();
    // _renderImage();
  }

  String intTo8bitString(int number, {bool prefix = false}) => prefix
      ? '0x${number.toRadixString(2).padLeft(8, '0')}'
      : number.toRadixString(2).padLeft(8, '0');

  final _pattern = RegExp(r'(?:0x)?(\d+)');

  int binaryStringToInt(String binaryString) =>
      int.parse(_pattern.firstMatch(binaryString)!.group(1)!, radix: 2);

  void onPanStart(DragStartDetails details) {
    recognizerManager.ink.strokes.add(Stroke());
    setState(() {});
  }

  Future<void> onPanUpdate(DragUpdateDetails details) async {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = (box).globalToLocal(details.localPosition);
    recognizerManager.points = List.from(recognizerManager.points)
      ..add(StrokePoint(
        x: localPosition.dx,
        y: localPosition.dy,
        t: DateTime.now().millisecondsSinceEpoch,
      ));
    if (recognizerManager.ink.strokes.isNotEmpty) {
      recognizerManager.ink.strokes.last.points =
          recognizerManager.points.toList();
    }
    setState(() {});
  }

  Size _getSizeOfDigit() {
    final dy = points.map((e) => e.points.dy).toList();
    final dx = points.map((e) => e.points.dx).toList();

    final lowestPoint = dy.reduce(max);
    final rightPoint = dx.reduce(max);
    top = dy.reduce(min);
    left = dx.reduce(min);

    final leftTopOffset = Offset(left, top);
    final leftBottomOffset = Offset(left, lowestPoint);
    final rightBottomOffset = Offset(rightPoint, lowestPoint);
    final height = (leftTopOffset - leftBottomOffset).distance;
    final width = (leftBottomOffset - rightBottomOffset).distance;

    return Size(width, height);
  }

  Future<void> onPanEnd(DragEndDetails details) async {
    print('User ended drawing');

    await recognizerManager.recognizeText();
    setState(() {
      size = _getSizeOfDigit();
    });
  }
}
