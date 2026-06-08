# Python 3.8+ Installation Guide for Windows

## Step-by-Step Installation

### Step 1: Download Python
1. Go to: https://www.python.org/downloads/
2. Click **"Download Python 3.12.x"** (or latest 3.8+)
   - Latest version recommended
   - File will be: `python-3.12.x-amd64.exe`

### Step 2: Run the Installer
1. **Double-click** the downloaded `.exe` file
2. **IMPORTANT:** Check the box that says:
   ```
   ☑ Add Python 3.12 to PATH
   ```
   This is CRITICAL - without it, Windows won't find Python

3. Click **"Install Now"** (recommended)
4. Wait for installation to complete
5. Click **"Close"** when done

### Step 3: Verify Python Installation
1. **Open Command Prompt** (Windows key + R, type `cmd`, press Enter)
2. Type this command:
   ```
   python --version
   ```
3. You should see:
   ```
   Python 3.12.x  (or your version)
   ```

**If you get "command not found":**
- You may have skipped checking "Add Python to PATH"
- **SOLUTION:** Restart your computer, then try again
- If still not working, uninstall and reinstall Python, making sure to check the PATH option

### Step 4: Install Required Libraries
1. **Open Command Prompt**
2. Copy and paste each command (one at a time):

```bash
pip install opencv-python==4.8.1.78
```
Wait for this to complete, then:

```bash
pip install numpy==1.24.3
```

Each command will show "Successfully installed..." when done.

### Step 5: Verify Libraries Installation
1. **Open Command Prompt**
2. Run this command:
   ```
   python -c "import cv2, numpy; print('OpenCV:', cv2.__version__); print('NumPy:', numpy.__version__)"
   ```
3. You should see versions printed:
   ```
   OpenCV: 4.8.1.78
   NumPy: 1.24.3
   ```

**If you get errors:**
- Try: `pip install --upgrade pip` first
- Then retry the installations above

### Step 6: Restart Web Server (IMPORTANT!)
1. **Stop Tomcat/Web Server**
   - Close the application or stop the service
   - Wait 5 seconds

2. **Start Tomcat/Web Server**
   - Start the application or service again
   - Wait for it to fully start up

3. This is CRITICAL because Java needs to reload environment variables

### Step 7: Test the AI Try-On Feature
1. Open browser: `http://localhost:8080/ClothingStore_Final/collections.jsp`
2. Click **"Try On with AI"** on any product
3. Upload your photo
4. Click **"Scan Photo"**
5. **Wait 10-30 seconds** for processing
6. You should see the dress appear on your photo!

---

## Troubleshooting

### Issue: "command not found" or "python is not recognized"

**Solution:**
1. Verify Python was installed: Check in `C:\Users\YourUsername\AppData\Local\Programs\Python\`
2. **Restart your computer** (Windows caches PATH at startup)
3. Try command again: `python --version`

### Issue: "Module not found: cv2" or "Module not found: numpy"

**Solution:**
```bash
pip install --upgrade pip
pip install opencv-python==4.8.1.78
pip install numpy==1.24.3
```

### Issue: "pip not found"

**Solution:** Python installed without pip
```bash
python -m pip install opencv-python==4.8.1.78
python -m pip install numpy==1.24.3
```

### Issue: Still getting error after all steps

**Solution:**
1. Completely restart your computer
2. Open NEW Command Prompt window
3. Verify: `python --version`
4. Restart web server
5. Try AI try-on again

---

## Verification Checklist

Before trying the AI try-on feature, verify all of these:

- [ ] Python 3.8+ installed
- [ ] "Add Python to PATH" was checked during installation
- [ ] `python --version` works in Command Prompt
- [ ] `pip install opencv-python==4.8.1.78` succeeded
- [ ] `pip install numpy==1.24.3` succeeded
- [ ] Web server restarted
- [ ] Computer restarted (if had any issues)

---

## Success Verification

Run this in Command Prompt to verify everything is ready:

```bash
python -c "import cv2, numpy; print('✓ Python 3 ready'); print('✓ OpenCV:', cv2.__version__); print('✓ NumPy:', numpy.__version__); print('✓ All systems go!')"
```

You should see:
```
✓ Python 3 ready
✓ OpenCV: 4.8.1.78
✓ NumPy: 1.24.3
✓ All systems go!
```

---

## Alternative: If All Else Fails

**Microsoft Store Installation** (Easiest):
1. Open Windows **Microsoft Store**
2. Search for **"Python 3.11"** or **"Python 3.12"**
3. Click **"Install"**
4. It automatically adds to PATH
5. Then install libraries:
   ```bash
   pip install opencv-python numpy
   ```

---

## What Happens Next

After Python is installed and verified:

1. **User uploads photo** → Stored temporarily
2. **Python script runs** → Analyzes body shape
3. **Dress is overlaid** → Appears on person's torso
4. **Results shown** → With styling recommendations
5. **Files cleaned up** → Temporary photos deleted

---

## Support

If you get stuck:
1. Check that "Add Python to PATH" was checked during installation
2. Restart computer - Windows PATH is only loaded at startup
3. Verify with: `python --version` in a NEW Command Prompt window
4. If still not working, uninstall and reinstall Python

---

**Once Python is installed:** Your AI try-on feature will work perfectly! 🎉
