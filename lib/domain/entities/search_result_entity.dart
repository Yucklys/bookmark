import 'package:equatable/equatable.dart';
import 'file_entity.dart';

class SearchResultEntity extends Equatable {
  final FileEntity file;
  final double relevanceScore;
  final String? matchedSnippet;

  const SearchResultEntity({
    required this.file,
    required this.relevanceScore,
    this.matchedSnippet,
  });

  @override
  List<Object?> get props => [file, relevanceScore, matchedSnippet];
}
