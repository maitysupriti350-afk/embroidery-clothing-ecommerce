<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); 
    response.setHeader("Pragma", "no-cache"); 
    response.setHeader("Expires", "0"); 
    if(session.getAttribute("user") == null) {
        response.sendRedirect("auth.jsp");
        return; 
    }
    boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <title>Welcome - THE GILDED STITCH</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&family=Playfair+Display:ital,wght@0,700;1,400&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            /* Sophisticated dark aesthetic */
            background: #A0736B;
            color: #f8fafc;
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* Centering scoped to main content so header/footer keep normal flow */
        .page-center {
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: calc(100vh - 160px);
            padding: 40px 20px;
        }

        /* Background light effect */
        .bg-glow {
            position: absolute;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(255, 182, 193, 0.15) 0%, rgba(15, 23, 42, 0) 70%);
            z-index: -1;
        }

        .welcome-container {
            max-width: 800px;
            padding: 60px;
            background: rgba(30, 41, 59, 0.5);
            backdrop-filter: blur(20px);
            border-radius: 40px;
            border: 1px solid rgba(255, 255, 255, 0.05);
            text-align: center;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            animation: fadeIn 1.2s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .status-badge {
            display: inline-block;
            padding: 8px 20px;
            background: rgba(34, 197, 94, 0.1);
            color: #4ade80;
            border-radius: 100px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 25px;
            border: 1px solid rgba(34, 197, 94, 0.2);
        }

        h1 {
            font-family: 'Playfair Display', serif;
            font-size: 3.5rem;
            margin-bottom: 20px;
            background: linear-gradient(to right, #fff, #94a3b8);
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .brand-story {
            font-size: 1.1rem;
            line-height: 1.8;
            color: #94a3b8;
            margin-bottom: 40px;
            font-style: italic;
        }

        .divider {
            width: 60px;
            height: 2px;
            background: #FFB6C1;
            margin: 0 auto 40px;
        }

        .action-links {
            display: flex;
            justify-content: center;
            gap: 20px;
        }

        .btn {
            padding: 15px 35px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 600;
            transition: 0.4s;
            font-size: 14px;
        }

        .btn-primary {
            background: #FF9FB7;
            color: white;
            box-shadow: 0 10px 20px rgba(255, 159, 183, 0.2);
        }

        .btn-primary:hover {
            background: #FF7A94;
            transform: translateY(-3px);
        }

        .btn-outline {
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: #fff;
        }

        .btn-outline:hover {
            background: rgba(255, 255, 255, 0.05);
            border-color: #fff;
        }

        .footer-tag {
            margin-top: 50px;
            font-size: 12px;
            color: #475569;
            letter-spacing: 4px;
            text-transform: uppercase;
        }
    </style>
</head>
<body>
<jsp:include page="/common/header.jsp" />

        <div class="page-center">
            <div class="bg-glow"></div>

            <div class="welcome-container">
        <span class="status-badge">Login Successful</span>
        
        <h1>Welcome to the Inner Circle</h1>
        
        <div class="divider"></div>
        
        <p class="brand-story">
            "We don't just follow trends; we honor the roots of elegance by blending classic silhouettes with contemporary aesthetics for the discerning individual."
        </p>

        <div class="action-links">
            <a href="${pageContext.request.contextPath}/collections.jsp" class="btn btn-primary">Explore Collections</a>
            <a href="${pageContext.request.contextPath}/cart.jsp" class="btn btn-outline">My Cart</a>
            <a href="${pageContext.request.contextPath}/OrdersServlet" class="btn btn-outline">My Orders</a>
            <a href="${pageContext.request.contextPath}/profile.jsp" class="btn btn-outline">Member Profile</a>
            <% if (isAdmin) { %>
                <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="btn btn-primary" style="background: #ff7f50;">Admin Panel</a>
            <% } %>
            <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn btn-outline" style="border-color: #ff4d4d; color: #ff4d4d;">Logout</a>
        </div>

        <div class="footer-tag">
            Maity's collection | Est. 2026
        </div>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />
</body>
</html>