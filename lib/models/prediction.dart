/// Prediction model class
/// Holds the result of AI analysis
class Prediction {
  final String result;        // "Benign" or "Suspicious"
  final double confidence;    // 0.0 to 100.0

  Prediction({
    required this.result,
    required this.confidence,
  });

  // Create Prediction from JSON (useful when loading from API)
  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      result: json['result'] as String,
      confidence: json['confidence'] as double,
    );
  }

  // Convert Prediction to JSON (useful when saving to database)
  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'confidence': confidence,
    };
  }
}

/*
🎓 BEGINNER EXPLANATION:

1. Class:
   - Blueprint for creating objects
   - Like a structure in C

2. Properties:
   - final: Value can't change after creation
   - required: Must provide when creating object

3. Constructor:
   - Prediction(result: "Benign", confidence: 95.5)
   - Named parameters with {}

4. Factory constructor:
   - Alternative way to create objects
   - Useful for converting from JSON

5. Methods:
   - Functions inside a class
   - toJson() and fromJson() for serialization

EXAMPLE USAGE:
  final pred = Prediction(
    result: "Benign",
    confidence: 92.5,
  );

  print(pred.result);      // "Benign"
  print(pred.confidence);  // 92.5
*/