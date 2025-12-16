import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _hasAcceptedCaution = false;
  bool _isSpeaking = true; // State to track if audio is enabled

  @override
  void initState() {
    super.initState();

    // 1. Initialize Animation (Dynamic Pulse Effect)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 2. Start the welcome audio message automatically
    _speakWelcomeMessage();
  }

  // Function to handle Text-to-Speech
  Future<void> _speakWelcomeMessage() async {
    if (!_isSpeaking) return;

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    String message = "Welcome to Skin Care Scan. "
        "Our AI-powered application assists you in early skin cancer detection. "
        "Please note that early detection significantly improves treatment outcomes. "
        "Read the caution message and press start to begin.";

    await _flutterTts.speak(message);
  }

  // Trigger button function to Mute/Unmute audio
  void _toggleSpeech() {
    setState(() {
      _isSpeaking = !_isSpeaking;
    });
    if (!_isSpeaking) {
      _flutterTts.stop(); // Stop audio immediately if muted
    } else {
      _speakWelcomeMessage(); // Restart audio if unmuted
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _flutterTts.stop(); // Clean up TTS engine
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Floating button to toggle audio on/off
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSpeech,
        backgroundColor: const Color(0xFF0B5FA5),
        child: Icon(_isSpeaking ? Icons.volume_up : Icons.volume_off),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B5FA5), Color(0xFFEAF4FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Branding
              const Text(
                'SkinCareScan',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),

              // Dynamic Pulse Animation for the Logo
              ScaleTransition(
                scale: _animation,
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.biotech, size: 100, color: Colors.white),
                ),
              ),

              const SizedBox(height: 40),

              // Caution / Disclaimer Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'CAUTION',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'This application is a prototype for educational purposes. '
                            'It is NOT a medical diagnostic tool. Always consult a doctor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Acceptance Checkbox
              CheckboxListTile(
                title: const Text(
                  "I understand and accept the disclaimer",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                value: _hasAcceptedCaution,
                onChanged: (val) => setState(() => _hasAcceptedCaution = val!),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFF0B5FA5),
              ),

              const SizedBox(height: 10),

              // Start Button: Only enabled if checkbox is ticked
              ElevatedButton(
                onPressed: _hasAcceptedCaution
                    ? () {
                  _flutterTts.stop(); // Stop audio before navigating
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(250, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('GET STARTED'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}