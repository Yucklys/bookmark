#!/usr/bin/env dart

/// Simplified test script - supports automatic configuration loading
///
/// Running modes:
/// 1. Automatic mode: dart run test_extraction_simple.dart
/// 2. Specify image: dart run test_extraction_simple.dart <image_path>
/// 3. Fully manual: dart run test_extraction_simple.dart <image_path> <api_key>

import 'dart:io';
import 'package:bookmark/data/datasources/remote/gemini_api_client.dart';
import 'package:bookmark/data/datasources/local/image_extraction_service.dart';
import 'package:bookmark/core/config/env_loader.dart';

Future<void> main(List<String> args) async {
  print('🚀 Image Object Extraction Test (Simplified)\n');

  String imagePath;
  String apiKey;

  // Support three running modes
  if (args.isEmpty) {
    // Fully automatic mode - read from config file
    print('🔧 Loading settings from config file...\n');
    try {
      final config = await EnvLoader.loadConfig();
      imagePath = config.imagePath;
      apiKey = config.apiKey;

      print('✅ Configuration loaded successfully');
      print('📸 Image: $imagePath');
      print('🔑 API Key: ${apiKey.substring(0, 10)}...\n');
    } catch (e) {
      print('❌ Configuration loading failed: $e\n');
      print('Please run using one of the following methods:');
      print('  1. Ensure GetImage/.env.local exists and contains API_KEY');
      print('  2. Manually specify parameters: dart run test_extraction_simple.dart <image_path> <api_key>');
      exit(1);
    }
  } else if (args.length == 1) {
    // Specify image, auto-load API Key
    imagePath = args[0];
    print('📸 Using specified image: $imagePath');
    try {
      final config = await EnvLoader.loadConfig();
      apiKey = config.apiKey;
      print('🔑 API Key loaded from config: ${apiKey.substring(0, 10)}...\n');
    } catch (e) {
      print('❌ API Key loading failed: $e');
      print('Please manually specify API Key: dart run test_extraction_simple.dart $imagePath <api_key>');
      exit(1);
    }
  } else {
    // Fully manual mode (backward compatible)
    imagePath = args[0];
    apiKey = args[1];
    print('📸 Image path: $imagePath');
    print('🔑 API Key: ${apiKey.substring(0, 10)}...\n');
  }

  // Check if image file exists
  if (!File(imagePath).existsSync()) {
    print('❌ Image file not found: $imagePath');
    exit(1);
  }

  print('📸 Image path: $imagePath');
  print('🔑 API Key: ${apiKey.substring(0, 10)}...\n');

  try {
    // Manually create service instances (without dependency injection)
    print('⚙️  Initializing services...');
    final geminiClient = GeminiApiClient();
    final extractionService = ImageExtractionService(geminiClient);
    print('✅ Services initialized successfully\n');

    // Set output directory
    final outputDir = './test_outputs';
    print('📁 Output directory: $outputDir\n');

    // Execute extraction
    print('🔍 Starting object extraction...\n');
    print('=' * 60);

    final metadata = await extractionService.extractObjects(
      imagePath: imagePath,
      outputDir: outputDir,
      apiKey: apiKey,
    );

    print('=' * 60);
    print('\n✅ Extraction completed!\n');

    // Display results
    print('📊 Extraction statistics:');
    print('  - Source image: ${metadata.sourceImage}');
    print('  - Size: ${metadata.imageSize[0]} × ${metadata.imageSize[1]}');
    print('  - Total objects: ${metadata.totalObjects}');
    print('');

    if (metadata.items.isNotEmpty) {
      print('📦 Extracted objects list:\n');
      for (final item in metadata.items) {
        print('  ${item.id}:');
        print('    File: ${item.filename}');
        print('    Size: ${item.width} × ${item.height}');
        print('    Position: (${item.bbox[0]}, ${item.bbox[1]})');
        print('    Area ratio: ${(item.areaRatio * 100).toStringAsFixed(2)}%');
        print('');
      }

      print('💾 All files saved to: $outputDir/');
      print('   - ${metadata.totalObjects} PNG files');
      print('   - 1 meta.json metadata file');
    } else {
      print('⚠️  No objects detected');
    }

    print('\n🎉 Test successful!');

  } catch (e, stackTrace) {
    print('\n❌ Test failed: $e\n');
    print('Stack trace:');
    print(stackTrace);
    exit(1);
  }
}
