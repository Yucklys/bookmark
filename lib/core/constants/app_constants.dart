class AppConstants {
  // Database
  static const String databaseName = 'bookmark.db';
  static const int databaseVersion = 1;

  // Tables
  static const String filesTable = 'files';
  static const String searchCacheTable = 'search_cache';

  // Storage
  static const String appDirectoryName = 'bookmark_files';
  static const String thumbnailDirectoryName = 'thumbnails';

  // Gemini API
  static const String geminiApiKeyStorageKey = 'gemini_api_key';
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // File constraints
  static const int maxFileSizeBytes = 100 * 1024 * 1024; // 100MB

  // Search
  static const int searchCacheExpiryHours = 24;
  static const int maxSearchResults = 50;
}
