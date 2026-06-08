<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.io.File" %>
<%@ page import="com.conn.DBConnect" %>
<%
    // HTML-escape helper to prevent XSS
    String searchParam = request.getParameter("search");
    String categoryParam = request.getParameter("category");
    if (searchParam == null) searchParam = "";
    if (categoryParam == null) categoryParam = "";
    String escapedSearch = searchParam.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
<title>The Heritage Gallery - Collections</title>
<!-- FontAwesome 6 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
<style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif; background-color: #f5f5f5; margin: 0; padding: 0; }
    header { text-align: center; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px; margin: 20px auto; max-width: 1400px; }
    
    .filters { 
        max-width: 1200px; 
        margin: 0 auto 30px; 
        display: flex; 
        gap: 20px; 
        align-items: center; 
        justify-content: center; 
        flex-wrap: wrap;
        background: rgba(165, 214, 167, 0.3);
        padding: 20px;
        border-radius: 8px;
    }
    
    .search-box { 
        display: flex; 
        align-items: center; 
        background: white; 
        border-radius: 25px; 
        padding: 10px 20px; 
        box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
    }
    
    .search-box input { 
        border: none; 
        outline: none; 
        padding: 5px; 
        font-size: 16px; 
        width: 250px; 
    }
    
    .search-box button { 
        background: none; 
        border: none; 
        cursor: pointer; 
        color: #ff3f6c; 
        font-size: 18px; 
    }
    
    .category-filter select { 
        padding: 10px 15px; 
        border-radius: 5px; 
        border: 1px solid #ddd; 
        background: white; 
        font-size: 16px; 
    }
    
    .container { 
        display: grid; 
        grid-template-columns: repeat(4, 1fr); 
        gap: 20px; 
        max-width: 1400px; 
        margin: 0 auto; 
        padding: 0 20px 40px;
    }
    
    @media (max-width: 1024px) {
        .container {
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
        }
    }
    
    @media (max-width: 768px) {
        .filters {
            flex-direction: column;
            align-items: stretch;
            margin: 0 20px 20px;
        }
        .search-box input {
            width: 100%;
        }
        .container {
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
            padding: 0 20px 40px;
        }
        header {
            margin: 20px;
            padding: 16px;
        }
    }
    
    @media (max-width: 480px) {
        .container {
            grid-template-columns: 1fr;
            padding: 0 16px 40px;
        }
        
        header {
            margin: 16px;
            padding: 16px;
            border-radius: 12px;
        }
        
        header h1 {
            font-size: 20px;
        }
        
        .filters {
            margin: 0 16px 20px;
            padding: 16px;
            gap: 12px;
        }
        
        .search-box {
            padding: 8px 16px;
        }
        
        .search-box input {
            font-size: 14px;
        }
        
        .category-filter select {
            padding: 8px 12px;
            font-size: 14px;
        }
        
        .collection-card {
            border-radius: 12px;
        }
        
        .image-box {
            height: 220px;
        }
        
        .wishlist-btn {
            width: 40px;
            height: 40px;
            top: 10px;
            right: 10px;
        }
        
        .card-info {
            padding: 12px;
        }
        
        .card-info h3 {
            font-size: 14px;
        }
        
        .price {
            font-size: 15px;
        }
    }
    
    .collection-card { 
        background: white; 
        border-radius: 4px; 
        overflow: hidden; 
        box-shadow: 0 1px 3px rgba(0,0,0,0.08); 
        position: relative; 
        display: flex;
        flex-direction: column;
        transition: box-shadow 0.2s ease;
    }
    
    .collection-card:hover {
        box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    }

    .image-box { 
        width: 100%; 
        padding-bottom: 125%; 
        background: #f8f8f8; 
        display: flex; 
        align-items: center; 
        justify-content: center;
        overflow: hidden; 
        position: relative;
    }

    .image-box img { 
        position: absolute;
        top: 0;
        left: 0;
        width: 100%; 
        height: 100%; 
        object-fit: cover; 
        transition: transform 0.3s ease;
    }

    .collection-card:hover .image-box img {
        transform: scale(1.05);
    }

    .image-box img.img-fallback {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: auto;
        height: auto;
        max-width: 60%;
        max-height: 60%;
        object-fit: contain;
    }

    .wishlist-btn { 
        position: absolute; 
        top: 12px; 
        right: 12px; 
        background: white; 
        border-radius: 50%; 
        width: 36px; 
        height: 36px; 
        display: flex; 
        align-items: center; 
        justify-content: center; 
        cursor: pointer; 
        border: none; 
        box-shadow: 0 1px 4px rgba(0,0,0,0.12); 
        z-index: 10;
        transition: transform 0.2s;
    }
    
    .wishlist-btn:active { transform: scale(0.9); }

    .card-info { padding: 12px; text-align: left; flex-grow: 1; }
    .category { font-size: 10px; color: #ff3f6c; font-weight: 600; text-transform: uppercase; margin: 0 0 6px 0; }
    .card-info h3 { font-size: 14px; margin: 6px 0; color: #282c3f; line-height: 1.4; }
    .price { font-weight: 600; margin: 8px 0; color: #282c3f; font-size: 14px; }
    
    .product-rating {
        display: flex;
        align-items: center;
        gap: 6px;
        margin: 8px 0;
        font-size: 13px;
    }
    
    .product-rating .stars {
        color: #ffc107;
        font-size: 14px;
        letter-spacing: 2px;
    }
    
    .product-rating .rating-value {
        font-weight: 600;
        color: #282c3f;
        min-width: 30px;
    }
    
    .product-rating .review-count {
        color: #999;
        font-size: 12px;
    }

    .product-meta {
        text-align: left;
        margin: 10px 0 0;
        color: #555;
        font-size: 13px;
        line-height: 1.6;
    }
    .product-meta strong { color: #333; }
    
    .form-control { 
        width: 100%; 
        margin-bottom: 8px; 
        border: 1px solid #e0e0e0; 
        border-radius: 4px; 
        padding: 8px; 
        box-sizing: border-box; 
        font-size: 14px;
    }
    
    .btn-group {
        padding: 12px;
        display: block;
        border-top: 1px solid #f0f0f0;
        margin-top: 12px;
    }
    
    .add-btn { 
        width: 100%; 
        background: #ff5da3; 
        color: white; 
        border: none; 
        padding: 12px; 
        border-radius: 4px; 
        cursor: pointer; 
        font-weight: 600; 
        font-size: 14px;
    }
    .add-btn:hover { background: #ff3f6c; }
    
    .add-btn.tryon-btn {
        background: #1b5e20;
        color: #fff;
    }
    .add-btn.tryon-btn:hover {
        background: #145a1c;
    }

    .carousel-container {
        position: relative;
        width: 100%;
        height: 280px;
        overflow: hidden;
        border-radius: 4px;
        background: #f5f5f5;
    }
    .carousel-images {
        display: flex;
        transition: transform 0.3s ease;
        width: 100%;
        height: 100%;
        align-items: center;
        justify-content: center;
    }
    .carousel-images img {
        width: auto;
        max-width: 100%;
        max-height: 100%;
        object-fit: contain;
        flex-shrink: 0;
    }
    .carousel-button {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        width: 38px;
        height: 38px;
        border-radius: 50%;
        border: none;
        background: rgba(255,255,255,0.9);
        box-shadow: 0 2px 10px rgba(0,0,0,0.12);
        cursor: pointer;
        z-index: 10;
        font-size: 18px;
        color: #222;
    }
    .carousel-button.left { left: 12px; }
    .carousel-button.right { right: 12px; }
</style>
</head>
<body>
<jsp:include page="/common/header.jsp" />

<header>
    <h1>The Heritage Gallery</h1>
    <p>Curated with love, women with tradition.</p>
</header>

<div class="tryon-banner">
    <div>
        <span class="badge"><i class="fas fa-magic"></i> AI Try-On</span>
        <h2>See the dress on your photo before you buy</h2>
        <p>Upload a photo or choose any product to preview color, fit, length, and styling guidance in a premium AI try-on experience.</p>
    </div>
    <a class="try-btn" href="${pageContext.request.contextPath}/ai-tryon.jsp">
        <i class="fas fa-eye"></i> Start AI Fit Preview
    </a>
</div>

<div class="filters">
    <form method="get" class="search-box">
        <input type="text" name="search" placeholder="Search products..." value="<%= escapedSearch %>">
        <button type="submit"><i class="fas fa-search"></i></button>
    </form>
    <div class="category-filter">
        <form method="get" style="display: inline;">
            <select name="category" onchange="this.form.submit()">
                <option value="">All Categories</option>
                <option value="Saree" <%= "Saree".equals(categoryParam) ? "selected" : "" %>>Saree</option>
                <option value="Kurti" <%= "Kurti".equals(categoryParam) ? "selected" : "" %>>Kurti</option>
                <option value="Lehenga" <%= "Lehenga".equals(categoryParam) ? "selected" : "" %>>Lehenga</option>
                <option value="Suit" <%= "Suit".equals(categoryParam) ? "selected" : "" %>>Suit</option>
                <option value="Churidar" <%= "Churidar".equals(categoryParam) ? "selected" : "" %>>Churidar</option>
            </select>
            <input type="hidden" name="search" value="<%= escapedSearch %>">
        </form>
    </div>
</div>

<div class="container">
    <%
        // সেশন থেকে ইউজার আইডি নেওয়া (লগইন করা থাকলে)
        Object userObj = session.getAttribute("user");
        String userId = (userObj != null) ? userObj.toString() : null;

        
        String search = searchParam;
        String category = categoryParam;

    
        String sql = "SELECT * FROM products WHERE 1=1";
        if (search != null && !search.trim().isEmpty()) {
            sql += " AND (p_name LIKE ? OR p_desc LIKE ?)";
        }
        if (category != null && !category.trim().isEmpty()) {
            sql += " AND p_category = ?";
        }

        boolean anyShown = false;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement psmt = conn.prepareStatement(sql)) {

            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                psmt.setString(paramIndex++, "%" + search.trim() + "%");
                psmt.setString(paramIndex++, "%" + search.trim() + "%");
            }
            if (category != null && !category.trim().isEmpty()) {
                psmt.setString(paramIndex++, category.trim());
            }

            try (ResultSet rs = psmt.executeQuery()) {

            Set<Integer> seenProductIds = new HashSet<>();
            int productCount = 0;
        while(rs.next()) {
                int pid = rs.getInt("p_id");
                String imgName = rs.getString("p_image");
                if (imgName != null && imgName.toLowerCase().contains(" - copy")) {
                    continue;
                }
                // Skip if product ID has already been shown
                if (seenProductIds.contains(pid)) {
                    continue;
                }
                // Skip first 2 products
                if (productCount < 2) {
                    productCount++;
                    seenProductIds.add(pid);
                    continue;
                }
                productCount++;
                seenProductIds.add(pid);
                // mark that we'll render at least one product
                anyShown = true;
                
                
                boolean isWishlisted = false;
                if (userId != null) {
                    String checkSql = "SELECT * FROM wishlist WHERE user_id = ? AND p_id = ?";
                    try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                        psCheck.setString(1, userId);
                        psCheck.setInt(2, pid);
                        try (ResultSet rsCheck = psCheck.executeQuery()) {
                            if(rsCheck.next()) {
                                isWishlisted = true;
                            }
                        }
                    }
                }
                // Extract product variables
                String productName = rs.getString("p_name");
                String productCategory = rs.getString("p_category");
                String productDesc = rs.getString("p_desc") != null ? rs.getString("p_desc") : "Fine design crafted with care.";
                // Use image directly from database
                String productImage = imgName != null ? imgName : "placeholder.svg";
                String productMade = "Made in 2024";
                String productQuality = "Premium craftsmanship with lasting comfort";
                String productRating = "4.8";
                String reviewCount = "22";
                String encodedName = productName;
                String encodedImage = productImage;
                try {
                    encodedName = java.net.URLEncoder.encode(productName, "UTF-8");
                    encodedImage = java.net.URLEncoder.encode(productImage, "UTF-8");
                } catch (java.io.UnsupportedEncodingException ignored) {}
                String tryOnUrl = request.getContextPath() + "/ai-tryon.jsp?prodName=" + encodedName + "&img=" + encodedImage + "&pid=" + pid;
                if ("Lehenga".equals(productCategory)) { productRating = "4.9"; reviewCount = "48"; }
                else if ("Saree".equals(productCategory)) { productRating = "4.7"; reviewCount = "52"; }
                else if ("Kurti".equals(productCategory)) { productRating = "4.6"; reviewCount = "40"; }
                else if ("Suit".equals(productCategory)) { productRating = "4.8"; reviewCount = "29"; }
                else if ("Churidar".equals(productCategory)) { productRating = "4.5"; reviewCount = "21"; }
    %>
    <div class="collection-card">
        <div class="wishlist-btn" data-pid="<%= pid %>" onclick="toggleWishlist(this.dataset.pid)">
            <%-- উইশলিস্টে থাকলে fa-solid (ভরাট হার্ট), না থাকলে fa-regular (খালি হার্ট) --%>
            <% String heartClass = isWishlisted ? "fa-solid" : "fa-regular"; %>
            <i id="heart-<%= pid %>" class="<%= heartClass %> fa-heart" style="color: red; font-size: 22px;"></i>
        </div>

        <div class="carousel-container">
            <div class="carousel-images" id="carousel-images-<%= pid %>">
                <img src="${pageContext.request.contextPath}/product_img/<%= productImage %>" alt="<%= productName %> - <%= productCategory %> | THE GILDED STITCH Premium Ethnic Wear" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/product_img/placeholder.svg'; this.classList.add('img-fallback');">
            </div>
        </div>

        <div class="card-info">
            <p class="category"><%= productCategory %></p>
            <h3 style="font-size: 16px; margin: 8px 0;"><%= productName %></h3>
            <p class="price">₹ <%= rs.getString("p_price") %></p>
            <div class="product-rating">
                <span class="rating-value"><%= productRating %></span>
                <span class="stars">★★★★★</span>
                <span class="review-count">(<%= reviewCount %>)</span>
            </div>
            <div class="product-meta">
                <strong>Made:</strong> <%= productMade %><br>
                <strong>Quality:</strong> <%= productQuality %><br>
                <strong>Rating:</strong> <%= productRating %> ★ (<%= reviewCount %> reviews)
            </div>
            <p style="margin-top: 10px; color: #555; font-size: 14px;"><%= productDesc %></p>
        </div>

        <!-- Reviews moved to product page -->

        <div class="btn-group" style="padding: 0 15px;">
            <form action="${pageContext.request.contextPath}/AddCartServlet" method="get">
                <input type="hidden" name="pid" value="<%= pid %>">
                <select name="size" class="form-control" required>
                    <option value="S">S</option>
                    <option value="M">M</option>
                    <option value="L">L</option>
                    <option value="XL">XL</option>
                </select>
                <input type="number" name="qty" value="1" min="1" max="10" class="form-control">
                <button type="submit" class="add-btn">Add to Cart</button>
            </form>
            <button type="button" class="add-btn tryon-btn" onclick="window.location.href='<%= tryOnUrl %>'"><i class="fas fa-magic"></i> Try On with AI</button>
        </div>
    </div>
<%
            }  // close while loop
        }  // close try(ResultSet rs)
    } catch(Exception e) {
        e.printStackTrace();
    }
    // If no products were rendered from database, show images from product_img folder
    if (!anyShown) {
        String imgDirPath = application.getRealPath("/product_img");
        File imgDir = new File(imgDirPath != null ? imgDirPath : "");
        if (imgDir.exists() && imgDir.isDirectory()) {
            File[] imgs = imgDir.listFiles(new java.io.FilenameFilter() {
                public boolean accept(File dir, String name) {
                    String ln = name.toLowerCase();
                    if (ln.contains(" - copy")) {
                        return false;
                    }
                    return ln.endsWith(".jpg") || ln.endsWith(".jpeg") || ln.endsWith(".png") || ln.endsWith(".webp") || ln.endsWith(".svg");
                }
            });
            int shown = 0;
            if (imgs != null) {
                for (File img : imgs) {
                    if (shown >= 12) break;
                    String fname = img.getName();
                    String title = fname.replaceAll("[_0-9-]+", " ").replaceAll("\\.[^.]+$", "").trim();
                    String categoryFallback = "Collection";
%>
    <div class="collection-card">
        <div class="carousel-container">
            <div class="carousel-images" id="carousel-images-sample-<%= shown %>">
                <img src="${pageContext.request.contextPath}/product_img/<%= fname %>" alt="<%= title %> - <%= categoryFallback %> | THE GILDED STITCH Premium Ethnic Wear" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/product_img/placeholder.svg'; this.classList.add('img-fallback');">
            </div>
        </div>
        <div class="card-info">
            <p class="category"><%= categoryFallback %></p>
            <h3 style="font-size: 16px; margin: 8px 0;"><%= title %></h3>
            <p class="price">₹ <%= 699 + (shown * 150) %></p>
            <div class="product-rating">
                <span class="rating-value">4.5</span>
                <span class="stars">★★★★★</span>
                <span class="review-count">(12)</span>
            </div>
            <div class="product-meta">
                <strong>Made:</strong> Made in 2024<br>
                <strong>Quality:</strong> Premium craftsmanship<br>
                <strong>Rating:</strong> 4.5 ★ (12 reviews)
            </div>
            <p style="margin-top: 10px; color: #555; font-size: 14px;">High-quality product made for everyday comfort and style.</p>
        </div>
        <!-- Sample reviews moved to product page -->
        <div style="padding: 0 15px;">
            <form action="#" method="get">
                <select name="size" class="form-control" required>
                    <option value="S">S</option>
                    <option value="M">M</option>
                    <option value="L">L</option>
                    <option value="XL">XL</option>
                </select>
                <input type="number" name="qty" value="1" min="1" max="10" class="form-control">
                <button type="button" class="add-btn">Add to Cart</button>
            </form>
            <button type="button" class="add-btn tryon-btn" data-prod-name="<%= java.net.URLEncoder.encode(title, "UTF-8") %>" data-img="<%= java.net.URLEncoder.encode(fname, "UTF-8") %>" data-pid="<%= shown %>" onclick="tryOnAI(this)"><i class="fas fa-magic"></i> Try On with AI</button>
        </div>
    </div>
<%
                    shown++;
                }
            }
        }
    }
    %>
</div>

<script>
function tryOnAI(button) {
    const prodName = button.getAttribute('data-prod-name');
    const img = button.getAttribute('data-img');
    const pid = button.getAttribute('data-pid');
    window.location.href = '${pageContext.request.contextPath}/ai-tryon.jsp?prodName=' + prodName + '&img=' + img + '&pid=' + pid;
}

function toggleWishlist(productId) {
    const icon = document.getElementById('heart-' + productId);
    
    fetch('${pageContext.request.contextPath}/WishlistServlet?p_id=' + productId)
    .then(response => response.text())
    .then(data => {
        const result = data.trim();
        console.log("Server response for ID " + productId + ": " + result);

        if (result === "added") {
            icon.classList.remove('fa-regular');
            icon.classList.add('fa-solid');
            icon.style.fontWeight = "900"; 
            icon.style.color = "red";
        } else if (result === "removed") {
            icon.classList.remove('fa-solid');
            icon.classList.add('fa-regular');
            icon.style.fontWeight = "400"; 
            icon.style.color = "red"; 
        } else if (result === "notlogin") {
            alert("Please login first!");
            window.location.href = "index.jsp";
        }
    })
    .catch(err => console.error("Error:", err));
}

function shiftCarousel(productId, direction) {
    const carousel = document.getElementById('carousel-images-' + productId);
    if (!carousel) return;
    const images = carousel.querySelectorAll('img');
    const currentIndex = Number(carousel.dataset.index || 0);
    let nextIndex = currentIndex + direction;
    if (nextIndex < 0) nextIndex = images.length - 1;
    if (nextIndex >= images.length) nextIndex = 0;
    carousel.dataset.index = nextIndex;
    carousel.style.transform = 'translateX(' + (-nextIndex * 100) + '%)';
}

function setRating(productId, rating) {
    const buttons = document.querySelectorAll('#review-panel-' + productId + ' .star-button');
    buttons.forEach(btn => {
        if (Number(btn.dataset.rating) <= rating) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });
    const hidden = document.getElementById('rating-value-' + productId);
    if (hidden) hidden.value = rating;
}

function submitReview(productId) {
    const ratingValue = Number(document.getElementById('rating-value-' + productId).value || 0);
    const reviewText = document.getElementById('review-text-' + productId).value.trim();
    const feedback = document.getElementById('review-feedback-' + productId);

    if (ratingValue < 1) {
        feedback.textContent = 'Please choose a star rating before submitting.';
        feedback.style.color = '#b91c1c';
        return;
    }
    if (!reviewText) {
        feedback.textContent = 'Please write a short review to help other customers.';
        feedback.style.color = '#b91c1c';
        return;
    }

    // POST to servlet
    const body = new URLSearchParams();
    body.append('p_id', productId);
    body.append('rating', ratingValue);
    body.append('comment', reviewText);

    fetch('${pageContext.request.contextPath}/AddReviewServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: body.toString()
    }).then(r => r.text()).then(txt => {
        if (txt && txt.trim() === 'success') {
            feedback.textContent = 'Thank you! Your review was saved.';
            feedback.style.color = '#16a34a';
            document.getElementById('review-text-' + productId).value = '';
            setRating(productId, ratingValue);
            fetchReviews(productId);
        } else {
            feedback.textContent = 'Could not save review. Please try again later.';
            feedback.style.color = '#b91c1c';
            console.error('AddReviewServlet response:', txt);
        }
    }).catch(err => {
        feedback.textContent = 'Network error. Please try again.';
        feedback.style.color = '#b91c1c';
        console.error('submitReview error', err);
    });
}

</script>
<jsp:include page="/common/footer.jsp" />
</body>
</html>