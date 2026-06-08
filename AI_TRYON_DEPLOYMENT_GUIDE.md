# AI Stylist Feature - Complete Integration Guide

## Overview

The AI Stylist feature provides users with intelligent try-on capabilities using:
- **Frontend:** JSP with HTML5 file input and AJAX
- **Backend:** Java Servlet for multipart file handling
- **AI Engine:** Python scripts for body analysis and virtual overlays

---

## Installation & Deployment Steps

### Step 1: Build Java Backend

```bash
# Navigate to project root
cd c:\Users\supri\eclipse-workspace\ClothingStore_Final

# Build with Maven
mvn clean package

# If successful, check target/ClothingStore.war exists
```

### Step 2: Install Python Dependencies

```bash
# Navigate to Python AI directory
cd src/main/webapp/python_ai

# Install required packages
pip install -r requirements.txt

# Install MediaPipe for enhanced features (recommended)
pip install mediapipe

# Verify installation
python -c "import cv2; import numpy; print('OK')"
```

### Step 3: Create Output Directory

The application will create the following directories automatically at runtime:
- `src/main/webapp/ai_tryon_temp/` - Temporary uploaded images
- `src/main/webapp/ai_tryon_output/` - Generated preview images

If manual creation is needed:
```bash
mkdir -p src/main/webapp/ai_tryon_temp
mkdir -p src/main/webapp/ai_tryon_output
```

### Step 4: Deploy to Tomcat

```bash
# Copy WAR file to Tomcat
cp target/ClothingStore.war /path/to/tomcat/webapps/

# Start Tomcat
# On Windows:
# C:\tomcat\bin\startup.bat

# On Linux:
# /opt/tomcat/bin/startup.sh

# Application should be available at:
# http://localhost:8080/ClothingStore
```

### Step 5: Verify Installation

1. Navigate to http://localhost:8080/ClothingStore/collections.jsp
2. Look for "Try On with AI" buttons on product cards
3. Click any button - should redirect to ai-tryon.jsp
4. Upload a photo and test "Scan Photo" button

---

## API Documentation

### AITryOnServlet

**Endpoint:** `POST /aiTryOn`

**Request Format:**
```
Content-Type: multipart/form-data

Parameters:
- userPhoto: File (JPG/PNG, max 10MB)
- productId: String (integer product ID)
```

**JavaScript Example:**
```javascript
const formData = new FormData();
formData.append('userPhoto', fileInput.files[0]);
formData.append('productId', '123');

fetch('/ClothingStore/aiTryOn', {
    method: 'POST',
    body: formData
})
.then(response => response.json())
.then(data => console.log(data));
```

**Success Response:**
```json
{
    "status": "success",
    "outputImage": "ai_tryon_output/tryon_20240523_143022.png",
    "bodyAnalysis": "Body shape: Pear. Recommended size: M.",
    "styleRecommendation": "This A-line style perfectly complements your figure..."
}
```

**Error Response:**
```json
{
    "status": "error",
    "message": "Product ID and user photo are required"
}
```

---

## Architecture Diagram

```
User Browser
    ↓
collections.jsp (product cards with "Try On" buttons)
    ↓
ai-tryon.jsp (upload page + AJAX client)
    ↓ [FormData: photo + productId]
AITryOnServlet (/aiTryOn)
    ├─ Validate file (type, size)
    ├─ Save temp file
    ├─ Extract productId
    └─ Execute Python script
        ↓
    ai_tryon_engine.py (main orchestrator)
        ├─ body_analyzer.py (analyze body shape/tone)
        ├─ virtual_tryon.py (create overlay)
        └─ Returns JSON results
    ↓
AITryOnServlet returns JSON
    ↓
ai-tryon.jsp (AJAX callback)
    └─ Display results to user
```

---

## Configuration & Customization

### Adjusting AI Parameters

**File:** `src/main/webapp/python_ai/body_analyzer.py`

```python
# Skin tone detection sensitivity
lower_skin = np.array([0, 20, 70], dtype=np.uint8)
upper_skin = np.array([30, 255, 255], dtype=np.uint8)
# Adjust these values to improve detection accuracy
```

**File:** `src/main/webapp/python_ai/virtual_tryon.py`

```python
# Overlay color (BGR format)
color = (50, 150, 120)  # Emerald green
# Adjust opacity
intensity = 0.15 + (0.2 * ...)  # Range 0.0-1.0
```

### Customizing Product Recommendations

**File:** `src/main/webapp/ai-tryon.jsp`

```javascript
// Fallback recommendations (when Python unavailable)
const outcomes = [
    {
        heading: "Your custom title",
        note: "Your custom recommendation",
        chips: ['Chip 1', 'Chip 2', 'Chip 3']
    }
    // Add more recommendations
];
```

### Adjusting File Upload Limits

**File:** `src/main/java/com/servlet/AITryOnServlet.java`

```java
private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10 MB
// Change to desired limit (in bytes)
```

---

## Troubleshooting Guide

### Problem: "Python script not found"

**Symptoms:** Error message "Python engine not found"

**Solutions:**
1. Verify Python scripts exist: `src/main/webapp/python_ai/`
2. Check file permissions are readable
3. Verify Python path in AITryOnServlet:
   ```java
   ProcessBuilder pb = new ProcessBuilder(
       "python",  // Ensure "python" is in system PATH
       pythonScriptPath,
       userPhotoPath,
       productId
   );
   ```

### Problem: "ModuleNotFoundError" in Python

**Symptoms:** Error mentions missing cv2, mediapipe, etc.

