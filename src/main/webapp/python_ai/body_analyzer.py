#!/usr/bin/env python3
"""
Body Analysis Module
Analyzes body shape, proportions, and skin tone to provide styling recommendations
"""

import cv2
import numpy as np
from pathlib import Path
import sys

try:
    import mediapipe as mp
except ImportError:
    mp = None
    print("[WARNING] MediaPipe not installed. Install with: pip install mediapipe", file=sys.stderr)

def analyze_body_shape(image_path):
    """
    Analyze body shape and proportions from image
    
    Args:
        image_path: Path to user's full-body photo
    
    Returns:
        Dictionary with body analysis results
    """
    
    try:
        # Load image
        image = cv2.imread(image_path)
        if image is None:
            print(f"[ERROR] Could not read image: {image_path}", file=sys.stderr)
            return None
        
        # Resize for processing
        original_h, original_w = image.shape[:2]
        max_dim = max(original_h, original_w)
        
        # Process image
        if mp:
            # Use MediaPipe for pose detection
            analysis = analyze_with_mediapipe(image, original_w, original_h)
        else:
            # Fallback: basic analysis
            analysis = analyze_basic(image, original_w, original_h)
        
        if not analysis:
            return None
        
        # Add color analysis
        color_analysis = analyze_skin_tone(image)
        analysis.update(color_analysis)
        
        return analysis
        
    except Exception as e:
        print(f"[ERROR] Body analysis failed: {str(e)}", file=sys.stderr)
        return None

def analyze_with_mediapipe(image, width, height):
    """
    Advanced body analysis using Google's MediaPipe pose detection
    """
    
    try:
        mp_pose = mp.solutions.pose
        mp_drawing = mp.solutions.drawing_utils
        
        with mp_pose.Pose(
            static_image_mode=True,
            model_complexity=1,
            enable_segmentation=True,
            smooth_landmarks=True
        ) as pose:
            
            # Convert BGR to RGB
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            results = pose.process(image_rgb)
            
            if not results.pose_landmarks:
                return analyze_basic(image, width, height)
            
            landmarks = results.pose_landmarks.landmark
            
            # Extract key body points (normalized to 0-1 range)
            keypoints = {
                "shoulder_left": (landmarks[11].x, landmarks[11].y),
                "shoulder_right": (landmarks[12].x, landmarks[12].y),
                "hip_left": (landmarks[23].x, landmarks[23].y),
                "hip_right": (landmarks[24].x, landmarks[24].y),
                "knee_left": (landmarks[25].x, landmarks[25].y),
                "knee_right": (landmarks[26].x, landmarks[26].y),
                "ankle_left": (landmarks[27].x, landmarks[27].y),
                "ankle_right": (landmarks[28].x, landmarks[28].y),
                "neck": (landmarks[0].x, landmarks[0].y) if landmarks[0].visibility > 0.5 else None
            }
            
            # Calculate body measurements (relative)
            shoulder_width = abs(keypoints["shoulder_right"][0] - keypoints["shoulder_left"][0])
            hip_width = abs(keypoints["hip_right"][0] - keypoints["hip_left"][0])
            
            # Determine body shape
            body_shape = classify_body_shape(shoulder_width, hip_width)
            
            # Size suggestion based on proportions
            size_suggestion = suggest_size(keypoints, image)
            
            return {
                "shape": body_shape,
                "shoulder_width": round(shoulder_width, 3),
                "hip_width": round(hip_width, 3),
                "size_suggestion": size_suggestion,
                "summary": f"Body shape: {body_shape.replace('_', ' ').title()}. Recommended size: {size_suggestion}. This style will flatter your proportions beautifully.",
                "detected_landmarks": True
            }
            
    except Exception as e:
        print(f"[ERROR] MediaPipe analysis failed: {str(e)}", file=sys.stderr)
        return None

