import 'package:equatable/equatable.dart';

class FileEntity extends Equatable {
  final String id;
  final String fileName;
  final String filePath;
  final String fileType;
  final String? mimeType;
  final int fileSize;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? geminiAnalysis;
  final List<String>? tags;
  final String? description;
  final String? thumbnailPath;

  const FileEntity({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    this.mimeType,
    required this.fileSize,
    required this.createdAt,
    required this.updatedAt,
    this.geminiAnalysis,
    this.tags,
    this.description,
    this.thumbnailPath,
  });

  @override
  List<Object?> get props => [
        id,
        fileName,
        filePath,
        fileType,
        mimeType,
        fileSize,
        createdAt,
        updatedAt,
        geminiAnalysis,
        tags,
        description,
        thumbnailPath,
      ];
}
