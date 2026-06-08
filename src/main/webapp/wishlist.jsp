<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.conn.DBConnect" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("auth.jsp");
        return;
    }
    String userId = session.getAttribute("user").toString();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
<title>My Wishlist - The Heritage Gallery</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
<style>
    body { font-family: 'Poppins', sans-serif; background-color: #FFB6C1; margin: 0; padding: 0; }
    header { text-align: center; padding: 30px 20px; }
    
   
    .container { 
        display: grid; 
        grid-template-columns: repeat(4, 1fr); 
        gap: 20px; 
        max-width: 1400px; 
        margin: 0 auto; 
        padding: 20px;
    }
    
    .collection-card { 
        background: white; 
        border-radius: 12px; 
        overflow: hidden; 
        box-shadow: 0 2px 12px rgba(0,0,0,0.08); 
        position: relative; 
        display: flex;
        flex-direction: column;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .collection-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 24px rgba(0,0,0,0.12);
    }

    .image-box { 
        width: 100%; 
        padding-bottom: 125%; 
        position: relative;
        background: #f8f8f8;
        overflow: hidden; 
    }

    .image-box img { 
        position: absolute;
        top: 0;
        left: 0;
        width: 100%; 
        height: 100%; 
        object-fit: cover; 
    }

    
    .remove-btn { 
        position: absolute; 
        top: 10px; 
        right: 10px; 
        background: rgba(255, 255, 255, 0.9); 
        border-radius: 50%; 
        width: 35px; 
        height: 35px; 
        display: flex; 
        align-items: center; 
        justify-content: center; 
        cursor: pointer; 
        border: none; 
        z-index: 10;
        color: #ff3f6c;
    }

    .card-info { padding: 12px; text-align: left; flex-grow: 1; }
    .category { font-size: 10px; color: #ff3f6c; font-weight: bold; text-transform: uppercase; margin: 0; }
    .product-name { font-size: 14px; margin: 5px 0; color: #333; font-weight: 500; }
    .price { font-weight: bold; font-size: 15px; margin: 5px 0; color: #222; }

    .move-btn { 
        width: 100%; 
        background: white; 
        color: #ff3f6c; 
        border: 1px solid #ff3f6c; 
        padding: 10px; 
        cursor: pointer; 
        font-weight: bold; 
        font-size: 13px;
        text-transform: uppercase;
        margin-top: auto;
    }
    .move-btn:hover { background: #ff3f6c; color: white; }

    @media (max-width: 1200px) { .container { grid-template-columns: repeat(3, 1fr); } }
    @media (max-width: 900px) { .container { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 600px) { .container { grid-template-columns: 1fr; } }

    /* Enhanced Mobile Styles */
    @media (max-width: 768px) {
        body {
            padding: 0;
        }
        
        header {
            padding: 20px 16px;
        }
        
        header h1 {
            font-size: 24px;
        }
        
        header p {
            font-size: 14px;
        }
        
        .container {
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
            padding: 16px;
        }
        
        .collection-card {
            border-radius: 12px;
        }
        
        .image-box {
            padding-bottom: 125%;
        }
        
        .remove-btn {
            width: 40px;
            height: 40px;
            top: 8px;
            right: 8px;
        }
        
        .card-info {
            padding: 16px;
        }
        
        .category {
            font-size: 11px;
        }
        
        .product-name {
            font-size: 15px;
        }
        
        .price {
            font-size: 16px;
        }
        
        .move-btn {
            padding: 12px 16px;
            font-size: 14px;
        }
    }

    @media (max-width: 480px) {
        header h1 {
            font-size: 20px;
        }
        
        header p {
            font-size: 13px;
        }
        
        .container {
            grid-template-columns: 1fr;
            gap: 12px;
            padding: 12px;
        }
        
        .remove-btn {
            width: 36px;
            height: 36px;
        }
        
        .card-info {
            padding: 12px;
        }
        
        .product-name {
            font-size: 14px;
        }
        
        .price {
            font-size: 15px;
        }
        
        .move-btn {
            padding: 10px 14px;
            font-size: 13px;
        }
    }
</style>
</head>
<body>

<header>
    <h1>My Wishlist ❤️</h1>
    <p>Your curated traditional favorites.</p>
</header>

<jsp:include page="/common/header.jsp" />

<div class="container">
    <%
        try (Connection conn = DBConnect.getConn();
             PreparedStatement psmt = conn.prepareStatement("SELECT p.* FROM products p JOIN wishlist w ON p.p_id = w.p_id WHERE w.user_id = ?")) {
            psmt.setString(1, userId);
            try (ResultSet rs = psmt.executeQuery()) {
                boolean hasItems = false;
                while(rs.next()) {
                    hasItems = true;
                    int pid = rs.getInt("p_id");
                    String imgName = rs.getString("p_image");
    %>
    <div class="collection-card" id="card-<%= pid %>">

        <button class="remove-btn" data-pid="<%= pid %>" onclick="removeFromWishlist(this.dataset.pid)">
            <i class="fa-solid fa-trash-can"></i>
        </button>

        <div class="image-box">
            <img src="${pageContext.request.contextPath}/product_img/<%= imgName %>" alt="<%= rs.getString("p_name").replaceAll("[<>\"']", "") %>" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/product_img/placeholder.svg';">
        </div>

        <div class="card-info">
            <p class="category"><%= rs.getString("p_category").replaceAll("[<>\"']", "") %></p>
            <h3 class="product-name"><%= rs.getString("p_name").replaceAll("[<>\"']", "") %></h3>
            <p class="price">₹ <%= rs.getString("p_price") %></p>
        </div>

        <a href="${pageContext.request.contextPath}/AddCartServlet?pid=<%= pid %>&size=M&qty=1&removeWishlist=true" class="move-btn">Move to Bag</a>
    </div>
    <%
                }
                if (!hasItems) {
    %>
        <div style="grid-column: 1/-1; text-align: center; color: #666;">Your wishlist is empty. Add favorite products to save them here.</div>
    <%
                }
            }
        } catch(Exception e) {
    %>
        <div style="grid-column: 1/-1; text-align: center; color: #d32f2f;">Error loading wishlist: <%= e.getMessage() %></div>
    <%
        }
    %>
</div>

<script>
function removeFromWishlist(productId) {
    fetch('${pageContext.request.contextPath}/WishlistServlet?p_id=' + productId)
    .then(response => response.text())
    .then(data => {
        if (data.trim() === "removed") {
            document.getElementById('card-' + productId).remove();
        }
    });
}
</script>
<jsp:include page="/common/footer.jsp" />
</body>
</html>