<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.conn.DBConnect" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.UUID" %>
<%
    // ========== SECURITY LAYER 1: Session Existence Check ==========
    if (session.getAttribute("user") == null) {
        response.sendRedirect("auth.jsp");
        return;
    }
    
    // ========== SECURITY LAYER 2: Admin Role Verification ==========
    Boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    if (!isAdmin) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    // ========== SECURITY LAYER 3: Session Inactivity Timeout (30 min) ==========
    Long lastAccess = (Long) session.getAttribute("lastAccessTime");
    long now = System.currentTimeMillis();
    long SESSION_TIMEOUT_MS = 30 * 60 * 1000; // 30 minutes
    if (lastAccess != null && (now - lastAccess) > SESSION_TIMEOUT_MS) {
        session.invalidate();
        response.sendRedirect("adminAuth.jsp?error=session_expired");
        return;
    }
    session.setAttribute("lastAccessTime", now);
    
    // ========== SECURITY LAYER 4: IP Address Binding ==========
    String currentIP = request.getRemoteAddr();
    String sessionIP = (String) session.getAttribute("adminIP");
    if (sessionIP == null) {
        session.setAttribute("adminIP", currentIP);
    } else if (!sessionIP.equals(currentIP)) {
        // IP changed mid-session — possible session hijacking
        session.invalidate();
        response.sendRedirect("adminAuth.jsp?error=ip_mismatch");
        return;
    }
    
    // ========== SECURITY LAYER 5: CSRF Token ==========
    String csrfToken = UUID.randomUUID().toString();
    session.setAttribute("csrfToken", csrfToken);
    
    // ========== SECURITY LAYER 6: No-Cache Headers ==========
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    response.setHeader("X-Content-Type-Options", "nosniff");
    response.setHeader("X-Frame-Options", "DENY");
    response.setHeader("X-XSS-Protection", "1; mode=block");
    response.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
    response.setHeader("Content-Security-Policy", "frame-ancestors 'none'");

    // Set active page for sidebar highlight
    request.setAttribute("adminActivePage", "dashboard");
    request.setAttribute("adminPageTitle", "Dashboard");

    // Fetch statistics
    int totalProducts = 0, totalOrders = 0, totalUsers = 0, pendingOrders = 0;
    BigDecimal totalRevenue = BigDecimal.ZERO;
    java.util.Map<String, Integer> categoryCounts = new java.util.HashMap<>();

    try (Connection conn = DBConnect.getConn()) {
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM products");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) totalProducts = rs.getInt(1);
        }
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM orders");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) totalOrders = rs.getInt(1);
        }
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM user");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) totalUsers = rs.getInt(1);
        }
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM orders WHERE status = 'pending'");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) pendingOrders = rs.getInt(1);
        }
        try (PreparedStatement ps = conn.prepareStatement("SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE status != 'cancelled'");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) totalRevenue = rs.getBigDecimal(1);
        }
        
        // Fetch product counts by category from database
        try (PreparedStatement ps = conn.prepareStatement("SELECT c.category_name, COUNT(p.p_id) as count FROM categories c LEFT JOIN products p ON c.category_id = p.category_id GROUP BY c.category_id, c.category_name ORDER BY c.display_order");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                categoryCounts.put(rs.getString("category_name"), rs.getInt("count"));
            }
        } catch (Exception e) {
            // Fallback: If categories table doesn't exist, use hardcoded category counting
            try {
                String[] categories = {"Saree", "Kurti", "Lehenga", "Suit", "Churidar"};
                for (String cat : categories) {
                    try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM products WHERE LOWER(p_category) LIKE ?")) {
                        ps.setString(1, "%" + cat.toLowerCase() + "%");
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                categoryCounts.put(cat, rs.getInt(1));
                            }
                        }
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ADMIN PANEL - THE GILDED STITCH</title>
<jsp:include page="/common/admin-style.jsp" />
<style>
    body::before {
        display: none;
    }
    
    /* Simple, Unique & Colorful Admin Dashboard */
    .dashboard-container {
        max-width: 100%;
        margin: 0;
        padding: 0 0 60px 0;
        background: #f0f2f5;
        min-height: 100vh;
        position: relative;
    }
    
    /* Dashboard Header */
    .dashboard-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 44px 48px;
        margin: 0 0 32px 0;
        border-radius: 0;
        border: none;
        box-shadow: 0 4px 20px rgba(102,126,234,0.25);
        position: relative;
        overflow: hidden;
        z-index: 1;
    }
    
    .dashboard-header h1 {
        font-size: 34px;
        font-weight: 800;
        margin: 0 0 10px 0;
        display: flex;
        align-items: center;
        gap: 16px;
        position: relative;
        z-index: 1;
        color: white;
        letter-spacing: -0.5px;
    }
    
    .dashboard-header p {
        font-size: 16px;
        opacity: 0.9;
        margin: 0;
        position: relative;
        z-index: 1;
        font-weight: 500;
        color: rgba(255,255,255,0.92);
    }
    
    /* Statistics Grid */
    .stat-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 24px;
        margin-bottom: 32px;
        padding: 0 32px;
        position: relative;
        z-index: 1;
    }
    
    .stat-card {
        border-radius: 16px;
        padding: 28px 32px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.08);
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
        border: none;
    }
    
    .stat-card:nth-child(1) {
        background: linear-gradient(135deg, #ff6b9d 0%, #ff8a80 100%);
        color: white;
    }
    .stat-card:nth-child(2) {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
    }
    .stat-card:nth-child(3) {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        color: white;
    }
    .stat-card:nth-child(4) {
        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        color: white;
    }
    .stat-card:nth-child(5) {
        background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
        color: white;
    }
    
    .stat-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 12px 35px rgba(0,0,0,0.18);
    }
    
    .stat-card-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 18px;
        position: relative;
        z-index: 1;
    }
    
    .stat-icon {
        width: 56px;
        height: 56px;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        transition: all 0.3s ease;
        background: rgba(255,255,255,0.25) !important;
        color: white !important;
    }
    
    .stat-card:hover .stat-icon {
        transform: scale(1.1);
        background: rgba(255,255,255,0.35) !important;
    }
    
    .stat-value {
        font-size: 38px;
        font-weight: 900;
        margin-bottom: 6px;
        position: relative;
        z-index: 1;
        color: white !important;
        -webkit-text-fill-color: white !important;
        background: none !important;
    }
    
    .stat-label {
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1.5px;
        position: relative;
        z-index: 1;
        color: rgba(255,255,255,0.88) !important;
    }
    
    /* Section Cards - Clean & Simple */
    .section-card {
        background: #ffffff;
        border-radius: 14px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.06);
        border: 1px solid #e8e8e8;
        border-left: 5px solid #667eea;
        margin: 0 32px 28px;
        overflow: hidden;
        transition: all 0.3s ease;
        position: relative;
        z-index: 1;
    }
    
    .section-card:hover {
        box-shadow: 0 8px 28px rgba(0,0,0,0.1);
        transform: translateY(-2px);
    }
    
    .section-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 22px 28px;
        border-bottom: 1px solid #f0f0f0;
        background: #fafbfc;
    }
    
    .section-header h2 {
        font-size: 20px;
        font-weight: 800;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 12px;
        color: #2d3436;
        -webkit-text-fill-color: #2d3436;
        background: none;
    }
    
    .section-header a {
        background: #667eea;
        color: white;
        padding: 10px 22px;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 700;
        font-size: 14px;
        transition: all 0.3s ease;
        box-shadow: none;
        border: none;
    }
    
    .section-header a:hover {
        background: #5a6fd6;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(102,126,234,0.3);
    }
    
    /* Table Styles */
    .section-card table {
        width: 100%;
        border-collapse: collapse;
    }
    
    .section-card thead {
        background: #f8f9fa;
    }
    
    .section-card th {
        padding: 16px 24px;
        text-align: left;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        border-bottom: 2px solid #e9ecef;
        color: #495057;
        -webkit-text-fill-color: #495057;
        background: none;
    }
    
    .section-card td {
        padding: 16px 24px;
        border-bottom: 1px solid #f1f3f5;
        font-size: 14px;
        color: #2d3436;
        font-weight: 500;
    }
    
    .section-card tbody tr {
        transition: all 0.2s ease;
    }
    
    .section-card tbody tr:hover {
        background: #f8f9ff;
    }
    
    .section-card tbody tr:last-child td {
        border-bottom: none;
    }
    
    /* Action Links */
    .action-links a {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        border-radius: 8px;
        text-decoration: none;
        font-size: 13px;
        font-weight: 600;
        transition: all 0.2s ease;
        margin-right: 6px;
    }
    
    .action-links a:not(.delete) {
        background: #667eea;
        color: white;
        box-shadow: none;
    }
    
    .action-links a:not(.delete):hover {
        background: #5a6fd6;
        transform: translateY(-2px);
        box-shadow: 0 4px 10px rgba(102,126,234,0.25);
    }
    
    .action-links a.delete {
        background: #f5576c;
        color: white;
        box-shadow: none;
    }
    
    .action-links a.delete:hover {
        background: #e04658;
        transform: translateY(-2px);
        box-shadow: 0 4px 10px rgba(245,87,108,0.25);
    }
    
    /* Status Badges */
    .status-badge {
        display: inline-block;
        padding: 5px 14px;
        border-radius: 20px;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .status-pending { background: #fff3cd; color: #856404; }
    .status-confirmed { background: #d1ecf1; color: #0c5460; }
    .status-shipped { background: #d4edda; color: #155724; }
    .status-delivered { background: #e2d5f1; color: #5b2d8e; }
    .status-cancelled { background: #f8d7da; color: #721c24; }
    .status-paid { background: #d4edda; color: #155724; }
    .status-unpaid { background: #f8d7da; color: #721c24; }
    
    /* Category Cards */
    .category-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 20px;
        margin-bottom: 32px;
        padding: 0 32px;
    }
    
    .category-card {
        border-radius: 16px;
        padding: 32px;
        box-shadow: 0 2px 12px rgba(0,0,0,0.06);
        transition: all 0.3s ease;
        text-align: center;
        cursor: pointer;
        position: relative;
        overflow: hidden;
        border: 1px solid #e8e8e8;
    }
    
    .category-card:nth-child(1) {
        background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
    }
    .category-card:nth-child(2) {
        background: linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%);
    }
    .category-card:nth-child(3) {
        background: linear-gradient(135deg, #fad0c4 0%, #ffd1ff 100%);
    }
    .category-card:nth-child(4) {
        background: linear-gradient(135deg, #89f7fe 0%, #66a6ff 100%);
    }
    .category-card:nth-child(5) {
        background: linear-gradient(135deg, #fddb92 0%, #d1fdff 100%);
    }
    
    .category-card:hover {
        transform: translateY(-6px);
        box-shadow: 0 10px 28px rgba(0,0,0,0.12);
    }
    
    .category-icon {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 28px;
        margin: 0 auto 18px auto;
        position: relative;
        z-index: 1;
        transition: all 0.3s ease;
        background: rgba(255,255,255,0.5) !important;
        color: #2d3436 !important;
    }
    
    .category-card:hover .category-icon {
        transform: scale(1.1);
        background: rgba(255,255,255,0.7) !important;
    }
    
    .category-value {
        font-size: 40px;
        font-weight: 900;
        margin-bottom: 10px;
        position: relative;
        z-index: 1;
        color: #2d3436 !important;
        -webkit-text-fill-color: #2d3436 !important;
        background: none !important;
    }
    
    .category-label {
        font-size: 13px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1.5px;
        position: relative;
        z-index: 1;
        color: rgba(0,0,0,0.65);
    }
    
    .category-card .click-hint {
        font-size: 12px;
        margin-top: 14px;
        opacity: 0;
        transition: opacity 0.3s ease;
        position: relative;
        z-index: 1;
        font-weight: 600;
        color: rgba(0,0,0,0.55);
    }
    
    .category-card:hover .click-hint {
        opacity: 1;
    }
    
    /* Modal Styles */
    .category-modal {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.4);
        z-index: 10000;
        align-items: center;
        justify-content: center;
    }
    
    .category-modal.show {
        display: flex;
    }
    
    .modal-content {
        background: #ffffff;
        border-radius: 20px;
        padding: 40px;
        max-width: 480px;
        width: 90%;
        box-shadow: 0 20px 60px rgba(0,0,0,0.2);
        animation: modalSlideIn 0.4s ease;
        border: 1px solid #e8e8e8;
    }
    
    @keyframes modalSlideIn {
        from {
            transform: translateY(-40px);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
    }
    
    .modal-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 28px;
        padding-bottom: 20px;
        border-bottom: 2px solid #f0f0f0;
    }
    
    .modal-header h3 {
        font-size: 24px;
        font-weight: 800;
        color: #2d3436;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 14px;
    }
    
    .modal-close {
        background: #f8f9fa;
        border: 1px solid #e9ecef;
        width: 44px;
        height: 44px;
        border-radius: 50%;
        cursor: pointer;
        font-size: 20px;
        color: #667eea;
        transition: all 0.3s ease;
    }
    
    .modal-close:hover {
        background: #f5576c;
        color: white;
        border-color: #f5576c;
        transform: rotate(90deg);
    }
    
    .modal-body {
        text-align: center;
    }
    
    .modal-count {
        font-size: 72px;
        font-weight: 900;
        margin-bottom: 12px;
        color: #667eea;
        -webkit-text-fill-color: #667eea;
        background: none;
    }
    
    .modal-label {
        font-size: 17px;
        color: #636e72;
        font-weight: 600;
    }
    
    .modal-icon {
        width: 90px;
        height: 90px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 40px;
        margin: 0 auto 24px auto;
        background: #f0f2ff;
    }
    
    /* Welcome Animation */
    .welcome-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        z-index: 99999;
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0;
        visibility: hidden;
        transition: all 0.5s ease;
    }
    
    .welcome-overlay.show {
        opacity: 1;
        visibility: visible;
    }
    
    .welcome-content {
        text-align: center;
        color: white;
        animation: welcomeFadeIn 0.8s ease;
    }
    
    @keyframes welcomeFadeIn {
        from {
            transform: translateY(30px);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
    }
    
    .welcome-icon {
        font-size: 100px;
        margin-bottom: 28px;
        animation: flowerBloom 2s ease-in-out infinite;
    }
    
    @keyframes flowerBloom {
        0%, 100% { transform: scale(1) rotate(0deg); }
        25% { transform: scale(1.1) rotate(8deg); }
        50% { transform: scale(1) rotate(0deg); }
        75% { transform: scale(1.1) rotate(-8deg); }
    }
    
    .welcome-title {
        font-size: 48px;
        font-weight: 900;
        margin-bottom: 18px;
        letter-spacing: -1px;
    }
    
    .welcome-subtitle {
        font-size: 18px;
        margin-bottom: 40px;
        opacity: 0.92;
        font-weight: 500;
    }
    
    .welcome-btn {
        background: white;
        color: #667eea;
        padding: 16px 44px;
        border: none;
        border-radius: 10px;
        font-size: 18px;
        font-weight: 800;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 0 4px 15px rgba(0,0,0,0.15);
    }
    
    .welcome-btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(0,0,0,0.2);
    }
    
    .flower-particles {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        pointer-events: none;
    }
    
    .flower-particle {
        position: absolute;
        font-size: 28px;
        animation: flowerFall linear infinite;
    }
    
    @keyframes flowerFall {
        0% { transform: translateY(-100px) rotate(0deg); opacity: 1; }
        100% { transform: translateY(100vh) rotate(360deg); opacity: 0; }
    }
    
    /* Message Bars */
    .msg-bar {
        padding: 16px 24px;
        border-radius: 10px;
        margin: 0 32px 20px;
        display: flex;
        align-items: center;
        gap: 12px;
        font-weight: 600;
        position: relative;
        z-index: 1;
    }
    
    .msg-bar.msg-success {
        background: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }
    
    .msg-bar.msg-error {
        background: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }
    
    /* Sales Report Section Special Styles */
    .sales-report-section {
        background: #ffffff;
    }
    
    .sales-report-output {
        padding: 28px 32px;
        background: #1a1a2e;
        margin: 20px 24px 24px;
        border-radius: 12px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        font-family: 'Courier New', monospace;
        font-size: 14px;
        line-height: 2;
        color: #00ff88;
        overflow-x: auto;
        border: 1px solid #2d2d44;
    }
    
    .sales-report-output div {
        padding: 4px 0;
        border-bottom: 1px solid rgba(255,255,255,0.05);
        white-space: pre-wrap;
    }
    
    .sales-placeholder {
        padding: 50px;
        text-align: center;
    }
    
    .sales-placeholder i {
        font-size: 60px;
        margin-bottom: 18px;
        color: #667eea;
        opacity: 0.5;
    }
    
    .sales-placeholder p {
        color: #636e72;
        font-weight: 600;
    }
    
    /* Responsive Design */
    @media (max-width: 1200px) {
        .stat-grid { grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); }
    }
    
    @media (max-width: 768px) {
        .stat-grid { grid-template-columns: 1fr 1fr; }
        .dashboard-header { padding: 32px 24px; }
        .dashboard-header h1 { font-size: 26px; }
        .section-header { flex-direction: column; align-items: flex-start; gap: 14px; }
        .section-header a { width: 100%; text-align: center; }
        .stat-grid, .category-grid { padding: 0 16px; }
        .section-card { margin: 0 16px 20px; }
    }
    
    @media (max-width: 480px) {
        .stat-grid { grid-template-columns: 1fr; }
        .stat-card { padding: 24px; }
        .stat-value { font-size: 34px; }
        .dashboard-header h1 { font-size: 22px; }
        .welcome-title { font-size: 34px; }
        .welcome-subtitle { font-size: 15px; }
    }
    
    /* Security Badge */
    .security-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: rgba(255,255,255,0.2);
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 11px;
        font-weight: 600;
        margin-left: 12px;
    }
</style>
<script>
    // Category Modal Functions
    const categoryConfig = {
        saree: { icon: 'fas fa-user-tie', label: 'Sarees', color: '#be185d', bgClass: 'saree' },
        kurti: { icon: 'fas fa-tshirt', label: 'Kurtis', color: '#7c3aed', bgClass: 'kurti' },
        suits: { icon: 'fas fa-vest', label: 'Suits', color: '#2563eb', bgClass: 'suits' },
        lehenga: { icon: 'fas fa-crown', label: 'Lehengas', color: '#d97706', bgClass: 'lehenga' }
    };

    // Add click event listeners to category cards
    document.addEventListener('DOMContentLoaded', function() {
        const categoryCards = document.querySelectorAll('.category-card');
        categoryCards.forEach(card => {
            card.addEventListener('click', function() {
                const category = this.getAttribute('data-category');
                const count = this.getAttribute('data-count');
                showCategoryModal(category, count);
            });
        });

        // Show welcome animation
        setTimeout(() => {
            const welcomeOverlay = document.getElementById('welcomeOverlay');
            if (welcomeOverlay) {
                welcomeOverlay.classList.add('show');
                createFlowerParticles();
            }
        }, 500);
    });

    function showCategoryModal(category, count) {
        const modal = document.getElementById('categoryModal');
        const config = categoryConfig[category];
        
        document.getElementById('modalTitle').innerHTML = `<i class="${config.icon}"></i> ${config.label} Details`;
        document.getElementById('modalIcon').innerHTML = `<i class="${config.icon}"></i>`;
        document.getElementById('modalIcon').className = `modal-icon ${config.bgClass}`;
        document.getElementById('modalCount').textContent = count;
        document.getElementById('modalCount').style.color = config.color;
        document.getElementById('modalLabel').textContent = `${config.label} Available`;
        
        modal.classList.add('show');
    }

    function closeCategoryModal() {
        const modal = document.getElementById('categoryModal');
        modal.classList.remove('show');
    }

    // Close modal when clicking outside
    document.getElementById('categoryModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeCategoryModal();
        }
    });

    // Welcome Animation Functions
    function closeWelcome() {
        const welcomeOverlay = document.getElementById('welcomeOverlay');
        welcomeOverlay.classList.remove('show');
    }

    function createFlowerParticles() {
        const container = document.getElementById('flowerParticles');
        const flowers = ['🌸', '🌺', '🌻', '🌷', '🌹', '💐', '🌼', '🌿'];
        
        for (let i = 0; i < 15; i++) {
            setTimeout(() => {
                const particle = document.createElement('div');
                particle.className = 'flower-particle';
                particle.textContent = flowers[Math.floor(Math.random() * flowers.length)];
                particle.style.left = Math.random() * 100 + '%';
                particle.style.animationDuration = (Math.random() * 3 + 4) + 's';
                particle.style.animationDelay = Math.random() * 2 + 's';
                container.appendChild(particle);
                
                // Remove particle after animation
                setTimeout(() => {
                    particle.remove();
                }, 8000);
            }, i * 200);
        }
    }
</script>
</head>
<body>

<jsp:include page="/common/admin-header.jsp" />

<div class="dashboard-container">
    <% String successMessage = (String) session.getAttribute("succMsg");
       String failedMessage = (String) session.getAttribute("failedMsg");
       if (successMessage != null) { %>
    <div class="msg-bar msg-success">
        <i class="fas fa-check-circle"></i> <%= successMessage %>
    </div>
    <% session.removeAttribute("succMsg"); }
       if (failedMessage != null) { %>
    <div class="msg-bar msg-error">
        <i class="fas fa-exclamation-circle"></i> <%= failedMessage %>
    </div>
    <% session.removeAttribute("failedMsg"); } %>

    <!-- Dashboard Header -->
    <div class="dashboard-header">
        <h1><i class="fas fa-sparkles"></i> Dashboard Overview ✨</h1>
        <p>Welcome back, beautiful admin! Here's what's happening with your store today 💖</p>
    </div>

    <!-- Statistics -->
    <div class="stat-grid">
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-icon products"><i class="fas fa-box"></i></div>
            </div>
            <div class="stat-value"><%= totalProducts %></div>
            <div class="stat-label">Total Products</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-icon orders"><i class="fas fa-shopping-bag"></i></div>
            </div>
            <div class="stat-value"><%= totalOrders %></div>
            <div class="stat-label">Total Orders</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-icon pending"><i class="fas fa-clock"></i></div>
            </div>
            <div class="stat-value"><%= pendingOrders %></div>
            <div class="stat-label">Pending Orders</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-icon users"><i class="fas fa-users"></i></div>
            </div>
            <div class="stat-value"><%= totalUsers %></div>
            <div class="stat-label">Registered Users</div>
        </div>
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-icon revenue"><i class="fas fa-indian-rupee-sign"></i></div>
            </div>
            <div class="stat-value"><%= totalRevenue %></div>
            <div class="stat-label">Total Revenue</div>
        </div>
    </div>

    <!-- Sales Report Button and Display Section -->
    <div class="section-card sales-report-section">
        <div class="section-header" style="background: linear-gradient(135deg, rgba(67,233,123,0.1) 0%, rgba(56,249,215,0.1) 100%);">
            <h2><i class="fas fa-chart-line" style="color: #38f9d7; -webkit-text-fill-color: #38f9d7;"></i> Sales Analytics Report</h2>
            <a href="${pageContext.request.contextPath}/AdminSalesReportServlet" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); box-shadow: 0 8px 25px rgba(67,233,123,0.35);">
                <i class="fas fa-file-invoice-dollar"></i> View Sales Report
            </a>
        </div>
        
        <% 
            // Display analytics data if available
            java.util.List<String> analyticsData = (java.util.List<String>) request.getAttribute("analyticsData");
            if (analyticsData != null && !analyticsData.isEmpty()) {
        %>
        <div class="sales-report-output">
            <% for (String line : analyticsData) { %>
                <div><%= line %></div>
            <% } %>
        </div>
        <% } else { %>
        <div class="sales-placeholder">
            <i class="fas fa-chart-bar"></i>
            <p style="font-size: 17px; margin: 0;">Click the button above to generate your sales analytics report</p>
            <p style="font-size: 13px; margin-top: 10px; opacity: 0.7;">The report will show order details, revenue, and business insights</p>
        </div>
        <% } %>
    </div>

    <!-- Product Categories Section -->
    <div class="section-card">
        <div class="section-header" style="background: linear-gradient(135deg, rgba(240,147,251,0.12) 0%, rgba(245,87,108,0.12) 100%);">
            <h2><i class="fas fa-tags" style="color: #f093fb; -webkit-text-fill-color: #f093fb;"></i> Product Categories Overview</h2>
            <a href="${pageContext.request.contextPath}/adminCategories.jsp" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); box-shadow: 0 8px 25px rgba(240,147,251,0.35);">Manage Categories <i class="fas fa-arrow-right"></i></a>
        </div>
        
        <!-- Category Summary Table -->
        <div style="overflow-x: auto; margin-bottom: 20px;">
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr>
                    <th style="padding: 14px; background: linear-gradient(135deg, rgba(240,147,251,0.15) 0%, rgba(245,87,108,0.15) 100%); border-bottom: 2px solid rgba(240,147,251,0.3);">Category</th>
                    <th style="padding: 14px; background: linear-gradient(135deg, rgba(240,147,251,0.15) 0%, rgba(245,87,108,0.15) 100%); border-bottom: 2px solid rgba(240,147,251,0.3);">Product Count</th>
                    <th style="padding: 14px; background: linear-gradient(135deg, rgba(240,147,251,0.15) 0%, rgba(245,87,108,0.15) 100%); border-bottom: 2px solid rgba(240,147,251,0.3);">Status</th>
                    <th style="padding: 14px; background: linear-gradient(135deg, rgba(240,147,251,0.15) 0%, rgba(245,87,108,0.15) 100%); border-bottom: 2px solid rgba(240,147,251,0.3);">Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                for (java.util.Map.Entry<String, Integer> entry : categoryCounts.entrySet()) {
                    String categoryName = entry.getKey();
                    int count = entry.getValue();
            %>
                <tr>
                    <td style="padding: 14px; border-bottom: 1px solid rgba(240,147,251,0.15);">
                        <strong><%= categoryName %>s</strong>
                    </td>
                    <td style="padding: 14px; border-bottom: 1px solid rgba(240,147,251,0.15);">
                        <span style="font-size: 20px; font-weight: 800; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent;"><%= count %></span>
                        <span style="color: #636e72; font-size: 12px; font-weight: 600;"> products</span>
                    </td>
                    <td style="padding: 14px; border-bottom: 1px solid rgba(240,147,251,0.15);">
                        <% if (count > 0) { %>
                            <span style="background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%); color: #155724; padding: 5px 14px; border-radius: 16px; font-size: 11px; font-weight: 800;">Active</span>
                        <% } else { %>
                            <span style="background: #f1f3f5; color: #868e96; padding: 5px 14px; border-radius: 16px; font-size: 11px; font-weight: 800;">Empty</span>
                        <% } %>
                    </td>
                    <td style="padding: 14px; border-bottom: 1px solid rgba(240,147,251,0.15);">
                        <a href="${pageContext.request.contextPath}/adminDashboard.jsp?category=<%= categoryName %>" style="padding: 8px 16px; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; border-radius: 12px; text-decoration: none; font-size: 12px; font-weight: 700; box-shadow: 0 4px 12px rgba(240,147,251,0.3);">View Products</a>
                    </td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
        </div>

        <!-- Category Cards (Visual) -->
        <div class="category-grid">
            <% for (java.util.Map.Entry<String, Integer> entry : categoryCounts.entrySet()) { %>
            <div class="category-card" data-category="<%= entry.getKey().toLowerCase() %>" data-count="<%= entry.getValue() %>" onclick="window.location.href='${pageContext.request.contextPath}/adminDashboard.jsp?category=<%= entry.getKey() %>'" style="cursor: pointer;">
                <div class="category-icon <%= entry.getKey().toLowerCase() %>">
                    <i class="fas fa-<%= entry.getKey().equalsIgnoreCase("Saree") ? "user-tie" : entry.getKey().equalsIgnoreCase("Kurti") ? "tshirt" : entry.getKey().equalsIgnoreCase("Suit") ? "vest" : entry.getKey().equalsIgnoreCase("Lehenga") ? "crown" : "box" %>"></i>
                </div>
                <div class="category-value"><%= entry.getValue() %></div>
                <div class="category-label"><%= entry.getKey() %>s</div>
                <div class="click-hint">Click to view products</div>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Products by Category Section -->
    <%
        String selectedCategory = request.getParameter("category");
        if (selectedCategory != null && !selectedCategory.isEmpty()) {
    %>
    <div class="section-card">
        <div class="section-header" style="background: linear-gradient(135deg, rgba(79,172,254,0.1) 0%, rgba(0,242,254,0.1) 100%);">
            <h2><i class="fas fa-box" style="color: #4facfe; -webkit-text-fill-color: #4facfe;"></i> Products in <%= selectedCategory %></h2>
            <a href="${pageContext.request.contextPath}/adminDashboard.jsp" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); box-shadow: 0 8px 25px rgba(102,126,234,0.3); font-size: 14px;">View All Categories <i class="fas fa-arrow-right"></i></a>
        </div>
        <div style="overflow-x: auto;">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Product Name</th>
                    <th>Price</th>
                    <th>Image</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnect.getConn()) {
                    String categorySql = "SELECT p_id, p_name, p_price, p_image FROM products WHERE p_category = ? ORDER BY p_id DESC LIMIT 20";
                    try (PreparedStatement ps = conn.prepareStatement(categorySql)) {
                        ps.setString(1, selectedCategory);
                        try (ResultSet rs = ps.executeQuery()) {
                            boolean hasProducts = false;
                            while(rs.next()) {
                                hasProducts = true;
                                int pid = rs.getInt("p_id");
                                String pName = rs.getString("p_name");
                                java.math.BigDecimal pPrice = rs.getBigDecimal("p_price");
                                String pImage = rs.getString("p_image");
            %>
                <tr>
                    <td><strong>#<%= pid %></strong></td>
                    <td><%= pName %></td>
                    <td><%= String.format("₹%.2f", pPrice) %></td>
                    <td>
                        <img src="${pageContext.request.contextPath}/product_img/<%= pImage %>" alt="<%= pName %>" style="width: 50px; height: 50px; object-fit: cover; border-radius: 6px;" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/product_img/placeholder.svg';">
                    </td>
                    <td><span class="status-badge status-completed">Active</span></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/editProduct.jsp?id=<%= pid %>" class="action-links a" style="padding: 6px 12px; background: #3b82f6; color: white; border-radius: 6px; text-decoration: none; font-size: 12px; font-weight: 600;">Edit</a>
                        <a href="${pageContext.request.contextPath}/DeleteProductServlet?id=<%= pid %>" class="action-links a" style="padding: 6px 12px; background: #ef4444; color: white; border-radius: 6px; text-decoration: none; font-size: 12px; font-weight: 600;" onclick="return confirm('Are you sure you want to delete this product?');">Delete</a>
                    </td>
                </tr>
            <%
                            }
                            if (!hasProducts) {
                                out.println("<tr><td colspan='6' style='text-align:center; color:#94a3b8; padding:20px;'>No products found in " + selectedCategory + "</td></tr>");
                            }
                        }
                    }
                } catch(Exception e) {
                    out.println("<tr><td colspan='6' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                }
            %>
            </tbody>
        </table>
        </div>
    </div>
    <% } %>

    <!-- Pending Orders Awaiting Approval (PRIORITY) -->
    <%
        int pendingForApproval = 0;
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM orders WHERE approval_status IN ('pending_review', 'payment_verification_failed')");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) pendingForApproval = rs.getInt(1);
        } catch (Exception e) {}
    %>
    <% if (pendingForApproval > 0) { %>
    <div class="section-card" style="border-left: 5px solid #f5576c;">
        <div class="section-header" style="background: linear-gradient(135deg, rgba(245,87,108,0.12) 0%, rgba(255,107,157,0.12) 100%);">
            <h2><i class="fas fa-exclamation-circle" style="color: #f5576c; -webkit-text-fill-color: #f5576c;"></i> Pending Orders Awaiting Approval</h2>
            <a href="${pageContext.request.contextPath}/adminOrders.jsp?status=pending" style="background: linear-gradient(135deg, #f5576c 0%, #ff6b9d 100%); box-shadow: 0 8px 25px rgba(245,87,108,0.35);">View All Pending <i class="fas fa-arrow-right"></i></a>
        </div>
        <div style="overflow-x: auto;">
        <table>
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th>Amount</th>
                    <th>Payment Status</th>
                    <th>Address Verified</th>
                    <th>Approval Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnect.getConn()) {
                    String orderColumn = DBConnect.hasColumn(conn, "orders", "created_at") ? "created_at" : "o_id";
                    String pendingSql = "SELECT o_id, user_id, total_amount, payment_status, address_verified, approval_status FROM orders WHERE approval_status IN ('pending_review', 'payment_verification_failed') ORDER BY " + orderColumn + " ASC LIMIT 10";
                    try (PreparedStatement ps = conn.prepareStatement(pendingSql);
                         ResultSet rs = ps.executeQuery()) {
                    boolean hasPending = false;
                    while(rs.next()) {
                        hasPending = true;
                        int orderId = rs.getInt("o_id");
                        String paymentStatus = rs.getString("payment_status");
                        boolean addressVerified = rs.getBoolean("address_verified");
                        String approvalStatus = rs.getString("approval_status");
            %>
                <tr>
                    <td><strong>#<%= orderId %></strong></td>
                    <td><%= rs.getString("user_id") %></td>
                    <td><%= String.format("₹%.2f", rs.getBigDecimal("total_amount")) %></td>
                    <td><span class="status-badge status-<%= paymentStatus %>"><%= paymentStatus %></span></td>
                    <td><%= addressVerified ? "✓ Yes" : "✗ No" %></td>
                    <td><span class="status-badge" style="background: #fef3c7; color: #92400e;"><%= approvalStatus.replace("_", " ") %></span></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/adminOrders.jsp?orderId=<%= orderId %>" class="action-links a" style="padding: 6px 12px; background: #ff3f6c; color: white; border-radius: 6px; text-decoration: none; font-size: 12px; font-weight: 600;">Review & Approve</a>
                    </td>
                </tr>
            <%
                    }
                    if (!hasPending) {
                        out.println("<tr><td colspan='7' style='text-align:center; color:#94a3b8; padding:20px;'>No pending orders</td></tr>");
                    }
                } catch(Exception e) {
                    out.println("<tr><td colspan='7' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                }
            }
            %>
            </tbody>
        </table>
        </div>
    </div>
    <% } %>

    <!-- Products Section -->
    <div class="section-card" id="products">
        <div class="section-header" style="background: linear-gradient(135deg, rgba(118,75,162,0.1) 0%, rgba(102,126,234,0.1) 100%);">
            <h2><i class="fas fa-box" style="color: #764ba2; -webkit-text-fill-color: #764ba2;"></i> Products</h2>
            <a href="${pageContext.request.contextPath}/addproduct.jsp" style="background: linear-gradient(135deg, #764ba2 0%, #667eea 100%); box-shadow: 0 8px 25px rgba(118,75,162,0.35);"><i class="fas fa-plus"></i> Add New</a>
        </div>
        <div style="overflow-x: auto;">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Category</th>
                    <th>Price</th>
                    <th>Image</th>
                    <th>Description</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnect.getConn();
                     PreparedStatement ps = conn.prepareStatement("SELECT * FROM products ORDER BY p_id DESC");
                     ResultSet rs = ps.executeQuery()) {
                    while(rs.next()) {
                        int pid = rs.getInt("p_id");
                        String desc = rs.getString("p_desc");
            %>
                <tr>
                    <td><%= pid %></td>
                    <td><%= rs.getString("p_name") %></td>
                    <td><%= rs.getString("p_category") %></td>
                    <td><%= String.format("&#8377;%.2f", rs.getBigDecimal("p_price")) %></td>
                    <td><%= rs.getString("p_image") %></td>
                    <td><%= desc != null ? desc.substring(0, Math.min(50, desc.length())) + "..." : "" %></td>
                    <td class="action-links">
                        <a href="${pageContext.request.contextPath}/editProduct.jsp?id=<%= pid %>"><i class="fas fa-edit"></i> Edit</a>
                        <a href="${pageContext.request.contextPath}/DeleteProductServlet?id=<%= pid %>" class="delete" onclick="return confirm('Delete this product?')"><i class="fas fa-trash"></i> Delete</a>
                    </td>
                </tr>
            <%
                    }
                } catch(Exception e) {
                    out.println("<tr><td colspan='7' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                }
            %>
            </tbody>
        </table>
        </div>
    </div>

    <!-- Recent Orders Preview -->
    <div class="section-card">
        <div class="section-header" style="background: linear-gradient(135deg, rgba(79,172,254,0.1) 0%, rgba(0,242,254,0.1) 100%);">
            <h2><i class="fas fa-shopping-bag" style="color: #4facfe; -webkit-text-fill-color: #4facfe;"></i> Recent Orders</h2>
            <a href="${pageContext.request.contextPath}/adminOrders.jsp" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); box-shadow: 0 8px 25px rgba(79,172,254,0.35);">View All <i class="fas fa-arrow-right"></i></a>
        </div>
        <div style="overflow-x: auto;">
        <table>
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th>Amount</th>
                    <th>Status</th>
                    <th>Date</th>
                </tr>
            </thead>
            <tbody>
            <%
                try (Connection conn = DBConnect.getConn()) {
                    String orderColumn = DBConnect.hasColumn(conn, "orders", "created_at") ? "created_at" : "o_id";
                    String recentSql = "SELECT * FROM orders ORDER BY " + orderColumn + " DESC LIMIT 5";
                    try (PreparedStatement ps = conn.prepareStatement(recentSql);
                         ResultSet rs = ps.executeQuery()) {
                    boolean hasOrders = false;
                    while(rs.next()) {
                        hasOrders = true;
                        String status = rs.getString("status");
            %>
                <tr>
                    <td>#<%= rs.getInt("o_id") %></td>
                    <td><%= rs.getString("user_id") %></td>
                    <td><%= String.format("&#8377;%.2f", rs.getBigDecimal("total_amount")) %></td>
                    <td><span class="status-badge status-<%= status %>"><%= status %></span></td>
                    <td><%= DBConnect.hasColumn(conn, "orders", "created_at") ? rs.getTimestamp("created_at") : "N/A" %></td>
                </tr>
            <%
                    }
                    if (!hasOrders) {
                        out.println("<tr><td colspan='5' style='text-align:center; color:#94a3b8;'>No orders yet</td></tr>");
                    }
                } catch(Exception e) {
                    out.println("<tr><td colspan='5' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                }
            }
            %>
            </tbody>
        </table>
        </div>
    </div>
</div>

<!-- Category Details Modal -->
<div class="category-modal" id="categoryModal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle"><i class="fas fa-user-tie"></i> Category Details</h3>
            <button class="modal-close" onclick="closeCategoryModal()">&times;</button>
        </div>
        <div class="modal-body">
            <div class="modal-icon" id="modalIcon"><i class="fas fa-user-tie"></i></div>
            <div class="modal-count" id="modalCount">0</div>
            <div class="modal-label" id="modalLabel">Products Available</div>
        </div>
    </div>
</div>

<!-- Welcome Overlay -->
<div class="welcome-overlay" id="welcomeOverlay">
    <div class="flower-particles" id="flowerParticles"></div>
    <div class="welcome-content">
        <div class="welcome-icon">🌸✨</div>
        <div class="welcome-title">Welcome, Admin! 💖</div>
        <div class="welcome-subtitle">Your dashboard is ready! Let's make your business bloom! 🌷</div>
        <button class="welcome-btn" onclick="closeWelcome()">Enter Dashboard ✨</button>
    </div>
</div>

<jsp:include page="/common/admin-footer.jsp" />
