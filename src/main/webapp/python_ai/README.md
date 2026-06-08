# AI Try-On Engine Setup Guide

This directory contains the Python AI backend for the virtual try-on feature in the Clothing Store application.

## Architecture

```
python_ai/
├── ai_tryon_engine.py      # Main orchestrator
├── body_analyzer.py         # Body shape & skin tone analysis
├── virtual_tryon.py         # Virtual overlay creation
├── requirements.txt         # Python dependencies
└── README.md               # This file
```

## Features

1. **Body Shape Analysis**
   - Detects body proportions using MediaPipe pose detection
   - Classifies body type (pear, apple, hourglass, rectangle, inverted triangle)
   - Generates size recommendations

2. **Skin Tone Analysis**
   - Analyzes skin tone (warm/cool)
   - Recommends complementary colors

3. **Virtual Try-On**
   - Creates realistic overlays of clothing on user photos
   - Uses body landmarks for accurate positioning
   - Generates styled preview images

## Installation

### Prerequisites
- Python 3.8 or higher
- pip (Python package manager)

### Step 1: Install Core Dependencies

```bash
# Navigate to this directory
cd src/main/webapp/python_ai

# Install required packages
pip install -r requirements.txt
```

### Step 2: Install Optional MediaPipe (Recommended)

MediaPipe provides advanced pose detection for more accurate body analysis:

```bash
pip install mediapipe
```

### Step 3: Verify Installation

```bash
python -c "import cv2; import numpy; print('Core dependencies OK')"
```

If MediaPipe is installed:
```bash
python -c "import mediapipe; print('MediaPipe OK')"
```

## Configuration

### Environment Variables

Create a `.env` file in the python_ai directory if needed:

```
OPENCV_ENABLED=true
MEDIAPIPE_ENABLED=true
DEBUG_MODE=false
```

## Usage

### From Java Servlet

The AITryOnServlet automatically calls the Python engine:

```java
ProcessBuilder pb = new ProcessBuilder(
    "python",
    "python_ai/ai_tryon_engine.py",
    userImagePath,
    productId
);
```

### Direct Python Usage

```python
from ai_tryon_engine import process_try_on

result = process_try_on("/path/to/image.jpg", "product_id")
print(result)
```

## Output

The engine returns a JSON response:

```json
{
    "status": "success",
    "body_analysis": "Analysis summary",
    "style_recommendation": "Personalized recommendation",
    "output_image": "path/to/output.png",
    "colors_match": ["emerald", "gold"],
    "size_suggestion": "M",
    "message": "AI analysis complete!"
}
```

## Troubleshooting

### Issue: "ModuleNotFoundError: No module named 'cv2'"

**Solution:**
```bash
pip install opencv-python
```

### Issue: "ModuleNotFoundError: No module named 'mediapipe'"

**Solution:** MediaPipe is optional. The system will fall back to basic analysis:
```bash
pip install mediapipe
```

### Issue: Python script not found from Java

**Solution:** Ensure Python is in system PATH:
```bash
# Check Python installation
python --version

# On Windows, add Python to PATH:
# Control Panel > System > Advanced Settings > Environment Variables > PATH
```

### Issue: Image processing fails

**Solutions:**
1. Ensure image file exists and is readable
2. Check image format (JPEG, PNG supported)
3. Verify image dimensions (not too large/small)
4. Check system memory availability

## Performance Optimization

### For Production Deployment

1. **Use MediaPipe** for better accuracy
2. **Image Caching** - Store processed images
3. **Batch Processing** - Process multiple images in parallel
4. **Model Optimization** - Use quantized models for faster inference

### Recommended System Requirements

- **CPU:** Intel Core i5 or equivalent
- **RAM:** 4GB minimum, 8GB recommended
- **Storage:** 500MB for dependencies
- **Network:** For image upload handling

## Advanced Features (Future Enhancements)

### 1. GAN-Based Try-On
Use StyleGAN or similar for more realistic overlays:
```bash
pip install torch torchvision
```

### 2. Size Recommendation Engine
Integrate with product database:
```bash
pip install sqlalchemy mysql-connector-python
```

### 3. Color Matching Algorithm
Advanced color science:
```bash
pip install scikit-learn colorsys
```

## Development Notes

## Hosted Inference (Hugging Face) - Recommended for realistic try-on

If you don't have a GPU on the server, use Hugging Face Inference API to run a hosted image-to-image / inpainting model. Follow these steps:

1. Create a Hugging Face account and obtain an API token: https://huggingface.co/settings/tokens
2. Choose a model for inpainting or image-to-image (example: `stabilityai/stable-diffusion-2-inpainting`).
3. Set environment variables so Tomcat/Python can access the token and model. Recommended (Tomcat): create `%CATALINA_HOME%\bin\setenv.bat` with:

```bat
@echo off
set "HF_API_TOKEN=hf_your_token_here"
set "HF_MODEL=stabilityai/stable-diffusion-2-inpainting"
```

4. Restart Tomcat so environment variables are visible to the webapp.

5. Verify from the running app by visiting the diagnostic servlet:

```
http://<host>:<port>/<your-app-context>/envCheck
```

The servlet will return JSON showing whether `HF_API_TOKEN` and `HF_MODEL` are set and whether `product_img/` exists.

6. Test the hosted inference wrapper manually (from the server shell):

```bash
cd src/main/webapp/python_ai
python ai_tryon_inference.py /full/path/to/user.jpg /full/path/to/product.png
```

The script prints a single JSON object to stdout with `status` and `output_image` on success.

Security notes: never check tokens into source control. Use machine-level env vars or `setenv.bat` for Tomcat.


### Adding Custom Body Analysis

1. Update `body_analyzer.py`
2. Add new classification logic
3. Update `classify_body_shape()` function
4. Test with various body types

### Improving Try-On Accuracy

1. Enhance `create_overlay_visualization()` in `virtual_tryon.py`
2. Use more sophisticated pose landmarks
3. Implement cloth-specific placement logic
4. Add texture and lighting corrections

## API Documentation

### `process_try_on(image_path, product_id)`

**Parameters:**
- `image_path` (str): Full path to uploaded image
- `product_id` (str): Product identifier from database

**Returns:**
- Dictionary with analysis results or error

### `analyze_body_shape(image_path)`

**Parameters:**
- `image_path` (str): Path to body photo

**Returns:**
- Dictionary with body metrics and classification

### `create_virtual_overlay(user_image_path, product_id, body_analysis)`

**Parameters:**
- `user_image_path` (str): User photo path
- `product_id` (str): Product ID
- `body_analysis` (dict): Results from body_analyzer

**Returns:**
- Dictionary with output image path

## License

This AI Try-On Engine is part of The Heritage Gallery Clothing Store application.

## Support

For issues or feature requests:
1. Check the troubleshooting section above
2. Review Java servlet logs for error messages
3. Test Python scripts independently:
   ```bash
   python ai_tryon_engine.py /path/to/image.jpg product_id
   ```

## Version History

- v1.0 (Current)
  - Basic body shape analysis
  - Skin tone detection
  - Virtual overlay generation
  - Size recommendations
  - Style guidance

---

**Last Updated:** 2024-05-23
**Status:** Production Ready with Optional Enhancements
