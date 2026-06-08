# AI Stylist Feature - Complete User Flow & Architecture

## User Journey Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         Collections Page                          │
│  User browses products in collections.jsp                        │
│  Each product shows:                                             │
│  - Image                                                         │
│  - Price                                                         │
│  - "Add to Cart" button                                          │
│  - "Try On with AI" button ← NEW FEATURE                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    User clicks "Try On with AI"
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    AI Try-On Page (ai-tryon.jsp)                 │
│                                                                  │
│  Header Section:                                                │
│  - Badge: "Premium AI Fit"                                      │
│  - Title: "Try your chosen dress on your own photo"            │
│  - Features list                                                │
│                                                                  │
│  Left Panel (Info):                                             │
│  - Back to Collections link                                     │
│                                                                  │
│  Right Panel (Interactive):                                     │
│  ┌─────────────────────────────────────────────────┐           │
│  │  Selected Dress:                                │           │
│  │  [Product Image] [Product Name]                │           │
│  │                                                 │           │
│  │  📤 Upload Your Photo                          │           │
│  │  ┌─────────────────────────────────────────┐  │           │
│  │  │  [Click to upload or drag photo]        │  │           │
│  │  └─────────────────────────────────────────┘  │           │
│  │                                                 │           │
│  │  Status: Ready for preview                     │           │
│  │                                                 │           │
│  │  [🔍 Scan Photo] [↻ Reset]                    │           │
│  └─────────────────────────────────────────────────┘           │
│                                                                  │
│  Preview Canvas (Initially Empty):                              │
│  ┌─────────────────────────────────────────────┐              │
│  │                                               │              │
│  │  Uploaded photo with dress overlay will     │              │
│  │  appear here                                │              │
│  │                                               │              │
│  └─────────────────────────────────────────────┘              │
│                                                                  │
│  Results Section:                                              │
│  ┌─────────────────────────────────────────────┐              │
│  │  How it works...                            │              │
│  └─────────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    User uploads photo
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Photo Displays in Preview                      │
│  - Photo shows in preview canvas                                │
│  - Product overlay becomes visible                              │
│  - Status updates                                               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                  User clicks "Scan Photo"
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│               AJAX Request to Backend                            │
│                                                                  │
│  FormData contains:                                             │
│  - userPhoto: [image file]                                     │
│  - productId: [product id]                                     │
│                                                                  │
│  Shows loading spinner: "Analyzing your photo..."              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    AITryOnServlet
                   (/aiTryOn endpoint)
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  1. Validate Request                                            │
│     ✓ Check multipart format                                   │
│     ✓ Extract userPhoto file                                   │
│     ✓ Extract productId                                        │
│                                                                  │
│  2. Validate File                                              │
│     ✓ Check file type (JPG/PNG)                               │
│     ✓ Check file size (<10MB)                                 │
│                                                                  │
│  3. Save Temporary File                                        │
│     ✓ Generate unique filename                                 │
│     ✓ Save to ai_tryon_temp/                                  │
│                                                                  │
│  4. Validate Product ID                                        │
│     ✓ Must be valid integer                                   │
│                                                                  │
│  5. Call Python AI Engine                                      │
│     ProcessBuilder → ai_tryon_engine.py                        │
│     Args: [image_path, product_id]                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
           Python AI Processing (ai_tryon_engine.py)
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  1. Import Modules                                              │
│     from body_analyzer import analyze_body_shape               │
│     from virtual_tryon import create_virtual_overlay           │
│                                                                  │
│  2. Call Body Analyzer                                         │
│     analyze_body_shape(image_path)                             │
│     Returns: {                                                 │
│         "shape": "pear",                                       │
│         "size_suggestion": "M",                                │
│         "tone": "warm",                                        │
│         "colors": ["emerald", "gold"]                          │
│     }                                                           │
│                                                                  │
│  3. Call Virtual Try-On                                        │
│     create_virtual_overlay(image_path, product_id, analysis)   │
│     Returns: {                                                 │
│         "output_path": "ai_tryon_output/tryon_xxx.png"        │
│         "status": "success"                                    │
│     }                                                           │
│                                                                  │
│  4. Generate Recommendations                                   │
│     Based on body shape and tone:                              │
│     "This A-line style perfectly complements..."              │
│                                                                  │
│  5. Return JSON Result                                         │
│     {                                                          │
│         "status": "success",                                   │
│         "body_analysis": "...",                               │
│         "style_recommendation": "...",                         │
│         "output_image": "...",                                 │
│         "colors_match": ["emerald", "gold"],                   │
│         "size_suggestion": "M"                                 │
│     }                                                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
              Body Analyzer (body_analyzer.py)
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  1. Load Image with OpenCV                                      │
│     cv2.imread(image_path)                                      │
│                                                                  │
│  2. Try MediaPipe (if available)                               │
│     ┌──────────────────────────────────────┐                 │
│     │ WITH MediaPipe (Advanced):           │                 │
│     │ - Detect pose landmarks               │                 │
│     │ - Extract shoulder/hip points        │                 │
│     │ - Calculate proportions               │                 │
│     │ - Classify body shape                 │                 │
│     │ - Extract pose segmentation           │                 │
│     └──────────────────────────────────────┘                 │
│                    OR                                           │
│     ┌──────────────────────────────────────┐                 │
│     │ FALLBACK (OpenCV):                   │                 │
│     │ - Detect skin regions                 │                 │
│     │ - Find body contours                  │                 │
│     │ - Estimate proportions                │                 │
│     │ - Basic shape classification          │                 │
│     └──────────────────────────────────────┘                 │
│                                                                  │
│  3. Analyze Skin Tone                                          │
│     - Convert to HSV color space                               │
│     - Detect skin pixels                                       │
│     - Calculate average color                                  │
│     - Classify as warm or cool                                 │
│                                                                  │
│  4. Recommend Colors                                           │
│     if tone == "warm": colors = ["emerald", "gold", ...]      │
│     if tone == "cool": colors = ["sapphire", "silver", ...]   │
│                                                                  │
│  5. Suggest Size                                               │
│     Based on shoulder width proportions:                       │
│     XS, S, M, L, XL                                           │
│                                                                  │
│  6. Return Analysis Results                                    │
│     Dictionary with all metrics                                │
└─────────────────────────────────────────────────────────────────┘
                              ↓
           Virtual Try-On (virtual_tryon.py)
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  1. Load User Image                                             │
│     cv2.imread(user_image_path)                                │
│                                                                  │
│  2. Create Visualization                                       │
│     Based on body shape, create overlay:                       │
│     - Create semi-transparent color overlay                    │
│     - Apply gradient based on body shape                       │
│     - Blend with original image                                │
│     - Add decorative frame                                     │
│     - Add text annotation                                      │
│                                                                  │
│  3. Enhance Image Quality                                      │
│     - Slight sharpening filter                                 │
│     - Denoising                                                │
│                                                                  │
│  4. Save Output Image                                          │
│     - Create ai_tryon_output directory if needed               │
│     - Generate unique filename with timestamp                  │
│     - Save as PNG                                              │
│     - Return relative path                                     │
│                                                                  │
│  5. Clean Up Temporary File                                    │
│     - Delete uploaded temp file                                │
│                                                                  │
│  6. Return Output Path                                         │
│     "ai_tryon_output/tryon_20240523_143022.png"               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
        AITryOnServlet Returns JSON Response
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Response JSON:                                                 │
│  {                                                              │
│    "status": "success",                                         │
│    "outputImage": "ai_tryon_output/tryon_xxx.png",             │
│    "bodyAnalysis": "Body shape: Pear. Size: M",               │
│    "styleRecommendation": "This A-line style...",             │
│    "colorsMatch": ["emerald", "gold"],                        │
│    "sizeSuggestion": "M"                                       │
│  }                                                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
        AJAX Success Callback in ai-tryon.jsp
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  1. Hide Loading Spinner                                        │
│     Status: "AI analysis complete!"                             │
│                                                                  │
│  2. Display Results                                            │
│     ┌─────────────────────────────────────┐                   │
│     │ Result Card:                        │                   │
│     │                                     │                   │
│     │ 🔍 Body Analysis & Fit              │                   │
│     │ Body shape: Pear. Recommended...    │                   │
│     │                                     │                   │
│     │ 🎨 Style Recommendation             │                   │
│     │ This dress perfectly complements... │                   │
│     │                                     │                   │
│     │ ✨ AI-Generated Try-On             │                   │
│     │ [Overlay image preview]             │                   │
│     └─────────────────────────────────────┘                   │
│                                                                  │
│  3. Display Color Chips                                        │
│     ✓ Color 1: Emerald                                        │
│     ✓ Color 2: Gold                                           │
│     ✓ Color 3: ...                                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
           ✅ User Sees Complete AI Analysis!