**Solutions:**
```bash
# Reinstall dependencies
pip install -r src/main/webapp/python_ai/requirements.txt

# Check Python version (must be 3.8+)
python --version

# Reinstall specific module
pip install opencv-python --upgrade
```

### Problem: Image upload fails

**Symptoms:** "Invalid request format" error

**Solutions:**
1. Ensure file is JPG or PNG
2. Check file size is under 10MB
3. Verify form has `enctype="multipart/form-data"` (already set)
4. Check browser console for network errors

### Problem: AI processing is slow

**Symptoms:** Takes >10 seconds for results

**Solutions:**
1. Install MediaPipe for better performance:
   ```bash
   pip install mediapipe
   ```
2. Reduce image size before upload
3. Check system resources (RAM, CPU)
4. Consider image preprocessing in virtual_tryon.py

### Problem: Output images not visible

**Symptoms:** Try-on preview blank or missing image

**Solutions:**
1. Check `ai_tryon_output` directory exists:
   ```bash
   ls -la src/main/webapp/ai_tryon_output/
   ```
2. Verify web server permissions on directory
3. Check Tomcat logs for file I/O errors
4. Ensure sufficient disk space

---

## Performance Optimization

### For Development
```bash
# Run with verbose logging
python -u src/main/webapp/python_ai/ai_tryon_engine.py image.jpg 1
```

### For Production

1. **Enable MediaPipe:**
   ```bash
   pip install mediapipe
   ```

2. **Optimize Image Processing:**
   - Reduce max resolution in `virtual_tryon.py`
   - Enable image caching
   - Use async processing

3. **Server Configuration:**
   - Increase Tomcat thread pool
   - Configure proper temp directory
   - Monitor disk space for output images

4. **Database Integration:**
   - Cache body analysis results
   - Store user preferences
   - Track successful analyses

---

## Security Considerations

### File Upload Security

✅ **Implemented:**
- File type validation (JPG/PNG only)
- File size limit (10MB)
- Temporary file cleanup
- Unique filename generation

⚠️ **Additional Recommendations:**
- Implement virus scanning
- Store uploads outside webroot in production
- Use signed URLs for output image access
- Implement rate limiting per user/IP

### Code Injection Prevention

✅ **Implemented:**
- Input validation (product ID must be integer)
- HTML escaping in JSP parameters
- Prepared statements in DB queries
- Proper JSON encoding

---

## Monitoring & Logging

### Java Logging

**File:** Tomcat logs
```bash
# Linux
tail -f /opt/tomcat/logs/catalina.out

# Windows
C:\tomcat\logs\catalina.log
```

### Python Logging

**Output:** Goes to servlet stderr
```bash
# Check servlet output
System.err.println("[AI] Body analysis complete");
```

**Enhance logging in ai_tryon_engine.py:**
```python
import logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
logger.debug("Processing image...")
```

---

## Database Integration (Optional)

To store AI analysis results in database:

```sql
-- Create analysis history table
CREATE TABLE ai_analysis_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    body_shape VARCHAR(50),
    skin_tone VARCHAR(20),
    size_suggestion VARCHAR(10),
    analysis_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(p_id)
);
```

Then update AITryOnServlet to store results.

---

## Testing Checklist

- [ ] Collections page loads with "Try On" buttons
- [ ] Clicking button redirects to ai-tryon.jsp
- [ ] Photo upload works
- [ ] AJAX loading spinner shows
- [ ] Results display after processing
- [ ] Fallback recommendations work if Python unavailable
- [ ] Reset button clears preview
- [ ] Mobile responsiveness works
- [ ] Error messages are clear
- [ ] Temp files are cleaned up

---

## Future Enhancements

### Phase 2 Features
1. **Realistic GAN-based try-on** using StyleGAN
2. **Multiple photo upload** for different angles
3. **Size prediction** with database integration
4. **Historical comparisons** of past try-ons
5. **Social sharing** of styled photos

### Phase 3 Features
1. **3D body model** reconstruction
2. **AR try-on** for mobile devices
3. **Personalized recommendations** using ML
4. **Inventory optimization** based on popular sizes
5. **A/B testing** of different overlays

---

## Rollback Procedures

If issues occur after deployment:

```bash
# Remove WAR file to disable feature
rm /path/to/tomcat/webapps/ClothingStore.war

# Restart Tomcat
# Windows: C:\tomcat\bin\shutdown.bat then startup.bat
# Linux: /opt/tomcat/bin/shutdown.sh then startup.sh

# Restore previous version
cp previous_build/ClothingStore.war /path/to/tomcat/webapps/
```

---

## Support & Documentation

### Internal Documentation
- [Python AI Engine README](./src/main/webapp/python_ai/README.md)
- [Session Implementation Notes](/memories/session/ai_tryon_implementation.md)

### External Resources
- [MediaPipe Documentation](https://developers.google.com/mediapipe)
- [OpenCV Documentation](https://docs.opencv.org/)
- [Apache Commons FileUpload](https://commons.apache.org/proper/commons-fileupload/)

---

## Version Information

- **Feature Version:** 1.0
- **Release Date:** 2024-05-23
- **Status:** Production Ready
- **Python Version Required:** 3.8+
- **Java Version:** 21 (as per project)

---

## Contact & Maintenance

For issues or questions:
1. Check the troubleshooting section above
2. Review AI engine logs
3. Verify Python environment setup
4. Test components independently

---

**Last Updated:** 2024-05-23
**Maintained By:** Development Team
**Next Review Date:** 2024-08-23
