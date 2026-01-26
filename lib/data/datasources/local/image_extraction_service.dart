import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import '../remote/gemini_api_client.dart';
import '../../models/extracted_object_model.dart';

/// Image extraction service - ports GetImage Node.js logic to Dart
@singleton
class ImageExtractionService {
  final GeminiApiClient _geminiClient;

  static const double minAreaRatio = 0.01; // 1% minimum area
  static const int maxObjects = 12;

  ImageExtractionService(this._geminiClient);

  /// Extract objects from image
  ///
  /// [imagePath] Source image path
  /// [outputDir] Output directory path
  /// [apiKey] Gemini API key
  ///
  /// Returns extraction metadata
  Future<ExtractionMetadata> extractObjects({
    required String imagePath,
    required String outputDir,
    required String apiKey,
  }) async {
    // 1. Initialize Gemini API
    _geminiClient.initialize(apiKey);

    // 2. Create output directory
    final outputDirectory = Directory(outputDir);
    if (!await outputDirectory.exists()) {
      await outputDirectory.create(recursive: true);
    }

    // 3. Read image
    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw Exception('Image file not found: $imagePath');
    }

    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final imgWidth = image.width;
    final imgHeight = image.height;

    print('📸 Loading image: $imagePath');
    print('📐 Image size: ${imgWidth}×${imgHeight}\n');

    // 4. Detect objects using Gemini API
    print('🔍 Analyzing image with Gemini Flash...');
    final detectedObjects = await _geminiClient.detectObjects(imageBytes);
    print('\n🎯 Found ${detectedObjects.length} potential objects\n');

    if (detectedObjects.isEmpty) {
      print('⚠️  No objects detected. Try a different image.');
      return ExtractionMetadata(
        sourceImage: path.basename(imagePath),
        imageSize: [imgWidth, imgHeight],
        totalObjects: 0,
        items: [],
      );
    }

    // 5. Filter and sort (by area)
    final totalArea = imgWidth * imgHeight;
    final filteredObjects = _filterAndSortObjects(
      detectedObjects,
      imgWidth,
      imgHeight,
      totalArea,
    );

    print('🔧 After filtering: ${filteredObjects.length} objects (min ${minAreaRatio * 100}% area)\n');
    print('💾 Extracting objects...\n');

    // 6. Extract each object
    final extractedObjects = <ExtractedObjectModel>[];
    for (int i = 0; i < filteredObjects.length; i++) {
      final obj = filteredObjects[i];
      final metadata = await _extractSingleObject(
        image,
        obj,
        i,
        outputDir,
        imgWidth,
        imgHeight,
      );
      extractedObjects.add(metadata);
    }

    // 7. Save metadata
    final metadata = ExtractionMetadata(
      sourceImage: path.basename(imagePath),
      imageSize: [imgWidth, imgHeight],
      totalObjects: extractedObjects.length,
      items: extractedObjects,
    );

    final metaPath = path.join(outputDir, 'meta.json');
    await File(metaPath).writeAsString(_metadataToJson(metadata));

    print('\n📦 Metadata saved to: meta.json');
    print('\n✅ Extraction complete! ${extractedObjects.length} objects saved to $outputDir/\n');

    return metadata;
  }

  /// Filter and sort objects
  List<_FilteredObject> _filterAndSortObjects(
    List<DetectedObject> objects,
    int imgWidth,
    int imgHeight,
    int totalArea,
  ) {
    return objects
        .map((obj) {
          // Convert 0-1000 coordinates to pixel coordinates
          final w = ((obj.xmax - obj.xmin) / 1000) * imgWidth;
          final h = ((obj.ymax - obj.ymin) / 1000) * imgHeight;
          final area = w * h;
          final areaRatio = area / totalArea;

          return _FilteredObject(
            detectedObject: obj,
            area: area,
            areaRatio: areaRatio,
          );
        })
        .where((obj) => obj.areaRatio >= minAreaRatio)
        .toList()
      ..sort((a, b) => b.area.compareTo(a.area))
      ..take(maxObjects);
  }

  /// Extract single object
  Future<ExtractedObjectModel> _extractSingleObject(
    img.Image image,
    _FilteredObject obj,
    int index,
    String outputDir,
    int imgWidth,
    int imgHeight,
  ) async {
    final detected = obj.detectedObject;

    // Convert 0-1000 coordinates to pixel coordinates
    final x = ((detected.xmin / 1000) * imgWidth).floor();
    final y = ((detected.ymin / 1000) * imgHeight).floor();
    final w = (((detected.xmax - detected.xmin) / 1000) * imgWidth).floor();
    final h = (((detected.ymax - detected.ymin) / 1000) * imgHeight).floor();

    // Boundary check
    final safeX = x.clamp(0, imgWidth - 1);
    final safeY = y.clamp(0, imgHeight - 1);
    final safeW = (w).clamp(1, imgWidth - safeX);
    final safeH = (h).clamp(1, imgHeight - safeY);

    // Crop image
    final cropped = img.copyCrop(
      image,
      x: safeX,
      y: safeY,
      width: safeW,
      height: safeH,
    );

    // Calculate area ratio
    final areaRatio = (safeW * safeH) / (imgWidth * imgHeight);

    // Save as PNG
    final filename = 'item_$index.png';
    final filepath = path.join(outputDir, filename);
    final pngBytes = img.encodePng(cropped);
    await File(filepath).writeAsBytes(pngBytes);

    print('  ✓ $filename - ${safeW}×${safeH} (${(areaRatio * 100).toStringAsFixed(2)}%)');

    return ExtractedObjectModel(
      id: 'item_$index',
      filename: filename,
      bbox: [safeX, safeY, safeW, safeH],
      width: safeW,
      height: safeH,
      areaRatio: double.parse(areaRatio.toStringAsFixed(4)),
    );
  }

  /// Convert metadata to JSON string
  String _metadataToJson(ExtractionMetadata metadata) {
    final jsonMap = metadata.toJson();
    // Manually format JSON (simplified version)
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln('  "source_image": "${jsonMap['source_image']}",');
    buffer.writeln('  "image_size": ${jsonMap['image_size']},');
    buffer.writeln('  "total_objects": ${jsonMap['total_objects']},');
    buffer.writeln('  "items": [');

    final items = jsonMap['items'] as List;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.writeln('    {');
      buffer.writeln('      "id": "${item['id']}",');
      buffer.writeln('      "filename": "${item['filename']}",');
      buffer.writeln('      "bbox": ${item['bbox']},');
      buffer.writeln('      "width": ${item['width']},');
      buffer.writeln('      "height": ${item['height']},');
      buffer.write('      "area_ratio": ${item['area_ratio']}');
      buffer.writeln(i == items.length - 1 ? '' : ',');
      buffer.writeln(i == items.length - 1 ? '    }' : '    },');
    }

    buffer.writeln('  ]');
    buffer.writeln('}');
    return buffer.toString();
  }
}

/// Filtered object (internal use)
class _FilteredObject {
  final DetectedObject detectedObject;
  final double area;
  final double areaRatio;

  _FilteredObject({
    required this.detectedObject,
    required this.area,
    required this.areaRatio,
  });
}