```

---

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                    USER BROWSER (Frontend)                        │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ collections.jsp                                          │  │
│  │ - Product grid with "Try On with AI" buttons            │  │
│  │ - Links to ai-tryon.jsp?prodName=...&img=...&pid=...   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ↓                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ ai-tryon.jsp (JSP Page)                                  │  │
│  │ ┌────────────────────────────────────────────────────┐   │  │
│  │ │ JavaScript:                                        │   │  │
│  │ │ - File input handling                             │   │  │
│  │ │ - Photo preview display                           │   │  │
│  │ │ - AJAX FormData creation                          │   │  │
│  │ │ - Fetch request to /aiTryOn                       │   │  │
│  │ │ - Results rendering                              │   │  │
│  │ │ - Error handling & fallback                       │   │  │
│  │ └────────────────────────────────────────────────────┘   │  │
│  │                                                           │  │
│  │ HTML Elements:                                          │  │
│  │ - File input: #userPhotoInput                          │  │
│  │ - Photo preview: #userPhoto img                        │  │
│  │ - Status: #previewStatus div                           │  │
│  │ - Results: #aiResults div                              │  │
│  │ - Buttons: Scan Photo, Reset                           │  │
│  └──────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
                           ↓ HTTP POST
                    Content-Type: multipart/form-data
                    [userPhoto file + productId]
                           ↓
┌──────────────────────────────────────────────────────────────────┐
│                   JAVA BACKEND (Servlet)                          │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ AITryOnServlet.java                                      │  │
│  │ @WebServlet("/aiTryOn")                                  │  │
│  │                                                           │  │
│  │ doPost() Method:                                         │  │
│  │ 1. Check if multipart content                          │  │
│  │ 2. Parse form fields & files                           │  │
│  │ 3. Validate file (type, size)                          │  │
│  │ 4. Save temporary file                                 │  │
│  │ 5. Extract product ID                                  │  │
│  │ 6. Call Python script via ProcessBuilder               │  │
│  │    ProcessBuilder pb = new ProcessBuilder(             │  │
│  │        "python",                                        │  │
│  │        "python_ai/ai_tryon_engine.py",                 │  │
│  │        tempFilePath,                                    │  │
│  │        productId                                        │  │
│  │    );                                                   │  │
│  │ 7. Capture Python output                               │  │
│  │ 8. Parse JSON response                                 │  │
│  │ 9. Return JSON to browser                              │  │
│  │ 10. Clean up temporary files                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
│  Dependencies:                                                   │
│  - org.apache.commons.fileupload                                │
│  - org.apache.commons.io                                        │
│  - com.google.gson                                              │
└──────────────────────────────────────────────────────────────────┘
                           ↓ Subprocess
                    ProcessBuilder calls Python
                           ↓
┌──────────────────────────────────────────────────────────────────┐
│              PYTHON AI ENGINE (Subprocess)                        │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ ai_tryon_engine.py (Main Orchestrator)                   │  │
│  │                                                           │  │
│  │ process_try_on(image_path, product_id):                 │  │
│  │ 1. Import analysis modules                             │  │
│  │ 2. Call analyze_body_shape()                           │  │
│  │ 3. Call create_virtual_overlay()                       │  │
│  │ 4. Generate style recommendations                      │  │
│  │ 5. Return JSON (stdout)                                │  │
│  └──────────────────────────────────────────────────────────┘  │
│          ↙                                          ↘            │
│  ┌─────────────────────────┐        ┌──────────────────────────┐│
│  │ body_analyzer.py        │        │ virtual_tryon.py         ││
│  │                         │        │                          ││
│  │ analyze_body_shape():   │        │ create_virtual_overlay():││
│  │ - Load image            │        │ - Load user image        ││
│  │ - MediaPipe detection   │        │ - Create color overlay   ││
│  │   (or fallback OpenCV)  │        │ - Apply gradient effect  ││
│  │ - Measure proportions   │        │ - Blend images           ││
│  │ - Classify body shape   │        │ - Save output PNG        ││
│  │ - Analyze skin tone     │        │ - Return path            ││
│  │ - Suggest colors        │        │                          ││
│  │ - Suggest size          │        │ Dependencies:            ││
│  │                         │        │ - OpenCV                 ││
│  │ Dependencies:           │        │ - NumPy                  ││
│  │ - OpenCV                │        │ - datetime               ││
│  │ - NumPy                 │        │ - pathlib                ││
│  │ - MediaPipe (optional)  │        │                          ││
│  └─────────────────────────┘        └──────────────────────────┘│
│          ↓                                          ↓             │
│     Returns:                                  Returns:           │
│     {                                         {                  │
│       "shape": "pear",                          "output_path":   │
│       "tone": "warm",                           "tryon_xxx.png", │
│       "colors": [...],                          "status": "ok"   │
│       "size": "M",                            }                  │
│       ...                                                        │
│     }                                                            │
└──────────────────────────────────────────────────────────────────┘
                           ↑
                    STDOUT (JSON String)
                           ↑
┌──────────────────────────────────────────────────────────────────┐
│              JAVA BACKEND (Servlet Response)                      │
│                                                                   │
│  Parse JSON from Python stdout                                   │
│  Build response:                                                 │
│  {                                                               │
│    "status": "success",                                          │
│    "outputImage": "ai_tryon_output/tryon_xxx.png",              │
│    "bodyAnalysis": "...",                                        │
│    "styleRecommendation": "...",                                │
│    "colorsMatch": [...],                                        │
│    "sizeSuggestion": "M"                                        │
│  }                                                               │
│                                                                   │
│  response.setContentType("application/json")                     │
│  response.getWriter().println(jsonString)                        │
└──────────────────────────────────────────────────────────────────┘
                           ↓ HTTP Response
                       JSON over HTTPS
                           ↓
┌──────────────────────────────────────────────────────────────────┐
│                    USER BROWSER (Frontend)                        │
│                                                                   │
│  AJAX Success Callback:                                          │
│  - Parse JSON response                                           │
│  - Update DOM with results                                       │
│  - Display body analysis                                         │
│  - Display style recommendations                                 │
│  - Display try-on image                                          │
│  - Show color suggestions                                        │
│  - User sees complete AI analysis!                               │
└──────────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
ClothingStore_Final/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── servlet/
│       │           └── AITryOnServlet.java ⭐ NEW
│       │
│       └── webapp/
│           ├── ai-tryon.jsp ⭐ UPDATED
│           ├── collections.jsp ⭐ UPDATED
│           │
│           ├── python_ai/ ⭐ NEW DIRECTORY
│           │   ├── ai_tryon_engine.py
│           │   ├── body_analyzer.py
│           │   ├── virtual_tryon.py
│           │   ├── __init__.py
│           │   ├── requirements.txt
│           │   └── README.md
│           │
│           ├── ai_tryon_temp/ (created at runtime)
│           └── ai_tryon_output/ (created at runtime)
│
├── pom.xml ⭐ UPDATED (added dependencies)
├── AI_TRYON_DEPLOYMENT_GUIDE.md ⭐ NEW
├── AI_STYLIST_QUICKSTART.md ⭐ NEW
└── IMPLEMENTATION_SUMMARY.md ⭐ NEW

⭐ = New or Modified files
```

---

## Data Flow Summary

| Step | Component | Input | Processing | Output |
|------|-----------|-------|-----------|--------|
| 1 | Browser | None | User clicks Try On button | Redirect to ai-tryon.jsp |
| 2 | ai-tryon.jsp | Product info | Display upload UI | File upload ready |
| 3 | JavaScript | Photo file | Validate & preview photo | Photo displayed locally |
| 4 | JavaScript/AJAX | FormData | Send POST request | HTTP POST to /aiTryOn |
| 5 | AITryOnServlet | Multipart request | Parse & validate | Save temp file |
| 6 | ProcessBuilder | File path + ID | Call Python script | Run Python subprocess |
| 7 | body_analyzer.py | Image | Detect body metrics | Body analysis JSON |
| 8 | virtual_tryon.py | Image + analysis | Create overlay | Output image path |
| 9 | ai_tryon_engine.py | Analysis results | Combine data | JSON response |
| 10 | AITryOnServlet | Python stdout | Parse JSON | HTTP response |
| 11 | AJAX callback | Response JSON | Update DOM | Display results |
| 12 | Browser | Results | Render UI | User sees analysis! |

---

**End of Complete Flow Documentation**
