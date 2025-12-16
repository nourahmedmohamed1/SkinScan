import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart'; 
import 'results_screen.dart';
import '../services/ai_service.dart';
import '../models/prediction.dart';
import '../models/scan_record.dart'; 
import '../services/scan_history_provider.dart'; 

class PreprocessingScreen extends StatefulWidget {
  final File imageFile;
  // Note: We don't necessarily need to pass aiResults here because 
  // this screen allows cropping, so we should run the AI AFTER the user crops.

  const PreprocessingScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<PreprocessingScreen> createState() => _PreprocessingScreenState();
}

class _PreprocessingScreenState extends State<PreprocessingScreen> {
  late File _currentImage;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.imageFile;
  }

  // Crop the image
  Future<void> _cropImage() async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _currentImage.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Image',
            toolbarColor: const Color(0xFF0B5FA5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Edit Image',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _currentImage = File(croppedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error cropping image: $e");
    }
  }

  // Modified Analysis Function
  Future<void> _runAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // 1. Access the AI Service provided in main.dart
      final aiService = Provider.of<AIService>(context, listen: false);

      // 2. Run analysis on the current (possibly cropped) image
      // Note: analyzeImage should be a method in your AIService that returns a Prediction model
      final Prediction prediction = await aiService.analyzeImage(_currentImage);

      if (mounted) {
        // 3. Save to History automatically
        final scanRecord = ScanRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imagePath: _currentImage.path,
          result: prediction.result,
          confidence: prediction.confidence,
          date: DateTime.now(),
        );

        Provider.of<ScanHistoryProvider>(context, listen: false).addScan(scanRecord);

        // 4. Navigate to Results Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              prediction: prediction,
              imageFile: _currentImage,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prepare Image'),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF4FF), Colors.white],
          ),
        ),
        child: _isAnalyzing
            ? _buildAnalyzingView()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildImagePreview(),
                    const SizedBox(height: 32),
                    const Text(
                      'Review Your Image',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B2946)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Crop the image if needed to focus on the lesion',
                      style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: _cropImage,
                      icon: const Icon(Icons.crop),
                      label: const Text('Crop Image'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0B5FA5),
                        side: const BorderSide(color: Color(0xFF0B5FA5), width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _runAnalysis,
                      icon: const Icon(Icons.analytics),
                      label: const Text('Run AI Analysis'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInfoBox(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(_currentImage, fit: BoxFit.cover, height: 350),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0B5FA5).withValues(alpha: 0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF0B5FA5), size: 20),
              SizedBox(width: 8),
              Text('What happens next?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Our AI will analyze the image and provide classification and confidence score.',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B5FA5)),
          ),
          SizedBox(height: 24),
          Text("AI is processing image...", style: TextStyle(fontSize: 18, color: Color(0xFF0B5FA5))),
        ],
      ),
    );
  }
}
