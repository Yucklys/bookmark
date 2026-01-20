import '../../domain/entities/file_entity.dart';

class FileModel extends FileEntity {
  const FileModel({
    required super.id,
    required super.fileName,
    required super.filePath,
    required super.fileType,
    super.mimeType,
    required super.fileSize,
    required super.createdAt,
    required super.updatedAt,
    super.geminiAnalysis,
    super.tags,
    super.description,
    super.thumbnailPath,
  });

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      id: map['id'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      fileType: map['file_type'] as String,
      mimeType: map['mime_type'] as String?,
      fileSize: map['file_size'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      geminiAnalysis: map['gemini_analysis'] as String?,
      tags: map['tags'] != null
          ? (map['tags'] as String).split(',').where((t) => t.isNotEmpty).toList()
          : null,
      description: map['description'] as String?,
      thumbnailPath: map['thumbnail_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'mime_type': mimeType,
      'file_size': fileSize,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'gemini_analysis': geminiAnalysis,
      'tags': tags?.join(','),
      'description': description,
      'thumbnail_path': thumbnailPath,
    };
  }

  factory FileModel.fromEntity(FileEntity entity) {
    return FileModel(
      id: entity.id,
      fileName: entity.fileName,
      filePath: entity.filePath,
      fileType: entity.fileType,
      mimeType: entity.mimeType,
      fileSize: entity.fileSize,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      geminiAnalysis: entity.geminiAnalysis,
      tags: entity.tags,
      description: entity.description,
      thumbnailPath: entity.thumbnailPath,
    );
  }
}
