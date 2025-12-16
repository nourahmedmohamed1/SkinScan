import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/prediction.dart'; // Ensure this model exists

class AIService {
  late Interpreter _interpreter;
  // Replace these with your actual model's labels in order
  final List<String> labels = [
    'Actinic keratosis',
    'Basal cell carcinoma',
    'Benign keratosis',
    'Dermatofibroma',
    'Melanocytic nevi',
    'Melanoma',
    'Vascular lesion'
  ];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // THE MISSING METHOD
  Future<Prediction> analyzeImage(File imageFile) async {
    // 1. Preprocess the image to 224x224 (Standard for most skin models)
    var input = _preprocess(imageFile);

    // 2. Prepare output buffer (matching number of classes, e.g., 7)
    var output =
        List<double>.filled(labels.length, 0).reshape([1, labels.length]);

    // 3. Run Inference
    _interpreter.run(input, output);

    // 4. Find the best result
    List<double> probabilities = List<double>.from(output[0]);
    int bestIndex = 0;
    double maxConfidence = 0.0;

    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        bestIndex = i;
      }
    }

    // 5. Return the Prediction object your screen expects
    return Prediction(
      result: labels[bestIndex],
      confidence: maxConfidence * 100, // Convert to percentage
    );
  }

  // Internal helper to resize and normalize image pixels
  List<dynamic> _preprocess(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    img.Image resized = img.copyResize(image!, width: 224, height: 224);

    // Create a 4D list: [Batch, Height, Width, Channels]
    var input = List.generate(
        1,
        (i) => List.generate(
            224, (y) => List.generate(224, (x) => List.filled(3, 0.0))));

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        // Normalize 0-255 to 0.0-1.0
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }
    return input;
  }

  void dispose() {
    _interpreter.close();
  }
}
