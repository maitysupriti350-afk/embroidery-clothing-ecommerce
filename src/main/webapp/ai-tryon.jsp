<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.URLDecoder" %>
<%
    String prodName = request.getParameter("prodName") != null ? request.getParameter("prodName") : "Selected Product";
    String prodImage = request.getParameter("img") != null ? request.getParameter("img") : "placeholder.svg";
    prodName = URLDecoder.decode(prodName, "UTF-8");
    prodImage = URLDecoder.decode(prodImage, "UTF-8");
    String escapedName = prodName.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    String escapedImage = prodImage.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Try-On Preview | The Heritage Gallery</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #1d2939; margin: 0; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; min-height: 100vh; }
        .page-body { max-width: 1400px; margin: 0 auto; padding: 28px 18px 44px; }
        .hero-panel { display: grid; grid-template-columns: 1fr 1fr; gap: 32px; align-items: start; margin-bottom: 28px; }
        .hero-copy { padding: 40px; background: rgba(255, 255, 255, 0.95); border-radius: 24px; box-shadow: 0 24px 60px rgba(0, 0, 0, 0.15); backdrop-filter: blur(10px); }
        .hero-copy .badge { display: inline-flex; align-items: center; gap: 10px; padding: 12px 20px; border-radius: 50px; background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; font-weight: 700; margin-bottom: 20px; font-size: 14px; }
        .hero-copy h1 { margin: 0 0 20px; font-size: 2.8rem; line-height: 1.1; color: #1a1a2e; font-weight: 700; }
        .hero-copy p { margin: 0 0 16px; line-height: 1.7; color: #4a5568; font-size: 16px; }
        .hero-copy ul { margin: 20px 0 0; padding-left: 20px; color: #4a5568; }
        .hero-copy ul li { margin-bottom: 12px; line-height: 1.6; }
        .hero-copy .cta-link { display: inline-flex; align-items: center; gap: 10px; margin-top: 24px; padding: 16px 28px; border-radius: 50px; background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; text-decoration: none; font-weight: 700; transition: transform 0.3s ease, box-shadow 0.3s ease; }
        .hero-copy .cta-link:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4); }
        .preview-card { background: rgba(255, 255, 255, 0.95); border-radius: 24px; overflow: hidden; box-shadow: 0 24px 60px rgba(0, 0, 0, 0.15); backdrop-filter: blur(10px); }
        .preview-card .preview-header { padding: 28px 32px 20px; display: flex; align-items: center; justify-content: space-between; gap: 20px; border-bottom: 1px solid #e2e8f0; }
        .preview-card .preview-header h2 { margin: 0; font-size: 1.4rem; color: #1a1a2e; font-weight: 700; }
        .preview-card .preview-header p { margin: 0; color: #64748b; max-width: 300px; font-size: 14px; }
        .preview-card .preview-body { padding: 28px 32px 32px; }
        .upload-box { display: grid; gap: 20px; }
        .upload-area { border: 2px dashed rgba(102, 126, 234, 0.3); border-radius: 20px; background: #f8fafc; padding: 32px; text-align: center; cursor: pointer; transition: all 0.3s ease; }
        .upload-area:hover { border-color: #667eea; background: #f0f4ff; transform: translateY(-2px); }
        .upload-area input { display: none; }
        .upload-area i { font-size: 2.5rem; color: #667eea; margin-bottom: 16px; }
        .upload-area p { margin: 0; font-size: 15px; color: #475569; font-weight: 500; }
        .preview-status { padding: 20px; border-radius: 16px; background: #f8fafc; border: 1px solid #e2e8f0; display: grid; gap: 12px; }
        .preview-status strong { color: #1a1a2e; display: block; margin-bottom: 8px; font-size: 16px; }
        .preview-canvas { position: relative; min-height: 500px; border-radius: 20px; overflow: hidden; background: #f1f5f9; border: 2px solid #e2e8f0; margin-top: 24px; }
        .preview-canvas img.user-photo { width: 100%; height: 100%; object-fit: cover; }
        .preview-canvas .dress-overlay-container { position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; }
        .preview-canvas img.product-overlay { position: absolute; cursor: move; pointer-events: auto; transition: box-shadow 0.2s ease; filter: drop-shadow(0 4px 12px rgba(0, 0, 0, 0.3)); }
        .preview-canvas img.product-overlay:hover { filter: drop-shadow(0 8px 20px rgba(0, 0, 0, 0.4)); }
        .preview-canvas .placeholder { padding: 40px; text-align: center; color: #64748b; }
        .preview-canvas .placeholder i { font-size: 4rem; color: #cbd5e1; margin-bottom: 20px; }
        .control-panel { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-top: 20px; padding: 20px; background: #f8fafc; border-radius: 16px; border: 1px solid #e2e8f0; }
        .control-group { display: flex; flex-direction: column; gap: 8px; }
        .control-group label { font-size: 13px; font-weight: 600; color: #475569; text-transform: uppercase; letter-spacing: 0.5px; }
        .control-group input[type="range"] { width: 100%; accent-color: #667eea; }
        .control-group select { padding: 10px 14px; border-radius: 8px; border: 1px solid #e2e8f0; background: #fff; font-size: 14px; cursor: pointer; }
        .ai-results { display: grid; gap: 16px; margin-top: 24px; }
        .ai-results .result-card { background: #fff; border-radius: 16px; padding: 24px; border: 1px solid #e2e8f0; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05); }
        .ai-results .result-card h3 { margin: 0 0 12px; color: #1a1a2e; font-size: 1.1rem; font-weight: 700; }
        .ai-results .result-chip { display: inline-flex; align-items: center; gap: 8px; margin: 8px 8px 0 0; padding: 10px 16px; border-radius: 50px; background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; font-weight: 600; font-size: 13px; }
        .ai-results .result-chip i { color: #fff; }
        .ai-results small { color: #64748b; }
        .action-footer { display: flex; justify-content: flex-end; margin-top: 20px; gap: 12px; flex-wrap: wrap; }
        .action-footer button { padding: 14px 24px; border-radius: 50px; border: none; cursor: pointer; font-weight: 700; font-size: 14px; transition: all 0.3s ease; }
        .action-footer .scan-btn { background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; }
        .action-footer .scan-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4); }
        .action-footer .browse-btn { background: #fff; color: #1a1a2e; border: 2px solid #e2e8f0; }
        .action-footer .browse-btn:hover { background: #f8fafc; border-color: #667eea; }
        .action-footer .download-btn { background: linear-gradient(135deg, #10b981, #059669); color: #fff; }
        .action-footer .download-btn:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4); }
        @media (max-width: 1024px) {
            .hero-panel { grid-template-columns: 1fr; }
            .preview-card { margin-top: 20px; }
        }
        @media (max-width: 768px) {
            .hero-copy { padding: 28px; }
            .hero-copy h1 { font-size: 2rem; }
            .preview-canvas { min-height: 400px; }
            .control-panel { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <jsp:include page="/common/header.jsp" />
    <div class="page-body">
        <div class="hero-panel">
            <div class="hero-copy">
                <span class="badge"><i class="fas fa-user-check"></i> Premium AI Fit</span>
                <h1>Try your chosen dress on your own photo</h1>
                <p>Upload a photo and our AI-powered fit preview will analyze your proportions, recommend size, length, color harmony, and how the item will look in a polished, easy-to-understand way.</p>
                <ul>
                    <li>Instant AI guidance for dress color and body-fit.</li>
                    <li>See how length and silhouette match your figure.</li>
                    <li>Get premium styling tips for a confident purchase.</li>
                </ul>
                <a class="cta-link" href="${pageContext.request.contextPath}/collections.jsp">Back to Collections</a>
            </div>
            <div class="preview-card">
                <div class="preview-header">
                    <div>
                        <h2>Selected dress</h2>
                        <p><%= escapedName %></p>
                    </div>
                    <img src="${pageContext.request.contextPath}/product_img/<%= escapedImage %>" alt="<%= escapedName %>" style="width:84px;height:84px;object-fit:cover;border-radius:18px;box-shadow:0 10px 24px rgba(0,0,0,0.12);">
                </div>
                <div class="preview-body">
                    <div class="upload-box">
                        <label class="upload-area" for="userPhotoInput">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <p>Upload your photo to see the dress on you</p>
                            <input type="file" id="userPhotoInput" accept="image/*">
                        </label>
                        <div class="preview-status" id="previewStatus">
                            <strong>Ready for your premium style preview</strong>
                            <p>Select a photo and tap the scan button to see size, color, and length suggestions.</p>
                        </div>
                        <div class="action-footer">
                            <button type="button" class="scan-btn" onclick="runTryOn()"><i class="fas fa-magnifying-glass"></i> Scan Photo</button>
                            <button type="button" class="browse-btn" onclick="resetPreview()"><i class="fas fa-rotate-left"></i> Reset</button>
                            <button type="button" class="download-btn" id="downloadBtn" onclick="downloadTryOn()" style="display:none;"><i class="fas fa-download"></i> Download</button>
                        </div>
                    </div>
                    <div class="preview-canvas" id="previewCanvas">
                        <div class="placeholder" id="previewPlaceholder">
                            <i class="fas fa-user"></i>
                            <p>Upload your photo to see the dress on you</p>
                        </div>
                        <img id="userPhoto" class="user-photo" src="" alt="Uploaded user" style="display:none;">
                        <div class="dress-overlay-container" id="dressOverlayContainer">
                            <img id="dressOverlay" class="product-overlay" src="${pageContext.request.contextPath}/product_img/<%= escapedImage %>" alt="Dress overlay" style="display:none; left: 50%; top: 15%; transform: translateX(-50%); width: 50%;">
                        </div>
                    </div>
                    
                    <div class="control-panel" id="controlPanel" style="display:none;">
                        <div class="control-group">
                            <label>Size</label>
                            <input type="range" id="sizeControl" min="20" max="100" value="50" oninput="updateDressSize(this.value)">
                        </div>
                        <div class="control-group">
                            <label>Rotation</label>
                            <input type="range" id="rotationControl" min="-180" max="180" value="0" oninput="updateDressRotation(this.value)">
                        </div>
                        <div class="control-group">
                            <label>Opacity</label>
                            <input type="range" id="opacityControl" min="0" max="100" value="90" oninput="updateDressOpacity(this.value)">
                        </div>
                        <div class="control-group">
                            <label>Blend Mode</label>
                            <select id="blendModeControl" onchange="updateBlendMode(this.value)">
                                <option value="normal">Normal</option>
                                <option value="multiply">Multiply</option>
                                <option value="screen">Screen</option>
                                <option value="overlay">Overlay</option>
                                <option value="soft-light">Soft Light</option>
                            </select>
                        </div>
                        <div class="control-group">
                            <label>Background Removal</label>
                            <select id="bgRemovalControl" onchange="toggleBackgroundRemoval(this.value)">
                                <option value="enabled">Enabled</option>
                                <option value="disabled">Disabled</option>
                            </select>
                        </div>
                    </div>
                    <div class="ai-results" id="aiResults">
                        <div class="result-card">
                            <h3>How it works</h3>
                            <p>Upload your photo and our optional AI preview will suggest the best match for fit, color tone, and length. This view helps make product choice simple and attractive.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <jsp:include page="/common/footer.jsp" />
    <script>
        let selectedProductId = null;
        let dressPosition = { x: 50, y: 15 };
        let isDragging = false;
        let dragOffset = { x: 0, y: 0 };
        let originalDressSrc = '';
        let processedDressSrc = '';
        let backgroundRemovalEnabled = true;

        // Extract product ID from URL parameters
        function getProductIdFromURL() {
            const urlParams = new URLSearchParams(window.location.search);
            return urlParams.get('pid') || urlParams.get('prodId') || null;
        }

        // Initialize product ID
        function initializeProductId() {
            selectedProductId = getProductIdFromURL();
            if (!selectedProductId) {
                console.warn("No product ID provided");
            }
        }

        // Dress control functions
        function updateDressSize(value) {
            const overlay = document.getElementById('dressOverlay');
            overlay.style.width = value + '%';
        }

        function updateDressRotation(value) {
            const overlay = document.getElementById('dressOverlay');
            overlay.style.transform = `translateX(-50%) rotate(${value}deg)`;
        }

        function updateDressOpacity(value) {
            const overlay = document.getElementById('dressOverlay');
            overlay.style.opacity = value / 100;
        }

        function updateBlendMode(value) {
            const overlay = document.getElementById('dressOverlay');
            overlay.style.mixBlendMode = value;
        }

        function toggleBackgroundRemoval(value) {
            const overlay = document.getElementById('dressOverlay');
            backgroundRemovalEnabled = value === 'enabled';
            
            if (backgroundRemovalEnabled && processedDressSrc) {
                overlay.src = processedDressSrc;
            } else if (originalDressSrc) {
                overlay.src = originalDressSrc;
            }
        }

        // Drag and drop functionality
        function initializeDragAndDrop() {
            const overlay = document.getElementById('dressOverlay');
            const canvas = document.getElementById('previewCanvas');

            overlay.addEventListener('mousedown', startDrag);
            overlay.addEventListener('touchstart', startDrag, { passive: false });
            document.addEventListener('mousemove', drag);
            document.addEventListener('touchmove', drag, { passive: false });
            document.addEventListener('mouseup', endDrag);
            document.addEventListener('touchend', endDrag);
        }

        function startDrag(e) {
            e.preventDefault();
            isDragging = true;
            const overlay = document.getElementById('dressOverlay');
            const canvas = document.getElementById('previewCanvas');
            const rect = canvas.getBoundingClientRect();
            
            const clientX = e.type === 'touchstart' ? e.touches[0].clientX : e.clientX;
            const clientY = e.type === 'touchstart' ? e.touches[0].clientY : e.clientY;
            
            dragOffset.x = clientX - rect.left - (rect.width * (dressPosition.x / 100));
            dragOffset.y = clientY - rect.top - (rect.height * (dressPosition.y / 100));
        }

        function drag(e) {
            if (!isDragging) return;
            e.preventDefault();
            
            const canvas = document.getElementById('previewCanvas');
            const rect = canvas.getBoundingClientRect();
            
            const clientX = e.type === 'touchmove' ? e.touches[0].clientX : e.clientX;
            const clientY = e.type === 'touchmove' ? e.touches[0].clientY : e.clientY;
            
            let newX = ((clientX - rect.left - dragOffset.x) / rect.width) * 100;
            let newY = ((clientY - rect.top - dragOffset.y) / rect.height) * 100;
            
            // Constrain to canvas bounds
            newX = Math.max(0, Math.min(100, newX));
            newY = Math.max(0, Math.min(100, newY));
            
            dressPosition.x = newX;
            dressPosition.y = newY;
            
            const overlay = document.getElementById('dressOverlay');
            overlay.style.left = newX + '%';
            overlay.style.top = newY + '%';
        }

        function endDrag() {
            isDragging = false;
        }

        // Background removal function
        function removeBackground(imageElement) {
            const canvas = document.createElement('canvas');
            const ctx = canvas.getContext('2d');
            
            canvas.width = imageElement.naturalWidth;
            canvas.height = imageElement.naturalHeight;
            
            ctx.drawImage(imageElement, 0, 0);
            
            const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
            const data = imageData.data;
            
            // Remove white/light background pixels
            for (let i = 0; i < data.length; i += 4) {
                const r = data[i];
                const g = data[i + 1];
                const b = data[i + 2];
                
                // Check if pixel is white or very light
                if (r > 240 && g > 240 && b > 240) {
                    // Make transparent
                    data[i + 3] = 0;
                }
                // Check for light gray backgrounds
                else if (r > 200 && g > 200 && b > 200) {
                    // Make semi-transparent based on lightness
                    const lightness = (r + g + b) / 3;
                    data[i + 3] = Math.max(0, 255 - (lightness - 200) * 5);
                }
            }
            
            ctx.putImageData(imageData, 0, 0);
            return canvas.toDataURL();
        }

        // Download functionality
        function downloadTryOn() {
            const canvas = document.getElementById('previewCanvas');
            const userPhoto = document.getElementById('userPhoto');
            const dressOverlay = document.getElementById('dressOverlay');
            
            if (userPhoto.style.display === 'none') {
                alert('Please upload a photo first');
                return;
            }
            
            // Create a canvas to merge the images
            const mergeCanvas = document.createElement('canvas');
            const ctx = mergeCanvas.getContext('2d');
            
            const canvasRect = canvas.getBoundingClientRect();
            mergeCanvas.width = canvasRect.width * 2;
            mergeCanvas.height = canvasRect.height * 2;
            
            // Draw user photo
            ctx.drawImage(userPhoto, 0, 0, mergeCanvas.width, mergeCanvas.height);
            
            // Use processed dress if background removal is enabled
            const dressToUse = backgroundRemovalEnabled && processedDressSrc ? processedDressSrc : dressOverlay.src;
            const dressImage = new Image();
            dressImage.onload = function() {
                // Draw dress overlay
                const overlayRect = dressOverlay.getBoundingClientRect();
                const relativeX = (overlayRect.left - canvasRect.left) / canvasRect.width;
                const relativeY = (overlayRect.top - canvasRect.top) / canvasRect.height;
                const relativeWidth = overlayRect.width / canvasRect.width;
                const relativeHeight = overlayRect.height / canvasRect.height;
                
                ctx.globalAlpha = dressOverlay.style.opacity || 0.9;
                ctx.drawImage(dressImage, 
                    relativeX * mergeCanvas.width, 
                    relativeY * mergeCanvas.height, 
                    relativeWidth * mergeCanvas.width, 
                    relativeHeight * mergeCanvas.height
                );
                
                // Download
                const link = document.createElement('a');
                link.download = 'try-on-result.png';
                link.href = mergeCanvas.toDataURL('image/png');
                link.click();
            };
            dressImage.src = dressToUse;
        }

        function resetPreview() {
            const userPhoto = document.getElementById('userPhoto');
            const overlay = document.getElementById('dressOverlay');
            const status = document.getElementById('previewStatus');
            const placeholder = document.getElementById('previewPlaceholder');
            const results = document.getElementById('aiResults');
            const controlPanel = document.getElementById('controlPanel');
            const downloadBtn = document.getElementById('downloadBtn');
            document.getElementById('userPhotoInput').value = '';
            userPhoto.src = '';
            userPhoto.style.display = 'none';
            overlay.style.display = 'none';
            placeholder.style.display = 'block';
            controlPanel.style.display = 'none';
            downloadBtn.style.display = 'none';
            
            // Reset controls
            document.getElementById('sizeControl').value = 50;
            document.getElementById('rotationControl').value = 0;
            document.getElementById('opacityControl').value = 90;
            document.getElementById('blendModeControl').value = 'normal';
            document.getElementById('bgRemovalControl').value = 'enabled';
            
            // Reset dress position
            dressPosition = { x: 50, y: 15 };
            overlay.style.left = '50%';
            overlay.style.top = '15%';
            overlay.style.transform = 'translateX(-50%)';
            overlay.style.width = '50%';
            overlay.style.opacity = '0.9';
            overlay.style.mixBlendMode = 'normal';
            
            // Reset dress sources and background removal
            originalDressSrc = '';
            processedDressSrc = '';
            backgroundRemovalEnabled = true;
            
            // Reset overlay to original product image
            overlay.src = '${pageContext.request.contextPath}/product_img/<%= escapedImage %>';
            
            status.innerHTML = '<strong>Ready for your premium style preview</strong><p>Select a photo and tap the scan button to see size, color, and length suggestions.</p>';
            results.innerHTML = '<div class="result-card"><h3>How it works</h3><p>Upload your photo and our optional AI preview will suggest the best match for fit, color tone, and length. This view helps make product choice simple and attractive.</p></div>';
        }

        function runTryOn() {
            const input = document.getElementById('userPhotoInput');
            const file = input.files[0];
            const status = document.getElementById('previewStatus');
            const results = document.getElementById('aiResults');
            const userPhoto = document.getElementById('userPhoto');
            const overlay = document.getElementById('dressOverlay');
            const placeholder = document.getElementById('previewPlaceholder');
            const controlPanel = document.getElementById('controlPanel');
            const downloadBtn = document.getElementById('downloadBtn');

            if (!file) {
                status.innerHTML = '<strong>Please upload a photo first.</strong><p>Choose an image so the AI preview can analyze your look.</p>';
                return;
            }

            if (!selectedProductId) {
                status.innerHTML = '<strong>Product information missing.</strong><p>Please go back and select a product.</p>';
                return;
            }

            // Show loading state
            status.innerHTML = '<strong><i class="fas fa-spinner fa-spin"></i> Analyzing your photo...</strong><p>Our AI is processing your image to provide personalized styling recommendations.</p>';
            results.innerHTML = '<div class="result-card"><p>Processing...</p></div>';

            // Display user photo locally while processing
            const reader = new FileReader();
            reader.onload = function(event) {
                userPhoto.src = event.target.result;
                userPhoto.style.display = 'block';
                
                // Store original dress source
                originalDressSrc = overlay.src;
                
                // Process dress image to remove background for live preview
                const originalDress = new Image();
                originalDress.crossOrigin = 'anonymous';
                originalDress.onload = function() {
                    processedDressSrc = removeBackground(originalDress);
                    
                    // Apply background removal if enabled
                    if (backgroundRemovalEnabled) {
                        overlay.src = processedDressSrc;
                    }
                    
                    overlay.style.display = 'block';
                    placeholder.style.display = 'none';
                    controlPanel.style.display = 'grid';
                    downloadBtn.style.display = 'inline-flex';
                    
                    // Initialize drag and drop
                    initializeDragAndDrop();
                };
                originalDress.src = originalDressSrc;
            };
            reader.readAsDataURL(file);

            // Prepare FormData for multipart upload
            const formData = new FormData();
            formData.append('userPhoto', file);
            formData.append('productId', selectedProductId);

            // Send to server
            fetch('${pageContext.request.contextPath}/aiTryOn', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    status.innerHTML = '<strong>AI analysis complete!</strong><p>Check out the personalized recommendations below.</p>';
                    
                    // Display results
                    let resultHTML = '<div class="result-card">';
                    
                    if (data.bodyAnalysis) {
                        resultHTML += '<h3>Body Analysis & Fit</h3><p>' + data.bodyAnalysis + '</p>';
                    }
                    
                    if (data.styleRecommendation) {
                        resultHTML += '<h3>Style Recommendation</h3><p>' + data.styleRecommendation + '</p>';
                    }
                    
                    resultHTML += '</div>';
                    
                    if (data.outputImage) {
                        resultHTML += '<div class="result-card"><h3>AI-Generated Try-On</h3><img src="' + data.outputImage + '" style="width:100%;border-radius:12px;margin-top:10px;"></div>';
                    }
                    
                    results.innerHTML = resultHTML;
                } else {
                    status.innerHTML = '<strong>Analysis could not complete.</strong><p>' + (data.message || 'Please try with a clearer photo.') + '</p>';
                    results.innerHTML = '<div class="result-card"><p>Note: Basic preview features are available. For advanced AI features, ensure Python environment is configured.</p></div>';
                    
                    // Show fallback recommendations
                    displayFallbackResults(results);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                status.innerHTML = '<strong>Connection error.</strong><p>Please check your connection and try again.</p>';
                
                // Show fallback recommendations
                displayFallbackResults(results);
            });
        }

        function displayFallbackResults(resultsElement) {
            const outcomes = [
                {
                    heading: 'Flattering fall and elegant length',
                    note: 'The selected dress enhances your posture and keeps the length graceful for modern celebrations.',
                    chips: ['Perfect length', 'Color harmony', 'Comfort fit']
                },
                {
                    heading: 'Premium color match for your tone',
                    note: 'Your skin tone pairs beautifully with this shade, creating a polished and confident appearance.',
                    chips: ['Rich contrast', 'Elegant silhouette', 'Smart styling']
                },
                {
                    heading: 'Smart size guidance',
                    note: 'This style suggests a size that supports your proportions while keeping the drape elegant and comfortable.',
                    chips: ['Balanced fit', 'Length confidence', 'Soft drape']
                }
            ];

            const choice = outcomes[Math.floor(Math.random() * outcomes.length)];
            resultsElement.innerHTML = `
                <div class="result-card">
                    <h3>${choice.heading}</h3>
                    <p>${choice.note}</p>
                    <div class="result-chip"><i class="fas fa-check-circle"></i> ${choice.chips[0]}</div>
                    <div class="result-chip"><i class="fas fa-check-circle"></i> ${choice.chips[1]}</div>
                    <div class="result-chip"><i class="fas fa-check-circle"></i> ${choice.chips[2]}</div>
                </div>
            `;
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            initializeProductId();
        });
    </script>
</body>
</html>
