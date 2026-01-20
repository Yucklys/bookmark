# Knowledge Base App Implementation Plan

## Overview
Build a Flutter knowledge base app that allows users to save files locally and search them using natural language queries powered by Gemini AI.

## User Requirements
- **File Types**: Support all file types that Gemini AI can analyze (documents, images, videos, code, etc.)
- **Search**: Natural language search using Google Gemini AI
- **Storage**: Local device storage only (no cloud sync)
- **Platforms**: Desktop (Windows/macOS/Linux) and Mobile (Android/iOS)

## Architecture

### Clean Architecture with BLoC Pattern
```
lib/
├── core/                    # Shared utilities, constants, theme
├── data/                    # Data sources, models, repositories
│   ├── datasources/
│   │   ├── local/          # SQLite, file system
│   │   └── remote/         # Gemini API
│   ├── models/
│   ├── repositories/
│   └── database/
├── domain/                  # Business logic
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/            # UI layer
│   ├── bloc/
│   ├── pages/
│   └── widgets/
└── main.dart
```

## Implementation Phases

### Phase 1: Foundation & Setup ✅ COMPLETED
**Goal**: Establish project structure and core infrastructure

**Completed Tasks**:
1. ✅ Updated `pubspec.yaml` with all required dependencies
2. ✅ Created folder structure following Clean Architecture
3. ✅ Setup dependency injection (GetIt + Injectable)
4. ✅ Implemented SQLite database with schema
5. ✅ Built file storage service

**Files Created**:
- `lib/core/di/injection.dart` - Dependency injection setup
- `lib/core/constants/app_constants.dart` - App-wide constants
- `lib/core/errors/failures.dart` - Custom error types
- `lib/domain/entities/file_entity.dart` - File domain entity
- `lib/domain/entities/search_result_entity.dart` - Search result entity
- `lib/data/models/file_model.dart` - File data model
- `lib/data/database/app_database.dart` - SQLite database
- `lib/data/datasources/local/file_storage_service.dart` - File operations

### Phase 2: Gemini Integration
**Goal**: Connect to Gemini AI for file analysis and search

**Tasks**:
1. Build Gemini API client
   - Authentication with API key
   - File content analysis endpoint
   - Semantic search queries
   - Rate limiting and error handling
2. Implement repository pattern
   - GeminiRepository interface (domain layer)
   - GeminiRepositoryImpl (data layer)
3. Create use cases
   - AnalyzeFileWithGeminiUseCase
   - SearchWithGeminiUseCase
4. Settings page for API key management
   - Secure storage for API key
   - Validation

**Files to Create**:
- `lib/data/datasources/remote/gemini_api_client.dart` - API client
- `lib/domain/repositories/gemini_repository.dart` - Interface
- `lib/data/repositories/gemini_repository_impl.dart` - Implementation
- `lib/domain/usecases/analyze_file_usecase.dart` - File analysis
- `lib/domain/usecases/search_files_usecase.dart` - Search logic
- `lib/presentation/pages/settings_page.dart` - API key settings

### Phase 3: File Import & Management
**Goal**: Enable users to import and manage files

**Tasks**:
1. File picker integration
   - Multi-platform file selection
   - File validation (size, type)
2. Import workflow
   - Copy file to app directory
   - Extract metadata
   - Send to Gemini for analysis
   - Store in database
3. File list UI
   - Display all files with metadata
   - Grid/list view toggle
   - Sort and filter options
4. BLoC for state management
   - FileImportBloc (handle import flow)
   - FileListBloc (display files)

**Files to Create**:
- `lib/domain/usecases/import_file_usecase.dart` - Import business logic
- `lib/domain/usecases/get_all_files_usecase.dart` - File listing
- `lib/presentation/bloc/file_import/file_import_bloc.dart` - Import state
- `lib/presentation/bloc/file_list/file_list_bloc.dart` - List state
- `lib/presentation/pages/home_page.dart` - Main screen
- `lib/presentation/widgets/file_card.dart` - File display widget

### Phase 4: Search Functionality
**Goal**: Implement natural language search

**Tasks**:
1. Search UI
   - Search bar with voice input support
   - Recent searches
   - Search results display
2. Search BLoC
   - Query processing
   - Call Gemini for semantic search
   - Fallback to SQLite FTS when offline
   - Result ranking
3. Search caching
   - Cache frequent queries
   - Offline support

**Files to Create**:
- `lib/presentation/bloc/search/search_bloc.dart` - Search state management
- `lib/presentation/pages/search_page.dart` - Search UI
- `lib/presentation/widgets/search_bar_widget.dart` - Search input
- `lib/presentation/widgets/search_result_card.dart` - Result display

### Phase 5: File Preview & Details
**Goal**: View and interact with stored files

