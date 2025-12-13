/// ScanRecord model class
/// Represents a saved scan in history
class ScanRecord {
  final String id;            // Unique identifier
  final String imagePath;     // Path to image file
  final String result;        // "Benign" or "Suspicious"
  final double confidence;    // Confidence score
  final DateTime date;        // When scan was performed

  ScanRecord({
    required this.id,
    required this.imagePath,
    required this.result,
    required this.confidence,
    required this.date,
  });

  // Create ScanRecord from JSON
  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      result: json['result'] as String,
      confidence: json['confidence'] as double,
      date: DateTime.parse(json['date'] as String),
    );
  }

  // Convert ScanRecord to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'result': result,
      'confidence': confidence,
      'date': date.toIso8601String(),
    };
  }
}

/*
🎓 BEGINNER EXPLANATION:

1. DateTime:
   - Represents date and time
   - date.toIso8601String() → "2025-12-06T14:30:00.000"
   - DateTime.parse() converts string back to DateTime

2. Unique ID:
   - Usually timestamp: DateTime.now().millisecondsSinceEpoch.toString()
   - Ensures each record is unique

3. Serialization:
   - toJson(): Convert object to Map
   - fromJson(): Convert Map to object
   - Needed for saving to SharedPreferences

EXAMPLE USAGE:
  final scan = ScanRecord(
    id: "1733500800000",
    imagePath: "/data/image.jpg",
    result: "Benign",
    confidence: 92.5,
    date: DateTime.now(),
  );
*/