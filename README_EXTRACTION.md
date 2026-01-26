# Image Object Extraction Feature

This feature automatically extracts objects from images using Google's Gemini AI.

## What It Does

- Analyzes images in `lib/data/image/` directory
- Detects and extracts individual objects (books, laptop, camera, phone, mouse, tools, cups, stationery, etc.)
- Saves each object as a separate PNG file
- Generates metadata with bounding boxes and object information

## Setup

1. Create a configuration file at `GetImage/.env.local`:
```
API_KEY=your_gemini_api_key_here
```

2. Place your test images in `lib/data/image/` directory

## Usage

### Automatic Mode (Recommended)
Automatically loads API key from config and uses default test image:
```bash
dart run test_extraction_simple.dart
```

### Specify Image
Use a specific image while auto-loading API key:
```bash
dart run test_extraction_simple.dart lib/data/image/your_image.jpg
```

### Manual Mode
Specify both image and API key:
```bash
dart run test_extraction_simple.dart lib/data/image/test1.jpg YOUR_API_KEY
```

## Expected Output

```
🚀 Image Object Extraction Test (Simplified)

🔧 Loading settings from config file...

✅ Configuration loaded successfully
📸 Image: lib/data/image/test1.jpg
🔑 API Key: AIzaSyBxxx...

⚙️  Initializing services...
✅ Services initialized successfully

📁 Output directory: ./test_outputs

🔍 Starting object extraction...

============================================================
📸 Loading image: lib/data/image/test1.jpg
📐 Image size: 1920×1080

🔍 Analyzing image with Gemini Flash...

🎯 Found 15 potential objects

🔧 After filtering: 12 objects (min 1.0% area)

💾 Extracting objects...

  ✓ item_0.png - 450×380 (15.82%)
  ✓ item_1.png - 380×320 (11.26%)
  ✓ item_2.png - 320×280 (8.30%)
  ✓ item_3.png - 280×240 (6.22%)
  ✓ item_4.png - 240×200 (4.44%)
  ✓ item_5.png - 200×180 (3.33%)
  ✓ item_6.png - 180×160 (2.67%)
  ✓ item_7.png - 160×140 (2.07%)
  ✓ item_8.png - 140×120 (1.56%)
  ✓ item_9.png - 120×100 (1.11%)
  ✓ item_10.png - 110×95 (0.97%)
  ✓ item_11.png - 105×90 (0.88%)

📦 Metadata saved to: meta.json

✅ Extraction complete! 12 objects saved to ./test_outputs/

============================================================

✅ Extraction completed!

📊 Extraction statistics:
  - Source image: test1.jpg
  - Size: 1920 × 1080
  - Total objects: 12

📦 Extracted objects list:

  item_0:
    File: item_0.png
    Size: 450 × 380
    Position: (100, 50)
    Area ratio: 15.82%

  item_1:
    File: item_1.png
    Size: 380 × 320
    Position: (600, 120)
    Area ratio: 11.26%

  ...

💾 All files saved to: ./test_outputs/
   - 12 PNG files
   - 1 meta.json metadata file

🎉 Test successful!
```

## Output Files

After extraction, you'll find in `./test_outputs/`:
- `item_0.png`, `item_1.png`, ... - Individual extracted objects
- `meta.json` - Metadata containing bounding boxes, sizes, and area ratios

## Features

- **Smart Object Detection**: Uses Gemini 2.5 Flash AI model
- **Automatic Filtering**: Only extracts objects > 1% of image area
- **Size Sorting**: Objects sorted by area (largest first)
- **Maximum Objects**: Extracts up to 12 objects per image
- **Metadata Export**: Complete JSON metadata with coordinates

## Requirements

- Dart SDK (included with Flutter)
- Gemini API key
- Images in supported formats (JPEG, PNG, etc.)
