# AI Try-On Feature - Quick Start Verification Checklist

## Before You Test

### 1. Install Python (Required)
- [ ] Download Python 3.8+ from https://www.python.org/downloads/
- [ ] During installation, CHECK the box: "Add Python to PATH"
- [ ] Complete installation
- [ ] Verify: Open Command Prompt and run `python --version`
  - Should show: `Python 3.8.x` or higher
  - If error, restart computer and try again

### 2. Install Dependencies
- [ ] Open Command Prompt in project root directory
- [ ] Run: `pip install -r src/main/webapp/python_ai/requirements.txt`
- [ ] Wait for installation to complete
- [ ] Verify: Run `python -c "import cv2; print('OpenCV ready')"`
  - Should display: `OpenCV ready`

### 3. Restart Web Server
- [ ] Stop Tomcat/Web Server
- [ ] Wait 5 seconds
- [ ] Start Tomcat/Web Server again
- [ ] Wait for startup to complete

## Testing the Feature

### Step 1: Navigate to Collections
- [ ] Go to: `http://localhost:8080/ClothingStore_Final/collections.jsp`
- [ ] See the green "Start AI Fit Preview" banner at the top

### Step 2: Select a Product
- [ ] Browse products on the page
- [ ] Click "Try On with AI" button on any product
- [ ] Should see product image in the preview card

### Step 3: Upload Photo
- [ ] Click "Upload your photo to see the dress on you"
- [ ] Select a clear photo of yourself (face + body visible)
- [ ] Accepted formats: JPG, PNG
- [ ] File size should be under 10MB

### Step 4: Run Analysis
- [ ] Click the blue "Scan Photo" button
- [ ] Wait for processing (should take 10-30 seconds)
- [ ] You should see:
  - [ ] Your uploaded photo appears
  - [ ] Dress overlay appears on your torso
  - [ ] Status changes to "AI analysis complete!"
  - [ ] Styling recommendations appear below

### Step 5: Review Results
- [ ] Check the dress color on your photo
- [ ] Read the body analysis
- [ ] Read the style recommendation
- [ ] Verify recommendations match your body type

## Expected Results

### Success Indicators ✅
1. **Photo uploads without error**
2. **Processing shows "Analyzing your photo..." message**
3. **Dress appears on your body in the photo**
4. **Recommendations display correctly**
5. **No Python errors in browser console**

### Output Example
```
Body Analysis & Fit:
"Pear-shaped figure analysis complete. The dress emphasizes your 
proportions beautifully..."

Style Recommendation:
"This dress perfectly enhances your pear-shaped figure with its flowing 
skirt and fitted bodice. The cool tones bring out your natural beauty..."
```

## If You Get Errors

### Error 1: "Python is not installed..."
**Problem:** Python not found in system PATH
**Solution:** 
1. Install Python from python.org
2. During installation, CHECK "Add Python to PATH"
3. Restart your computer
4. Restart web server

### Error 2: "ModuleNotFoundError: No module named 'cv2'"
**Problem:** OpenCV not installed
**Solution:**
```bash
pip install opencv-python==4.8.1.78
pip install numpy==1.24.3
```
Then restart web server

### Error 3: "Product information missing..."
**Problem:** Product ID not passing to try-on page
**Solution:** 
- Make sure you clicked "Try On with AI" from a product
- Check URL has `&pid=XXX` parameter
- Check browser console for JavaScript errors

### Error 4: Dress doesn't appear on photo
**Problem:** Image too dark or unclear
**Solution:**
- Try a clearer photo with better lighting
- Ensure full body is visible in photo
- Try different angles

### Error 5: "Connection error"
**Problem:** Web server not responding
**Solution:**
1. Check if web server is running
2. Restart web server
3. Check if port 8080 is accessible

## Performance Notes

⏱️ **First Run:** May take 30-60 seconds (Python/OpenCV loading)
⏱️ **Subsequent Runs:** 10-30 seconds typical
⏱️ **Maximum Timeout:** 60 seconds (will show error after)

## Browser Compatibility

✅ Works on: Chrome, Firefox, Edge, Safari
✅ Mobile: Should work on mobile browsers too
❌ Note: Processing time may be longer on slower connections

## File Structure Verification

Check these files exist:
- [ ] `src/main/webapp/python_ai/ai_tryon_engine.py`
- [ ] `src/main/webapp/python_ai/virtual_tryon.py`
- [ ] `src/main/webapp/python_ai/body_analyzer.py`
- [ ] `src/main/webapp/python_ai/requirements.txt`
- [ ] `src/main/java/com/servlet/AITryOnServlet.java`
- [ ] `src/main/webapp/ai-tryon.jsp`

Create these directories if they don't exist:
- [ ] `ai_tryon_temp/` (for uploaded photos)
- [ ] `ai_tryon_output/` (for results)

These are created automatically by the application.

## Support

If issues persist:
1. Check browser console (F12) for errors
2. Check server logs for Python errors
3. Verify Python installation: `python --version`
4. Verify dependencies: `pip list | grep opencv`
5. Restart web server and try again

---

**Ready to test?** Follow the steps above and enjoy your AI try-on feature! 🎉
