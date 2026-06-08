#!/usr/bin/env python3
"""
Virtual Try-On Module
Creates realistic overlays of clothing items on user photos
"""

import cv2
import numpy as np
from pathlib import Path
import sys
import os
from datetime import datetime

try:
    import mediapipe as mp
    HAS_MEDIAPIPE = True
except ImportError:
    HAS_MEDIAPIPE = False

def create_virtual_overlay(user_image_path, product_id, body_analysis):
    """
    Create virtual try-on overlay by positioning dress on person's torso
    
    Args:
        user_image_path: Path to user's uploaded photo
        product_id: Product ID (would be used to fetch product image from DB)
        body_analysis: Body analysis results from body_analyzer
    
    Returns:
        Dictionary with output image path and overlay details
    """
    
    try:
        # Load user image
        user_image = cv2.imread(user_image_path)
        if user_image is None:
            print(f"[ERROR] Could not load user image: {user_image_path}", file=sys.stderr)
            return None
        
        # Create realistic dress overlay based on body analysis
        output_image = create_realistic_dress_overlay(user_image, body_analysis, product_id)
        
        if output_image is None:
            return None
        
        # Save output image
        output_path = save_output_image(output_image)
        
        if output_path:
            return {
                "output_path": output_path,
                "method": "realistic_overlay",
                "status": "success"
            }
        else:
            return None
            
    except Exception as e:
        print(f"[ERROR] Virtual try-on failed: {str(e)}", file=sys.stderr)
        return None

def create_realistic_dress_overlay(image, body_analysis, product_id):
    """
    Create a realistic virtual dress try-on by overlaying dress pattern on person's body
    """
    
    try:
        h, w = image.shape[:2]
        result = image.copy()
        
        shape = body_analysis.get("shape", "pear")
        
        # Define dress positioning based on body shape
        # Calculate dress region on the person's torso
        if shape == "apple":
            # Focus on fitted waist
            dress_y_start = int(h * 0.25)
            dress_y_end = int(h * 0.80)
            dress_width_ratio = 0.55
        elif shape == "pear":
            # Emphasis on hips and lower body
            dress_y_start = int(h * 0.30)
            dress_y_end = int(h * 0.95)
            dress_width_ratio = 0.60
        elif shape == "hourglass":
            # Full fitted dress on curves
            dress_y_start = int(h * 0.20)
            dress_y_end = int(h * 0.92)
            dress_width_ratio = 0.50
        else:
            # Default (rectangle)
            dress_y_start = int(h * 0.28)
            dress_y_end = int(h * 0.88)
            dress_width_ratio = 0.55
        
        # Calculate dress dimensions
        dress_width = int(w * dress_width_ratio)
        dress_height = dress_y_end - dress_y_start
        dress_x_start = int((w - dress_width) / 2)
        
        # Get color from body analysis
        colors = body_analysis.get("colors", ["emerald"])
        color_name = colors[0] if colors else "emerald"
        
        # Map color names to BGR values
        color_map = {
            "emerald": (50, 150, 120),      # Green
            "gold": (0, 215, 255),           # Gold/Yellow
            "sapphire": (200, 100, 50),      # Blue
            "ruby": (50, 50, 200),           # Red
            "amethyst": (200, 50, 150),      # Purple
            "rose": (150, 100, 150),         # Pink
            "ivory": (240, 240, 235),        # Cream
            "coral": (75, 165, 255)          # Coral
        }
        
        dress_color = color_map.get(color_name, (50, 150, 120))
        
        # Try to load actual product image to overlay (preferred)
        product_img = load_product_image(product_id, dress_width, dress_height)

        if product_img is not None:
            overlay_region = product_img
        else:
            # Create dress pattern with gradient and texture as fallback
            overlay_region = create_dress_pattern(dress_width, dress_height, dress_color)

        # Blend overlay onto person with alpha blending
        alpha = 0.85  # More opaque to clearly show product

        # Handle boundary conditions and perform blending
        if dress_y_end <= h and dress_x_start >= 0 and (dress_x_start + dress_width) <= w:
            try:
                # If overlay has alpha channel, use it as mask
                if overlay_region.shape[2] == 4:
                    alpha_mask = overlay_region[:, :, 3] / 255.0
                    for c in range(3):
                        result[dress_y_start:dress_y_end, dress_x_start:dress_x_start + dress_width, c] = (
                            (1 - alpha_mask) * result[dress_y_start:dress_y_end, dress_x_start:dress_x_start + dress_width, c] +
                            alpha_mask * overlay_region[:, :, c]
                        ).astype(np.uint8)
                else:
                    for c in range(3):
                        result[dress_y_start:dress_y_end, dress_x_start:dress_x_start + dress_width, c] = (
                            result[dress_y_start:dress_y_end, dress_x_start:dress_x_start + dress_width, c] * (1 - alpha) +
                            overlay_region[:, :, c] * alpha
                        ).astype(np.uint8)
            except Exception as e:
                print(f"[WARNING] Blending overlay failed: {str(e)}", file=sys.stderr)
                # Fallback to no-op
        
        # Add subtle styling markers
        add_styling_details(result, dress_y_start, dress_x_start, dress_width, dress_height)
        
        return result
        
    except Exception as e:
        print(f"[ERROR] Realistic overlay creation failed: {str(e)}", file=sys.stderr)
        return None

