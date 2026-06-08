#!/usr/bin/env python3
"""
AI Try-On Engine - Main Orchestrator
Coordinates body analysis and virtual try-on processing
"""

import sys
import json
import os
from pathlib import Path

# Add script directory to Python path
sys.path.insert(0, str(Path(__file__).parent))

def process_try_on(image_path, product_id):
    """
    Main try-on processing function
    
    Args:
        image_path: Full path to uploaded user photo
        product_id: Product ID from database
    
    Returns:
        JSON response with analysis and try-on results
    """
    
    try:
        # Import analysis modules
        from body_analyzer import analyze_body_shape
        from virtual_tryon import create_virtual_overlay
        
        # Validate input
        if not os.path.exists(image_path):
            return {
                "status": "error",
                "message": "Image file not found"
            }
        
        # Step 1: Analyze body shape and proportions
        print("[*] Analyzing body shape and tone...", file=sys.stderr)
        body_analysis = analyze_body_shape(image_path)
        
        if not body_analysis:
            return {
                "status": "error",
                "message": "Could not analyze body from image"
            }
        
        # Step 2: Create virtual try-on overlay
        print("[*] Creating virtual try-on overlay...", file=sys.stderr)
        try_on_result = create_virtual_overlay(image_path, product_id, body_analysis)
        
        if not try_on_result:
            return {
                "status": "error",
                "message": "Could not generate try-on preview"
            }
        
        # Step 3: Generate style recommendations
        print("[*] Generating style recommendations...", file=sys.stderr)
        style_recommendation = generate_style_recommendation(body_analysis, product_id)
        
        # Return success response
        response = {
            "status": "success",
            "body_analysis": body_analysis.get("summary", "Body shape analysis complete"),
            "style_recommendation": style_recommendation,
            "output_image": try_on_result.get("output_path", ""),
            "colors_match": body_analysis.get("colors", []),
            "size_suggestion": body_analysis.get("size_suggestion", "M"),
            "message": "AI analysis complete!"
        }
        
        return response
        
    except Exception as e:
        import traceback
        print(f"[ERROR] {str(e)}", file=sys.stderr)
        print(traceback.format_exc(), file=sys.stderr)
        return {
            "status": "error",
            "message": f"Processing error: {str(e)}"
        }

def generate_style_recommendation(body_analysis, product_id):
    """
    Generate personalized style recommendations based on body analysis
    
    Args:
        body_analysis: Dictionary with body shape and tone information
        product_id: Product ID for database lookup
    
    Returns:
        String with style recommendation text
    """
    
    try:
        shape = body_analysis.get("shape", "pear")
        tone = body_analysis.get("tone", "warm")
        colors = body_analysis.get("colors", ["emerald", "gold"])
        
        recommendations = {
            "apple": {
                "warm": "This A-line style beautifully balances your proportions and complements warm tones perfectly. The fitted bodice flatters your midsection while the flowing skirt creates an elegant silhouette.",
                "cool": "This structured dress works wonderfully with cool undertones, creating a sophisticated and confident look. The design highlights your best features while maintaining a balanced appearance."
            },
            "pear": {
                "warm": "This dress perfectly enhances your pear-shaped figure with its flowing skirt and fitted bodice. The warm tones bring out your natural beauty and create a harmonious color match.",
                "cool": "The rich cool tones in this piece complement your skin beautifully. The silhouette is designed to flatter pear-shaped figures with an elegantly balanced look."
            },
            "hourglass": {
                "warm": "This fitted style celebrates your curves beautifully! The design accentuates your natural proportions, and the warm tones enhance your radiant appearance.",
                "cool": "This elegant design hugs your curves in all the right places. Cool undertones create a sophisticated and polished look that's perfect for your figure."
            },
            "rectangle": {
                "warm": "This dress adds beautiful dimension to your frame. The warm color palette creates depth and warmth, making you look absolutely radiant and confident.",
                "cool": "This style creates a balanced and elongated silhouette. Cool tones add sophistication and create a seamless, elegant appearance."
            },
            "inverted_triangle": {
                "warm": "This flowing skirt beautifully balances your proportions while the warm tones bring out your natural glow. You'll look graceful and confident!",
                "cool": "This dress is designed to flatter inverted triangle figures perfectly. The cool tones add elegance and create a balanced, harmonious look."
            }
        }
        
        # Get recommendation based on shape and tone
        shape_key = shape if shape in recommendations else "pear"
        tone_key = tone if tone in recommendations[shape_key] else "warm"
        
        base_recommendation = recommendations[shape_key][tone_key]
        
        # Add color information
        color_text = f" The {', '.join(colors)} tones in this piece create a stunning contrast with your complexion."
        
        return base_recommendation + color_text
        
    except Exception as e:
        return "This piece is beautifully designed for your style. The fit and color create a harmonious and elegant look!"

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(json.dumps({"status": "error", "message": "Missing arguments"}))
        sys.exit(1)
    
    image_path = sys.argv[1]
    product_id = sys.argv[2]
    
    result = process_try_on(image_path, product_id)
    print(json.dumps(result))