def analyze_basic(image, width, height):
    """
    Basic body shape analysis using image processing
    Falls back when MediaPipe is unavailable
    """
    
    try:
        # Convert to HSV for better skin detection
        hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
        
        # Detect skin region (rough approximation)
        lower_skin = np.array([0, 20, 70], dtype=np.uint8)
        upper_skin = np.array([20, 255, 255], dtype=np.uint8)
        mask = cv2.inRange(hsv, lower_skin, upper_skin)
        
        # Find contours
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        if contours:
            # Get the largest contour (assuming it's the body)
            largest_contour = max(contours, key=cv2.contourArea)
            x, y, w, h = cv2.boundingRect(largest_contour)
            
            # Estimate body shape based on bounding box proportions
            aspect_ratio = h / w if w > 0 else 1
            
            if aspect_ratio > 2.0:
                body_shape = "rectangle"
            elif w > h * 0.6:
                body_shape = "apple"
            else:
                body_shape = "pear"
        else:
            body_shape = "pear"  # Default
        
        return {
            "shape": body_shape,
            "size_suggestion": "M",
            "summary": f"Body shape: {body_shape.replace('_', ' ').title()}. Recommended size: M. Designed to complement your natural proportions.",
            "detected_landmarks": False
        }
        
    except Exception as e:
        print(f"[ERROR] Basic analysis failed: {str(e)}", file=sys.stderr)
        return {
            "shape": "hourglass",
            "size_suggestion": "M",
            "summary": "Analysis complete. Recommended size: M.",
            "detected_landmarks": False
        }

def classify_body_shape(shoulder_width, hip_width):
    """
    Classify body shape based on shoulder and hip measurements
    """
    
    ratio = hip_width / shoulder_width if shoulder_width > 0 else 1
    
    if ratio < 0.85:
        return "inverted_triangle"
    elif ratio > 1.15:
        return "pear"
    elif 0.95 < ratio < 1.05:
        return "hourglass"
    elif ratio < 0.95:
        return "apple"
    else:
        return "rectangle"

def suggest_size(keypoints, image):
    """
    Suggest size based on body measurements
    """
    
    try:
        h, w = image.shape[:2]
        
        # Calculate full body height from neck to ankle
        if keypoints.get("neck") and keypoints.get("ankle_left"):
            neck_y = keypoints["neck"][1]
            ankle_y = keypoints["ankle_left"][1]
            body_height = abs(ankle_y - neck_y)
            
            # Calculate shoulder width in pixels
            shoulder_width = abs(keypoints["shoulder_right"][0] - keypoints["shoulder_left"][0]) * w
            
            # Estimate size based on proportions
            if shoulder_width < w * 0.25:
                return "XS"
            elif shoulder_width < w * 0.3:
                return "S"
            elif shoulder_width < w * 0.35:
                return "M"
            elif shoulder_width < w * 0.4:
                return "L"
            else:
                return "XL"
    except:
        pass
    
    return "M"  # Default

def analyze_skin_tone(image):
    """
    Analyze skin tone to recommend complementary colors
    """
    
    try:
        # Convert to RGB
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        # Detect skin regions (simple approach)
        hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
        lower_skin = np.array([0, 20, 70], dtype=np.uint8)
        upper_skin = np.array([30, 255, 255], dtype=np.uint8)
        mask = cv2.inRange(hsv, lower_skin, upper_skin)
        
        # Get average color of detected skin
        if cv2.countNonZero(mask) > 0:
            skin_pixels = image_rgb[mask > 0]
            avg_r = int(np.mean(skin_pixels[:, 0]))
            avg_g = int(np.mean(skin_pixels[:, 1]))
            avg_b = int(np.mean(skin_pixels[:, 2]))
            
            # Classify as warm or cool tone
            # Warm: higher red component
            tone = "warm" if avg_r > avg_b else "cool"
            
            # Recommend colors based on tone
            if tone == "warm":
                colors = ["emerald", "gold", "terracotta", "peach"]
            else:
                colors = ["sapphire", "silver", "plum", "rose gold"]
            
            return {
                "tone": tone,
                "colors": colors[:2],  # Return top 2 color suggestions
                "skin_rgb": (avg_r, avg_g, avg_b)
            }
        else:
            return {
                "tone": "warm",
                "colors": ["emerald", "gold"],
                "skin_rgb": (0, 0, 0)
            }
            
    except Exception as e:
        print(f"[WARNING] Skin tone analysis failed: {str(e)}", file=sys.stderr)
        return {
            "tone": "warm",
            "colors": ["emerald", "gold"]
        }
