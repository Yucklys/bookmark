import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';

@singleton
class FileStorageService {
  Directory? _appFilesDirectory;
  Directory? _thumbnailDirectory;

  Future<Directory> get appFilesDirectory async {
    if (_appFilesDirectory != null) return _appFilesDirectory!;

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    _appFilesDirectory = Directory(
      path.join(appDocDir.path, AppConstants.appDirectoryName),
    );

    if (!await _appFilesDirectory!.exists()) {
      await _appFilesDirectory!.create(recursive: true);
    }

    return _appFilesDirectory!;
  }

  Future<Directory> get thumbnailDirectory async {
    if (_thumbnailDirectory != null) return _thumbnailDirectory!;

    final Directory filesDir = await appFilesDirectory;
    _thumbnailDirectory = Directory(
      path.join(filesDir.path, AppConstants.thumbnailDirectoryName),
    );

    if (!await _thumbnailDirectory!.exists()) {
      await _thumbnailDirectory!.create(recursive: true);
    }

    return _thumbnailDirectory!;
  }

  /// Copy a file to the app's storage directory
  Future<String> copyFileToStorage(String sourcePath, String fileId) async {
    try {
      final File sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw const FileStorageFailure('Source file does not exist');
      }

      // Check file size
      final int fileSize = await sourceFile.length();
      if (fileSize > AppConstants.maxFileSizeBytes) {
        throw FileStorageFailure(
          'File size exceeds maximum allowed size of ${AppConstants.maxFileSizeBytes ~/ (1024 * 1024)}MB',
        );
      }

      final Directory filesDir = await appFilesDirectory;
      final String fileName = path.basename(sourcePath);
      final String extension = path.extension(fileName);

      // Create unique filename using fileId
      final String newFileName = '$fileId$extension';
      final String destinationPath = path.join(filesDir.path, newFileName);

      // Copy the file
      await sourceFile.copy(destinationPath);

      return destinationPath;
    } catch (e) {
      if (e is FileStorageFailure) rethrow;
      throw FileStorageFailure('Failed to copy file: ${e.toString()}');
    }
  }

  /// Delete a file from storage
  Future<void> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileStorageFailure('Failed to delete file: ${e.toString()}');
    }
  }

  /// Delete a thumbnail
  Future<void> deleteThumbnail(String thumbnailPath) async {
    try {
      final File thumbnail = File(thumbnailPath);
      if (await thumbnail.exists()) {
        await thumbnail.delete();
      }
    } catch (e) {
      // Don't throw error if thumbnail deletion fails
      // Just log it
      print('Warning: Failed to delete thumbnail: ${e.toString()}');
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.length();
    } catch (e) {
      throw FileStorageFailure('Failed to get file size: ${e.toString()}');
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final File file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get total storage used by app files
  Future<int> getTotalStorageUsed() async {
    try {
      final Directory filesDir = await appFilesDirectory;
      int totalSize = 0;

      await for (final FileSystemEntity entity in filesDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      throw FileStorageFailure('Failed to calculate storage usage: ${e.toString()}');
    }
  }

  /// Clean up orphaned files (files not in database)
  Future<void> cleanupOrphanedFiles(List<String> validFilePaths) async {
    try {
      final Directory filesDir = await appFilesDirectory;
      final Set<String> validPaths = validFilePaths.toSet();

      await for (final FileSystemEntity entity in filesDir.list()) {
        if (entity is File && !validPaths.contains(entity.path)) {
          await entity.delete();
        }
      }
    } catch (e) {
      throw FileStorageFailure('Failed to cleanup orphaned files: ${e.toString()}');
    }
  }
}
