import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'preprocessing_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  // Pick image from gallery
  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigate to preprocessing screen
  void _continueToPreprocessing() {
    if (_selectedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreprocessingScreen(imageFile: _selectedImage!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
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
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF0B5FA5),
            ),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Image Preview or Placeholder
              _selectedImage == null
                  ? _buildImagePlaceholder()
                  : _buildImagePreview(),

              const SizedBox(height: 32),

              // Pick Image Button
              if (_selectedImage == null)
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 20,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    // Continue Button
                    ElevatedButton.icon(
                      onPressed: _continueToPreprocessing,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Continue to Analysis'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Change Image Button
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Choose Different Image'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0B5FA5),
                        side: const BorderSide(
                          color: Color(0xFF0B5FA5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 48),

              // Information Box
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
                          Icons.info_outline,
                          color: Color(0xFF0B5FA5),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Image Requirements:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0B2946),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRequirement('Clear, well-lit photo'),
                    _buildRequirement('Lesion should be visible'),
                    _buildRequirement('Avoid blurry images'),
                    _buildRequirement('JPG or PNG format'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Placeholder when no image is selected
  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0B5FA5).withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: const Color(0xFF0B5FA5).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No image selected',
            style: TextStyle(
              fontSize: 18,
              color: const Color(0xFF6B7280).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // Image preview when image is selected
  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
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
          _selectedImage!,
          fit: BoxFit.cover,
          height: 300,
        ),
      ),
    );
  }

  Widget _buildRequirement(String requirement) {
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
            requirement,
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

1. File? vs File:
   - File?: Can be null (no image selected yet)
   - File: Always has a value

2. setState() usage:
   - Called when _selectedImage changes
   - Rebuilds the widget to show the new image

3. Conditional rendering:
   - _selectedImage == null ? ... : ...
   - Shows different UI based on state

4. Image.file():
   - Displays an image from device storage
   - fit: BoxFit.cover makes it fill the space

5. ClipRRect:
   - Clips child widget to rounded corners
   - Makes the image have rounded edges

6. OutlinedButton vs ElevatedButton:
   - ElevatedButton: Filled background (primary action)
   - OutlinedButton: Just border (secondary action)
*/