**Tasks**:
1. Multi-format file preview
   - PDF viewer
   - Image viewer (with zoom)
   - Markdown renderer
   - Video player
   - Code syntax highlighting
   - Generic file info for unsupported types
2. File details page
   - Metadata display
   - Gemini analysis results
   - Tags and description
   - Share/export options
3. File operations
   - Delete file
   - Edit metadata
   - Re-analyze with Gemini

**Files to Create**:
- `lib/presentation/pages/file_detail_page.dart` - Detail view
- `lib/presentation/widgets/file_preview/pdf_preview.dart`
- `lib/presentation/widgets/file_preview/image_preview.dart`
- `lib/presentation/widgets/file_preview/markdown_preview.dart`
- `lib/presentation/widgets/file_preview/video_preview.dart`
- `lib/presentation/widgets/file_preview/code_preview.dart`
- `lib/domain/usecases/delete_file_usecase.dart` - Delete logic
- `lib/presentation/bloc/file_detail/file_detail_bloc.dart` - Detail state

### Phase 6: Polish & Optimization
**Goal**: Improve UX and performance

**Tasks**:
1. Loading states and error handling
   - Shimmer effects
   - Empty states
   - Error messages
   - Retry mechanisms
2. Performance optimization
   - Lazy loading for file list
   - Image caching
   - Background file analysis
   - Database indexing
3. Offline mode
   - Graceful degradation when no internet
   - Queue Gemini requests for later
   - Show offline indicator
4. Theme and responsive design
   - Dark/light theme
   - Desktop vs mobile layouts
   - Accessibility

**Files to Create**:
- `lib/core/theme/app_theme.dart` - Theme configuration
- `lib/presentation/widgets/loading_shimmer.dart` - Loading states
- `lib/presentation/widgets/empty_state.dart` - Empty views
- `lib/core/utils/platform_utils.dart` - Platform detection

## Database Schema

```sql
CREATE TABLE files (
  id TEXT PRIMARY KEY,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_type TEXT NOT NULL,
  mime_type TEXT,
  file_size INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  gemini_analysis TEXT,
  tags TEXT,
  description TEXT,
  thumbnail_path TEXT
);

CREATE TABLE search_cache (
  id TEXT PRIMARY KEY,
  query TEXT NOT NULL,
  results TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

-- Indexes
CREATE INDEX idx_files_created_at ON files(created_at DESC);
CREATE INDEX idx_files_file_type ON files(file_type);
CREATE INDEX idx_files_tags ON files(tags);
```

## Key Technical Decisions

1. **BLoC for State Management**: Chosen for clear separation of concerns and excellent testing support
2. **SQLite with sqflite**: Industry standard, supports FTS5 for text search, cross-platform with sqflite_common_ffi
3. **Copy files to app directory**: Ensures reliable access and simplifies permissions
4. **Hybrid search**: Gemini for semantic search online, SQLite FTS offline
5. **Secure storage for API keys**: flutter_secure_storage for sensitive data

## Security Considerations

- Store Gemini API key in flutter_secure_storage
- Request minimal file permissions
- Sanitize file inputs and search queries
- All data stays local (privacy-first)

## Platform-Specific Notes

### Desktop
- Use sqflite_common_ffi for SQLite
- Larger screen responsive layouts
- Keyboard shortcuts
- Drag-and-drop file import (future enhancement)

### Mobile
- Handle storage permissions properly
- Mobile-optimized UI
- Share extension integration (future enhancement)

## Dependencies Added

### Production
- flutter_bloc: ^8.1.6 - State management
- equatable: ^2.0.5 - Value equality
- get_it: ^7.7.0 - Dependency injection
- injectable: ^2.4.2 - DI code generation
- sqflite: ^2.3.3 - SQLite database
- sqflite_common_ffi: ^2.3.3 - Desktop SQLite support
- path_provider: ^2.1.3 - File paths
- file_picker: ^8.0.0+1 - File selection
- mime: ^1.0.5 - MIME type detection
- google_generative_ai: ^0.4.3 - Gemini AI
- cached_network_image: ^3.3.1 - Image caching
- shimmer: ^3.0.0 - Loading animations
- flutter_pdfview: ^1.3.2 - PDF viewer
- photo_view: ^0.15.0 - Image viewer
- flutter_markdown: ^0.7.3 - Markdown renderer
- intl: ^0.19.0 - Internationalization
- uuid: ^4.4.2 - UUID generation
- permission_handler: ^11.3.1 - Permissions
- flutter_secure_storage: ^9.2.2 - Secure storage

### Development
- build_runner: ^2.4.11 - Code generation
- injectable_generator: ^2.6.1 - DI generation
- mockito: ^5.4.4 - Mocking for tests
- bloc_test: ^9.1.7 - BLoC testing

## Next Steps

Continue with Phase 2: Gemini Integration to implement AI-powered file analysis and semantic search capabilities.
