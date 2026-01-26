import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

/// Gemini API client for image analysis and object detection
@singleton
class GeminiApiClient {
  // Using Gemini 2.5 Flash (Gemini 3 may not be available in API yet)
  static const String modelName = 'gemini-2.5-flash';
  static const double minAreaRatio = 0.01; // 1% minimum area
  static const int maxObjects = 12;

  GenerativeModel? _model;

  /// Initialize Gemini model
  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  /// Detect objects in image and return bounding box coordinates
  ///
  /// Return format: List<Map<String, dynamic>>
  /// Each object contains: { "box_2d": [ymin, xmin, ymax, xmax] }
  /// Coordinate range: 0-1000
  Future<List<DetectedObject>> detectObjects(Uint8List imageBytes) async {
    if (_model == null) {
      throw Exception('Gemini API client not initialized. Call initialize() first.');
    }

    final systemInstruction = '''
You are an ultra-fast instance segmentation agent.
Goal: Identify distinct, complete physical objects.
Format: [ymin, xmin, ymax, xmax] (0-1000).
Rules:
- Target: Books, laptop, camera, phone, mouse, tools, cups, stationery.
- Filter: Only objects > 1% area.
- Max: 12 objects.
- Output: STRICT JSON ONLY.

Output format:
{
  "objects": [
    {
      "box_2d": [ymin, xmin, ymax, xmax]
    }
  ]
}
''';

    try {
      final prompt = TextPart('Extract coordinates for all primary objects.');
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await _model!.generateContent([
        Content.multi([imagePart, prompt]),
        Content.text(systemInstruction),
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      // Parse JSON response
      final json = _parseJson(text);
      final objects = json['objects'] as List<dynamic>? ?? [];

      return objects
          .map((obj) => DetectedObject.fromJson(obj as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to detect objects: $e');
    }
  }

  /// Parse JSON text (with error tolerance)
  Map<String, dynamic> _parseJson(String text) {
    try {
      // Remove possible markdown code block markers
      String cleanText = text.trim();
      if (cleanText.startsWith('```json')) {
        cleanText = cleanText.substring(7);
      }
      if (cleanText.startsWith('```')) {
        cleanText = cleanText.substring(3);
      }
      if (cleanText.endsWith('```')) {
        cleanText = cleanText.substring(0, cleanText.length - 3);
      }

      // Parse using dart:convert
      final dynamic parsed = jsonDecode(cleanText.trim());
      if (parsed is! Map<String, dynamic>) {
        throw Exception('Expected JSON object, got ${parsed.runtimeType}');
      }
      return parsed;
    } catch (e) {
      throw Exception('Failed to parse JSON response: $text');
    }
  }
}

/// Detected object
class DetectedObject {
  final List<double> box2d; // [ymin, xmin, ymax, xmax] (0-1000)

  DetectedObject({required this.box2d});

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    final box = json['box_2d'] as List<dynamic>;
    return DetectedObject(
      box2d: box.map((e) => (e as num).toDouble()).toList(),
    );
  }

  double get ymin => box2d[0];
  double get xmin => box2d[1];
  double get ymax => box2d[2];
  double get xmax => box2d[3];

  /// Calculate area ratio (in 0-1000 coordinate system)
  double get area => (xmax - xmin) * (ymax - ymin);
}
