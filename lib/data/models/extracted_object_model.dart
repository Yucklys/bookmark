import 'package:equatable/equatable.dart';

/// Extracted object model
class ExtractedObjectModel extends Equatable {
  final String id;
  final String filename;
  final List<int> bbox; // [x, y, width, height] in pixels
  final int width;
  final int height;
  final double areaRatio;

  const ExtractedObjectModel({
    required this.id,
    required this.filename,
    required this.bbox,
    required this.width,
    required this.height,
    required this.areaRatio,
  });

  factory ExtractedObjectModel.fromJson(Map<String, dynamic> json) {
    return ExtractedObjectModel(
      id: json['id'] as String,
      filename: json['filename'] as String,
      bbox: (json['bbox'] as List<dynamic>).map((e) => e as int).toList(),
      width: json['width'] as int,
      height: json['height'] as int,
      areaRatio: (json['area_ratio'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'bbox': bbox,
      'width': width,
      'height': height,
      'area_ratio': areaRatio,
    };
  }

  @override
  List<Object?> get props => [id, filename, bbox, width, height, areaRatio];
}

/// Extraction metadata
class ExtractionMetadata extends Equatable {
  final String sourceImage;
  final List<int> imageSize; // [width, height]
  final int totalObjects;
  final List<ExtractedObjectModel> items;

  const ExtractionMetadata({
    required this.sourceImage,
    required this.imageSize,
    required this.totalObjects,
    required this.items,
  });

  factory ExtractionMetadata.fromJson(Map<String, dynamic> json) {
    return ExtractionMetadata(
      sourceImage: json['source_image'] as String,
      imageSize: (json['image_size'] as List<dynamic>).map((e) => e as int).toList(),
      totalObjects: json['total_objects'] as int,
      items: (json['items'] as List<dynamic>)
          .map((item) => ExtractedObjectModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source_image': sourceImage,
      'image_size': imageSize,
      'total_objects': totalObjects,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [sourceImage, imageSize, totalObjects, items];
}
