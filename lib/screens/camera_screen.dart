import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'preprocessing_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // This function opens the device camera
  Future<void> _takePicture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Pick image from camera
      // High quality is kept for better AI accuracy
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90, 
      );

      if (photo != null) {
        final File imageFile = File(photo.path);

        if (mounted) {
          // Pass the image to PreprocessingScreen
          // PreprocessingScreen will handle the AIService call
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PreprocessingScreen(imageFile: imageFile),
            ),
          );
        }
      } else {
        // User cancelled camera, stop loading
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 2025 Flutter Best Practice: Trigger camera after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePicture();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Skin Lesion'),
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
        child: Center(
          child: _isLoading
              ? _buildLoadingView()
              : _buildCapturePrompt(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B5FA5)),
        ),
        SizedBox(height: 24),
        Text(
          'Preparing Camera...',
          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildCapturePrompt() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF0B5FA5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(Icons.camera_alt, size: 60, color: Color(0xFF0B5FA5)),
          ),
          const SizedBox(height: 32),
          const Text(
            'Ready to Capture',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0B2946)),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: _takePicture,
            icon: const Icon(Icons.camera),
            label: const Text('Capture Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            ),
          ),
          const SizedBox(height: 48),
          _buildTipsBox(),
        ],
      ),
    );
  }

  Widget _buildTipsBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0B5FA5).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFF0B5FA5), size: 20),
              SizedBox(width: 8),
              Text('Tips for Best Results:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip('Ensure natural bright lighting'),
          _buildTip('Keep lesion centered and in focus'),
          _buildTip('Hold your phone steady'),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF0B5FA5)),
          const SizedBox(width: 8),
          Text(tip, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}
