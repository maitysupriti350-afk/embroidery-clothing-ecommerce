#!/usr/bin/env python3
"""
Hosted-model inference wrapper for AI try-on (Hugging Face / generic)

Usage: python ai_tryon_inference.py <user_image_path> <product_image_path>

This script sends both images to a hosted model (configurable via HF_MODEL env var)
and saves the resulting image to ai_tryon_output/. It prints a single JSON object
to stdout with `status` and `output_image` or `error` fields.
"""

import os
import sys
import json
import base64
from pathlib import Path
import requests


def main():
    if len(sys.argv) < 3:
        print(json.dumps({"status": "error", "message": "Missing arguments"}))
        sys.exit(1)

    user_image = sys.argv[1]
    product_image = sys.argv[2]

    hf_token = os.environ.get("HF_API_TOKEN")
    hf_model = os.environ.get("HF_MODEL")

    if not hf_token or not hf_model:
        print(json.dumps({"status": "error", "message": "HF_API_TOKEN and HF_MODEL must be set in environment"}))
        sys.exit(1)

    # Read files
    try:
        with open(user_image, "rb") as f:
            user_b = f.read()
        with open(product_image, "rb") as f:
            prod_b = f.read()
    except Exception as e:
        print(json.dumps({"status": "error", "message": f"Failed to read images: {str(e)}"}))
        sys.exit(1)

    user_b64 = base64.b64encode(user_b).decode("utf-8")
    prod_b64 = base64.b64encode(prod_b).decode("utf-8")

    url = f"https://api-inference.huggingface.co/models/{hf_model}"
    headers = {"Authorization": f"Bearer {hf_token}", "Accept": "application/json"}

    payload = {
        "inputs": {
            "user_image": user_b64,
            "product_image": prod_b64
        },
        "options": {"wait_for_model": True}
    }

    try:
        resp = requests.post(url, headers=headers, json=payload, timeout=120)
    except Exception as e:
        print(json.dumps({"status": "error", "message": f"Request failed: {str(e)}"}))
        sys.exit(1)

    # If the model returns an image directly (content-type image/*), save it
    content_type = resp.headers.get("content-type", "")
    output_dir = Path(__file__).parent.parent / "ai_tryon_output"
    output_dir.mkdir(exist_ok=True)

    if content_type.startswith("image"):
        # Save binary
        out_path = output_dir / f"hf_tryon_{os.getpid()}.png"
        with open(out_path, "wb") as f:
            f.write(resp.content)
        print(json.dumps({"status": "success", "output_image": f"ai_tryon_output/{out_path.name}"}))
        return

    # Otherwise expect JSON response
    try:
        j = resp.json()
    except Exception as e:
        print(json.dumps({"status": "error", "message": f"Invalid JSON response: {str(e)}", "raw": resp.text[:1000]}))
        sys.exit(1)

    # Look for base64 image keys commonly used: 'image', 'generated_image', 'output'
    candidates = ["image", "generated_image", "output", "result"]
    img_b64 = None
    for k in candidates:
        if k in j and isinstance(j[k], str):
            img_b64 = j[k]
            break

    # Some models return nested structure
    if img_b64 is None:
        # search for first long base64-looking string
        def find_b64(obj):
            if isinstance(obj, str) and len(obj) > 200:
                return obj
            if isinstance(obj, dict):
                for v in obj.values():
                    res = find_b64(v)
                    if res:
                        return res
            if isinstance(obj, list):
                for v in obj:
                    res = find_b64(v)
                    if res:
                        return res
            return None

        img_b64 = find_b64(j)

    if not img_b64:
        # No image found
        print(json.dumps({"status": "error", "message": "No image returned by model", "response": j}))
        sys.exit(1)

    try:
        img_bytes = base64.b64decode(img_b64)
        out_path = output_dir / f"hf_tryon_{os.getpid()}.png"
        with open(out_path, "wb") as f:
            f.write(img_bytes)
        print(json.dumps({"status": "success", "output_image": f"ai_tryon_output/{out_path.name}"}))
    except Exception as e:
        print(json.dumps({"status": "error", "message": f"Failed to decode/save image: {str(e)}"}))


if __name__ == "__main__":
    main()
