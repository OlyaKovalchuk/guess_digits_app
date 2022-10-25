import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class DigitsRecognizer {
  final DigitalInkRecognizerModelManager modelManager =
      DigitalInkRecognizerModelManager();
  final String language = 'en-US';
  late final DigitalInkRecognizer digitalInkRecognizer =
      DigitalInkRecognizer(languageCode: language);

  final Ink ink = Ink();
  List<StrokePoint> points = [];

  String recognizedText = '';

  void clearPad() {
    ink.strokes.clear();
    points.clear();
  }

  Future<void> init() async {
    final bool isModelDownloaded =
        await modelManager.isModelDownloaded(language);
    if (!isModelDownloaded) {
      await modelManager.downloadModel(language);
    }
  }

  Future<String> recognizeText() async {
    final candidates = await digitalInkRecognizer.recognize(ink);

    return candidates.first.text;
  }
}
