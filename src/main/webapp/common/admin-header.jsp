<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // ====== ADMIN SECURITY GATE (applies to all admin pages) ======
    if (session.getAttribute("user") == null || !Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
        response.sendRedirect(request.getContextPath() + "/adminAuth.jsp");
        return;
    }
    // Session inactivity check (30 min)
    Long lastAccess = (Long) session.getAttribute("lastAccessTime");
    long now = System.currentTimeMillis();
    if (lastAccess != null && (now - lastAccess) > (30 * 60 * 1000L)) {
        session.invalidate();
        response.sendRedirect(request.getContextPath() + "/adminAuth.jsp?error=session_expired");
        return;
    }
    session.setAttribute("lastAccessTime", now);
    // No-cache headers for all admin pages
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    // Determine which sidebar link is active
    String activePage = (String) request.getAttribute("adminActivePage");
    if (activePage == null) activePage = "dashboard";
    String user = session.getAttribute("user") != null ? session.getAttribute("user").toString() : "";
    int pendingOrders = 0;
    try {
        java.sql.Connection chkConn = com.conn.DBConnect.getConn();
        try (java.sql.PreparedStatement psPend = chkConn.prepareStatement("SELECT COUNT(*) FROM orders WHERE status = 'pending'")) {
            try (java.sql.ResultSet rsPend = psPend.executeQuery()) {
                if (rsPend.next()) pendingOrders = rsPend.getInt(1);
            }
        }
        chkConn.close();
    } catch (Exception ignore) {}
%>
<style>
    /* Custom Logo Styles */
    .gilded-stitch-logo {
        display: flex;
        align-items: center;
        gap: 12px;
        font-family: 'Playfair Display', Georgia, serif;
    }
    
    .logo-icon {
        width: 44px;
        height: 44px;
        background: linear-gradient(135deg, #d4af37 0%, #f4e4bc 50%, #d4af37 100%);
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 22px;
        color: #1a1a1a;
        box-shadow: 0 4px 12px rgba(212, 175, 55, 0.3);
        position: relative;
        overflow: hidden;
    }
    
    .logo-icon::before {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: linear-gradient(45deg, transparent, rgba(255,255,255,0.3), transparent);
        transform: rotate(45deg);
        animation: logoShine 3s infinite;
    }
    
    @keyframes logoShine {
        0% { transform: translateX(-100%) rotate(45deg); }
        100% { transform: translateX(100%) rotate(45deg); }
    }
    
    .logo-text {
        font-size: 16px;
        font-weight: 700;
        color: #d4af37;
        letter-spacing: 1px;
        text-transform: uppercase;
        text-shadow: 0 2px 4px rgba(212, 175, 55, 0.2);
    }
    
    .logo-text span {
        color: #f4e4bc;
    }
</style>
<!-- Admin Sidebar -->
<nav class="admin-sidebar" id="adminSidebar">
    <div class="sidebar-brand">
        <div class="gilded-stitch-logo">
            <div class="logo-icon">✦</div>
            <div class="logo-text">Gilded<span>Stitch</span></div>
        </div>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-title">Main</div>
        <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="sidebar-link <%= "dashboard".equals(activePage) ? "active" : "" %>">
            <i class="fas fa-chart-pie"></i> Dashboard
        </a>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-title">Management</div>
        <a href="${pageContext.request.contextPath}/adminDashboard.jsp#products" class="sidebar-link <%= "products".equals(activePage) ? "active" : "" %>">
            <i class="fas fa-box"></i> Products
        </a>
        <a href="${pageContext.request.contextPath}/adminCategories.jsp" class="sidebar-link <%= "categories".equals(activePage) ? "active" : "" %>">
            <i class="fas fa-tags"></i> Categories
        </a>
        <a href="${pageContext.request.contextPath}/adminOrders.jsp" class="sidebar-link <%= "orders".equals(activePage) ? "active" : "" %>">
            <i class="fas fa-shopping-bag"></i> Orders
            <% if (pendingOrders > 0) { %><span class="badge"><%= pendingOrders %></span><% } %>
        </a>
        <a href="${pageContext.request.contextPath}/adminUsers.jsp" class="sidebar-link <%= "users".equals(activePage) ? "active" : "" %>">
            <i class="fas fa-users"></i> Users
        </a>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-title">Actions</div>
        <a href="${pageContext.request.contextPath}/addproduct.jsp" class="sidebar-link <%= "addproduct".equals(activePage) ? "active" : "" %>">
            <i class="fas fa-plus-circle"></i> Add Product
        </a>
    </div>
    <div class="sidebar-section">
        <div class="sidebar-section-title">Frontend</div>
        <a href="${pageContext.request.contextPath}/collections.jsp" class="sidebar-link">
            <i class="fas fa-eye"></i> View Store
        </a>
        <a href="${pageContext.request.contextPath}/dashboard.jsp" class="sidebar-link">
            <i class="fas fa-user"></i> User Dashboard
        </a>
    </div>
    <div class="sidebar-section" style="border-top: 1px solid rgba(255,255,255,0.08); padding-top: 16px; margin-top: 16px;">
        <div style="padding: 12px 16px; background: rgba(255,255,255,0.05); border-radius: 6px; font-size: 11px; color: #94a3b8;">
            <div style="font-weight: 600; margin-bottom: 4px;">🔐 ADMIN MODE</div>
            <div>Email: <%= user %></div>
            <div style="margin-top: 6px; font-size: 10px; color: #64748b;">Restricted Admin Access</div>
        </div>
        <a href="${pageContext.request.contextPath}/LogoutServlet" class="sidebar-link" style="margin-top: 12px;">
            <i class="fas fa-sign-out-alt"></i> Admin Logout
        </a>
    </div>
</nav>

<!-- Admin Main Content Area -->
<div class="admin-main">
    <div class="admin-topbar">
        <div style="display: flex; align-items: center; gap: 12px;">
            <button class="sidebar-toggle" onclick="document.getElementById('adminSidebar').classList.toggle('open')">
                <i class="fas fa-bars"></i>
            </button>
            <h1><%= request.getAttribute("adminPageTitle") != null ? request.getAttribute("adminPageTitle").toString().replaceAll("[<>\"']", "") : "Admin Panel" %></h1>
        </div>
        <div class="user-info">
            <i class="fas fa-user-circle" style="font-size: 20px;"></i>
            <span><%= user != null ? user.toString().replaceAll("[<>\"']", "") : "" %></span>
        </div>
    </div>

    <div class="admin-content">
    </div>
</div>
