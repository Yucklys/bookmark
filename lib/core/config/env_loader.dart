import 'dart:io';

/// Configuration loader - automatically reads settings from config files
///
/// Features:
/// - Reads API Key from GetImage/.env.local
/// - Uses lib/data/image/test1.jpg as default image
class EnvLoader {
  static const String envPath = 'GetImage/.env.local';
  static const String defaultImagePath = 'lib/data/image/test1.jpg';

  /// Load complete configuration
  static Future<AppConfig> loadConfig() async {
    String apiKey = await _loadApiKey();
    String imagePath = defaultImagePath;
    return AppConfig(apiKey: apiKey, imagePath: imagePath);
  }

  /// Read API Key from .env.local
  static Future<String> _loadApiKey() async {
    final file = File(envPath);

    if (!await file.exists()) {
      throw Exception('❌ Config file not found: $envPath\nPlease ensure GetImage/.env.local exists');
    }

    final content = await file.readAsString();

    // Support multiple API Key variable names
    final patterns = [
      RegExp(r'API_KEY\s*=\s*(.+)'),
      RegExp(r'GEMINI_API_KEY\s*=\s*(.+)'),
    ];

    for (final regex in patterns) {
      final match = regex.firstMatch(content);
      if (match != null) {
        final apiKey = match.group(1)!.trim();
        // Remove possible quotes
        return apiKey.replaceAll(RegExp(r'''^["\']|["\']$'''), '');
      }
    }

    throw Exception('❌ API_KEY or GEMINI_API_KEY not found in $envPath');
  }

  /// Check if default image exists
  static Future<bool> checkDefaultImageExists() async {
    return await File(defaultImagePath).exists();
  }
}

/// Application configuration
class AppConfig {
  final String apiKey;
  final String imagePath;

  AppConfig({
    required this.apiKey,
    required this.imagePath,
  });

  @override
  String toString() {
    return 'AppConfig(imagePath: $imagePath, apiKey: ${apiKey.substring(0, 10)}...)';
  }
}
