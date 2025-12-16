import 'package:flutter/material.dart';
import 'dart:io';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../models/prediction.dart';
import 'home_screen.dart';

class ResultsScreen extends StatefulWidget {
  final Prediction prediction;
  final File imageFile;

  const ResultsScreen({
    super.key,
    required this.prediction,
    required this.imageFile,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // Controller to handle the screenshot capture
  final ScreenshotController screenshotController = ScreenshotController();

  // Method to capture the report area and save it to the mobile gallery
  Future<void> _saveAsImage() async {
    try {
      // Capture the content inside the Screenshot widget
      // We add a small delay to ensure all UI elements are fully rendered
      final imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes != null) {
        // Get temporary directory to store the file before moving to gallery
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/skin_report_${DateTime.now().millisecond}.png').create();
        await file.writeAsBytes(imageBytes);

        // Save the file to the device gallery using the Gal package
        await Gal.putImage(file.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Full report saved to Gallery! 📸'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error saving image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigate back to the Home Screen and clear the navigation stack
  void _scanAgain(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuspicious = widget.prediction.result.toLowerCase() == 'suspicious';
    final Color resultColor = isSuspicious ? const Color(0xFFD9534F) : const Color(0xFF28A745);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => _scanAgain(context),
        ),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // This widget captures everything inside it as an image
              Screenshot(
                controller: screenshotController,
                child: Container(
                  // Solid background color ensures the saved image looks professional
                  padding: const EdgeInsets.all(24.0),
                  color: const Color(0xFFEAF4FF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      // 1. Result Status (Suspicious / Benign)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: resultColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: resultColor, width: 2),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isSuspicious ? Icons.warning_amber_rounded : Icons.check_circle,
                              size: 80,
                              color: resultColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.prediction.result.toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: resultColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 2. Confidence Card
                      _buildConfidenceCard(context, resultColor),

                      const SizedBox(height: 24),

                      // 3. The Analyzed Image
                      _buildImagePreview(),

                      const SizedBox(height: 32),

                      // 4. Medical Disclaimer
                      _buildDisclaimer(isSuspicious),
                    ],
                  ),
                ),
              ),

              // Action Buttons (Kept outside the Screenshot so they don't appear in the saved image)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saveAsImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Save Image'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B5FA5),
                          side: const BorderSide(color: Color(0xFF0B5FA5), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _scanAgain(context),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Scan Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for Confidence Score
  Widget _buildConfidenceCard(BuildContext context, Color resultColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Confidence Score',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B2946),
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 24,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                height: 24,
                width: MediaQuery.of(context).size.width *
                    (widget.prediction.confidence / 100) *
                    0.7,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B5FA5), Color(0xFF2A85D8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.prediction.confidence.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B5FA5),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for Image Preview
  Widget _buildImagePreview() {
    return Column(
      children: [
        const Text(
          'Analyzed Image',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0B2946),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              widget.imageFile,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget for Disclaimer
  Widget _buildDisclaimer(bool isSuspicious) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.medical_information, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'MEDICAL DISCLAIMER',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'This app is NOT a diagnostic tool and should NOT replace professional medical advice. Always consult a certified dermatologist for any skin concerns.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          if (isSuspicious) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⚠️ IMPORTANT: Schedule an appointment with a dermatologist as soon as possible.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ]
        ],
      ),
    );
  }
}