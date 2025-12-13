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
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        // Convert XFile to File
        final File imageFile = File(photo.path);

        // Navigate to preprocessing screen with the captured image
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PreprocessingScreen(imageFile: imageFile),
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Automatically open camera when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePicture();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Photo'),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF4FF),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: _isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF0B5FA5),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Opening Camera...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          )
              : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Camera Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B5FA5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 60,
                    color: Color(0xFF0B5FA5),
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Camera Ready',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B2946),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Position the skin lesion in good lighting',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Capture Button
                ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera),
                  label: const Text('Take Picture'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0B5FA5).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFF0B5FA5),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tips for Best Results:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0B2946),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('Use natural lighting'),
                      _buildTip('Keep camera steady'),
                      _buildTip('Fill frame with lesion'),
                      _buildTip('Avoid shadows'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Color(0xFF0B5FA5),
          ),
          const SizedBox(width: 8),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

/*
🎓 BEGINNER EXPLANATION:

1. StatefulWidget vs StatelessWidget:
   - StatefulWidget: Can change over time (has setState())
   - StatelessWidget: Never changes

2. ImagePicker:
   - Opens device camera or gallery
   - Returns an XFile (cross-platform file)

3. setState():
   - Tells Flutter to rebuild the widget
   - Use it when data changes (like _isLoading)

4. Navigation:
   - Navigator.push: Go to new screen
   - Navigator.pop: Go back
   - Navigator.pushReplacement: Replace current screen

5. Async/Await:
   - async: Function runs in background
   - await: Wait for result before continuing

6. Future<void>:
   - Future: Represents a value that will be available later
   - void: Function doesn't return anything

📝 NOTE FOR REAL CAMERA:
   If you want a live camera preview (like Instagram),
   you would use the 'camera' package instead of 'image_picker'.

   Steps to add real camera later:
   1. Add to pubspec.yaml: camera: ^0.10.5
   2. Initialize CameraController
   3. Show CameraPreview widget
   4. Add flash toggle button

   For now, image_picker is simpler and works perfectly!
*/