def load_product_image(product_id, target_w, target_h):
    """
    Try to load a product image from the project `product_img` folder.
    Support PNG/JPG and basic alpha blending when PNG has transparency.
    """
    try:
        # Product images are stored relative to project root: ../product_img/
        script_dir = Path(__file__).parent.parent
        product_dir = script_dir / "product_img"

        if not product_dir.exists():
            return None

        # Try common filename patterns
        candidates = [
            product_dir / f"{product_id}.png",
            product_dir / f"{product_id}.jpg",
            product_dir / f"{product_id}.jpeg",
            product_dir / f"product_{product_id}.png",
            product_dir / f"product_{product_id}.jpg",
            product_dir / f"product_{product_id}.jpeg",
        ]

        found = None
        for c in candidates:
            if c.exists():
                found = c
                break

        # If not found, try any file containing the product_id
        if found is None:
            for p in product_dir.iterdir():
                if product_id in p.name:
                    found = p
                    break

        if found is None:
            return None

        img = cv2.imread(str(found), cv2.IMREAD_UNCHANGED)
        if img is None:
            return None

        # Resize to fit target region
        img_resized = cv2.resize(img, (target_w, target_h), interpolation=cv2.INTER_AREA)
        return img_resized
    except Exception as e:
        print(f"[WARNING] load_product_image failed: {str(e)}", file=sys.stderr)
        return None

def create_dress_pattern(width, height, color):
    """
    Create a dress pattern with gradient and texture details
    """
    
    try:
        dress = np.zeros((height, width, 3), dtype=np.uint8)
        
        # Create gradient effect (darker at top, lighter at bottom for depth)
        for y in range(height):
            intensity = 0.7 + (0.3 * (y / height))  # Gradient intensity
            for x in range(width):
                # Apply gradient
                dress[y, x] = tuple(int(c * intensity) for c in color)
        
        # Add subtle texture/pattern
        noise = np.random.normal(0, 8, (height, width, 3)).astype(np.uint8)
        dress = cv2.addWeighted(dress, 0.9, noise, 0.1, 0)
        
        # Add subtle vertical stripes for fabric texture
        for x in range(0, width, 15):
            cv2.line(dress, (x, 0), (x, height), (255, 255, 255), 1)
            alpha = 0.1
            dress[:, x:x+2] = cv2.addWeighted(dress[:, x:x+2], 1-alpha, 
                                              np.ones_like(dress[:, x:x+2]) * 200, alpha, 0)
        
        # Add top and bottom borders for dress definition
        cv2.line(dress, (0, 2), (width, 2), (100, 100, 100), 2)  # Top border
        
        return dress
        
    except Exception as e:
        print(f"[WARNING] Pattern creation failed: {str(e)}", file=sys.stderr)
        # Return solid color dress if pattern creation fails
        dress = np.full((height, width, 3), color, dtype=np.uint8)
        return dress

def add_styling_details(image, y_start, x_start, width, height):
    """
    Add styling details like borders and indicators
    """
    
    try:
        font = cv2.FONT_HERSHEY_SIMPLEX
        
        # Add subtle frame around dress
        cv2.rectangle(image, (x_start - 2, y_start - 2), 
                     (x_start + width + 2, y_start + height + 2), 
                     (200, 180, 150), 2)
        
        # Add "AI Try-On" indicator at top
        text_x = max(10, x_start)
        text_y = max(25, y_start - 10)
        cv2.putText(image, "AI Try-On", (text_x, text_y), 
                   font, 0.7, (255, 255, 255), 2, cv2.LINE_AA)
        
    except Exception as e:
        print(f"[WARNING] Adding styling details failed: {str(e)}", file=sys.stderr)

def save_output_image(image):
    """
    Save processed image and return the path
    
    Returns:
        Relative path to saved image
    """
    
    try:
        # Create output directory if it doesn't exist
        script_dir = Path(__file__).parent.parent / "ai_tryon_output"
        script_dir.mkdir(exist_ok=True)
        
        # Generate unique filename
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        filename = f"tryon_{timestamp}.png"
        output_path = script_dir / filename
        
        # Save image
        if cv2.imwrite(str(output_path), image):
            # Return relative path for web access
            return f"ai_tryon_output/{filename}"
        else:
            print(f"[ERROR] Failed to save output image: {output_path}", file=sys.stderr)
            return None
            
    except Exception as e:
        print(f"[ERROR] Output save failed: {str(e)}", file=sys.stderr)
        return None

def enhance_image_quality(image):
    """
    Enhance the quality of the output image
    """
    
    try:
        # Apply slight sharpening
        kernel = np.array([[-1, -1, -1],
                          [-1,  9, -1],
                          [-1, -1, -1]]) / 1.5
        sharpened = cv2.filter2D(image, -1, kernel)
        
        # Apply slight denoising
        denoised = cv2.fastNlMeansDenoisingColored(sharpened, None, h=8, hForColorComponents=8, 
                                                    templateWindowSize=7, searchWindowSize=21)
        
        return denoised
        
    except Exception as e:
        print(f"[WARNING] Enhancement failed: {str(e)}", file=sys.stderr)
        return image

