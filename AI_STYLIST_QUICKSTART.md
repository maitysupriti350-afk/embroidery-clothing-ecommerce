# AI Stylist Quick Start Guide

Get the AI Try-On feature running in 5 minutes!

## Quick Setup

### 1. Install Python Dependencies (1 min)

```bash
cd src/main/webapp/python_ai
pip install -r requirements.txt
pip install mediapipe  # Optional but recommended
```

### 2. Build & Deploy (2 min)

```bash
# From project root
mvn clean package

# Copy to Tomcat
cp target/ClothingStore.war /path/to/tomcat/webapps/

# Restart Tomcat
```

### 3. Test (2 min)

1. Open: http://localhost:8080/ClothingStore/collections.jsp
2. Find "Try On with AI" button on any product
3. Upload a photo → See results!

---

## What Works Now

✅ Body shape analysis (5 body types)
✅ Size recommendations  
✅ Skin tone detection
✅ Color suggestions
✅ AI preview generation
✅ Responsive mobile design
✅ Auto-fallback if Python unavailable

---

## File Locations

| Component | Location |
|-----------|----------|
| Java Servlet | `src/main/java/com/servlet/AITryOnServlet.java` |
| Try-On Page | `src/main/webapp/ai-tryon.jsp` |
| Products Page | `src/main/webapp/collections.jsp` |
| Python Engine | `src/main/webapp/python_ai/` |
| Output Images | `src/main/webapp/ai_tryon_output/` |

---

## Customization

### Change Overlay Color
File: `src/main/webapp/python_ai/virtual_tryon.py`
```python
color = (50, 150, 120)  # BGR format (emerald green)
```

### Adjust Upload Size Limit  
File: `src/main/java/com/servlet/AITryOnServlet.java`
```java
private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10 MB
```

### Customize Recommendations
File: `src/main/webapp/ai-tryon.jsp` (see `displayFallbackResults()`)

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Python not found | Ensure Python is in system PATH |
| Upload fails | Check file is JPG/PNG, under 10MB |
| Slow processing | Install MediaPipe: `pip install mediapipe` |
| No output image | Check `ai_tryon_output` directory exists |
| Blank results | Check browser console for errors |

---

## Key Features

### On Collections Page
```jsp
<button class="add-btn tryon-btn" onclick="window.location.href='<%= tryOnUrl %>'">
    <i class="fas fa-magic"></i> Try On with AI
</button>
```

### AJAX Processing
```javascript
fetch('${pageContext.request.contextPath}/aiTryOn', {
    method: 'POST',
    body: formData
}).then(response => response.json())
  .then(data => displayResults(data));
```

### Python Analysis
```python
# Body Shape: apple, pear, hourglass, rectangle, inverted_triangle
# Size: XS, S, M, L, XL
# Tone: warm or cool
# Colors: complementary color suggestions
```

---

## Next Steps

1. ✅ Basic feature working
2. → Consider adding database logging (see deployment guide)
3. → Monitor Python performance
4. → Add analytics tracking
5. → Implement caching for common body types
6. → Plan GAN-based enhancements for Phase 2

---

**Need help?** See `AI_TRYON_DEPLOYMENT_GUIDE.md` for detailed docs.

---

*Created: 2024-05-23 | Status: Production Ready*
