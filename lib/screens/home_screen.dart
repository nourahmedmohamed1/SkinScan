import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'upload_screen.dart';
import 'about_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkinCareScan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
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
        child: SafeArea(
          child: SingleChildScrollView( // الحل الأساسي لمشكلة Overflow
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // App Logo
                Container(
                  width: 100, // تقليل الحجم قليلاً ليتناسب مع الشاشات الصغيرة
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B5FA5),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B5FA5).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.medical_services, size: 50, color: Colors.white),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Welcome to SkinCareScan',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B2946),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Early detection saves lives.\nAnalyze skin lesions with AI assistance.',
                  style: TextStyle(fontSize: 15, color: Color(0xFF6B7280), height: 1.4),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // زر بدء فحص جديد (كاميرا) [cite: 19]
                _buildActionButton(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Start New Scan',
                  subtitle: 'Take a photo with camera',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CameraScreen())),
                ),

                const SizedBox(height: 16),

                // زر رفع صورة من المعرض [cite: 20]
                _buildActionButton(
                  context,
                  icon: Icons.photo_library,
                  label: 'Upload Image',
                  subtitle: 'Choose from gallery',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadScreen())),
                ),

                const SizedBox(height: 16),

                // زر التعليمات والمعلومات
                _buildActionButton(
                  context,
                  icon: Icons.info_outline,
                  label: 'Instructions & Info',
                  subtitle: 'Learn how to use the app',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen())),
                  isPrimary: false,
                ),

                const SizedBox(height: 40), // مسافة بديلة عن Spacer()

                // صندوق إخلاء المسؤولية
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This app is not a medical diagnostic tool. Always consult a healthcare professional.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ),
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

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isPrimary ? const Color(0xFF0B5FA5).withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: isPrimary ? const Color(0xFF0B5FA5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isPrimary ? Colors.white.withOpacity(0.2) : const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: isPrimary ? Colors.white : const Color(0xFF0B5FA5)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isPrimary ? Colors.white : const Color(0xFF0B2946),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isPrimary ? Colors.white.withOpacity(0.8) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: isPrimary ? Colors.white70 : Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}