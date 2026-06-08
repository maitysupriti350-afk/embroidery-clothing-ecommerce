<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.conn.DBConnect" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("auth.jsp");
        return;
    }
    Boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    if (isAdmin) {
        response.sendRedirect("adminDashboard.jsp");
        return;
    }
    String currentUser = session.getAttribute("user").toString();

    // Load profile from database
    String profileFullName = "";
    String profilePhone = "";
    String profileAddress = "";
    String profileMembership = "Standard";
    int orderCount = 0;

    try (Connection conn = DBConnect.getConn();
         PreparedStatement ps = conn.prepareStatement("SELECT * FROM user WHERE userid = ?")) {
        ps.setString(1, currentUser);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String fn = rs.getString("full_name");
                if (fn != null) profileFullName = fn;
                String ph = rs.getString("phone");
                if (ph != null) profilePhone = ph;
                String addr = rs.getString("address");
                if (addr != null) profileAddress = addr;
                String mem = rs.getString("membership");
                if (mem != null) profileMembership = mem;
            }
        }
        // Get actual order count
        try (PreparedStatement psOrders = conn.prepareStatement("SELECT COUNT(*) FROM orders WHERE user_id = ?")) {
            psOrders.setString(1, currentUser);
            try (ResultSet rsOrders = psOrders.executeQuery()) {
                if (rsOrders.next()) orderCount = rsOrders.getInt(1);
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <title>My Profile - THE GILDED STITCH</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { background-color: #556B2F; color: #4a4a4a; min-height: 100vh; padding: 20px 0; }

        /* Keep header/footer in normal flow. Center main profile card within wrapper. */
        .profile-wrapper { display: flex; justify-content: center; padding: 28px 20px; }

        .profile-card { background: #FFB6C1; max-width: 820px; width: 100%; padding: 36px; border-radius: 16px; box-shadow: 0 15px 35px rgba(93, 64, 55, 0.1); border: 1px solid #e0d5c1; }
        
        h2 { font-family: 'Playfair Display', serif; color: #5d4037; font-size: 2rem; margin-bottom: 5px; text-align: left; }
        .email-label { color: #a08a7e; font-size: 14px; margin-bottom: 18px; display:block; text-align:left }

        .edit-form { text-align: left; }
        .input-group { margin-bottom: 20px; }
        
        .input-group label { display: block; font-size: 12px; color: #a08a7e; text-transform: uppercase; margin-bottom: 5px; font-weight: 600; }
        
        .input-group input, .input-group select, .input-group textarea { 
            width: 100%; padding: 12px; border: 1px solid #eaddca; border-radius: 10px; background: #fff; color: #5d4037; outline: none; transition: 0.3s; font-family: 'Poppins', sans-serif; font-size: 14px;
        }
        .input-group textarea { resize: vertical; min-height: 80px; }
        
        .input-group input:focus, .input-group textarea:focus, .input-group select:focus { border-color: #5d4037; box-shadow: 0 0 5px rgba(93, 64, 55, 0.2); }

        .info-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #eaddca; font-size: 14px; }
        .info-row .info-label { color: #a08a7e; font-weight: 600; }
        .info-row .info-value { color: #5d4037; }

        .btn-container { display: flex; gap: 15px; margin-top: 30px; }
        
        .btn { flex: 1; padding: 14px; border-radius: 10px; text-decoration: none; font-size: 14px; font-weight: 600; text-align: center; cursor: pointer; border: none; transition: 0.3s; }
        
        .btn-save { background: #5d4037; color: #fff; }
        .btn-cancel { border: 1px solid #5d4037; color: #5d4037; background: transparent; }
        
        .btn:hover { transform: translateY(-2px); opacity: 0.9; }

        .reward-summary {
            margin-top: 16px;
            padding: 18px;
            border-radius: 18px;
            background: linear-gradient(135deg, #ffe1f2 0%, #ffc1e6 100%);
            border: 1px solid #ffb2dd;
            color: #5c0d45;
        }

        .reward-summary strong {
            display: block;
            font-size: 1.35rem;
            margin-bottom: 8px;
        }

        .reward-action {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-top: 14px;
            padding: 12px 18px;
            border-radius: 14px;
            background: #ff6bb0;
            color: #fff;
            text-decoration: none;
            font-weight: 700;
            transition: background 0.25s ease;
        }

        .reward-action:hover {
            background: #e52f86;
        }

        /* Mobile Responsive Styles */
        @media (max-width: 768px) {
            body {
                padding: 0;
            }
            
            .profile-wrapper {
                padding: 16px;
            }
            
            .profile-card {
                padding: 24px 20px;
                border-radius: 16px;
            }
            
            h2 {
                font-size: 24px;
            }
            
            .email-label {
                font-size: 13px;
                margin-bottom: 16px;
            }
            
            .input-group {
                margin-bottom: 16px;
            }
            
            .input-group input,
            .input-group select,
            .input-group textarea {
                padding: 14px 16px;
                font-size: 16px;
            }
            
            .info-row {
                font-size: 13px;
                padding: 12px 0;
            }
            
            .btn-container {
                flex-direction: column;
                gap: 12px;
                margin-top: 24px;
            }
            
            .btn {
                padding: 14px 20px;
                font-size: 15px;
            }
            
            .reward-summary {
                padding: 16px;
                margin-top: 12px;
            }
            
            .reward-summary strong {
                font-size: 1.2rem;
            }
            
            .reward-action {
                width: 100%;
                padding: 14px 20px;
                margin-top: 12px;
            }
        }

        @media (max-width: 480px) {
            .profile-wrapper {
                padding: 12px;
            }
            
            .profile-card {
                padding: 20px 16px;
            }
            
            h2 {
                font-size: 20px;
            }
            
            .input-group input,
            .input-group select,
            .input-group textarea {
                padding: 12px 14px;
                font-size: 15px;
            }
            
            .btn {
                padding: 12px 16px;
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/common/header.jsp" />

    <div class="profile-wrapper">
        <div class="profile-card">
        <h2>My Profile</h2>
        <div class="email-label"><%= currentUser != null ? currentUser.replaceAll("[<>\"']", "") : "" %></div>

        <% String successMessage = (String) session.getAttribute("succMsg");
           String failedMessage = (String) session.getAttribute("failedMsg");
           if (successMessage != null) { %>
        <div style="margin-bottom: 20px; padding: 12px; border-radius: 8px; background: #d1e7dd; color: #0f5132;">
            <%= successMessage.replaceAll("[<>\"']", "") %>
        </div>
        <% session.removeAttribute("succMsg"); }
           if (failedMessage != null) { %>
        <div style="margin-bottom: 20px; padding: 12px; border-radius: 8px; background: #f8d7da; color: #721c24;">
            <%= failedMessage.replaceAll("[<>\"']", "") %>
        </div>
        <% session.removeAttribute("failedMsg"); } %>

        <div style="background: #f5f0e8; border-radius: 12px; padding: 16px; margin-bottom: 24px;">
            <div class="info-row">
                <span class="info-label">Membership</span>
                <span class="info-value"><%= profileMembership != null ? profileMembership.replaceAll("[<>\"']", "") : "" %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Total Orders</span>
                <span class="info-value"><%= orderCount %></span>
            </div>
            <div class="info-row" style="margin-top:12px;padding-top:12px;border-top:1px solid #eaddca;">
                <span class="info-label">Reward Points</span>
                <span class="info-value" id="profileRewardPoints">0</span>
            </div>
            <div class="info-row">
                <span class="info-label">Estimated Discount</span>
                <span class="info-value" id="profileRewardDiscount">0% off</span>
            </div>
            <div style="margin-top:10px;color:#6b3a53;font-size:13px;">
                Earn points on the homepage games and come back here to view your reward status.
            </div>
            <div class="reward-summary">
                <strong id="profileRewardSummaryTitle">Your spinner reward status</strong>
                Spin the wheel on the new rewards page and increase your discount power. Every 20 points gives you a stronger savings boost at checkout.
                <a href="${pageContext.request.contextPath}/spinner.jsp" class="reward-action">Go to Spinner</a>
            </div>
        </div>

        <%-- Recent orders fetch and display --%>
        <%
            java.util.List<java.util.Map<String,Object>> recentOrders = new java.util.ArrayList<>();
            try (Connection conn2 = DBConnect.getConn()) {
                boolean hasCreatedAt = DBConnect.hasColumn(conn2, "orders", "created_at");
                String orderSql = "SELECT o_id, status, total_amount" + (hasCreatedAt ? ", created_at" : "") + " FROM orders WHERE user_id = ? ORDER BY " + (hasCreatedAt ? "created_at" : "o_id") + " DESC LIMIT 5";
                try (PreparedStatement psRecent = conn2.prepareStatement(orderSql)) {
                    psRecent.setString(1, currentUser);
                    try (ResultSet rs = psRecent.executeQuery()) {
                        while (rs.next()) {
                            java.util.Map<String,Object> m = new java.util.HashMap<>();
                            m.put("o_id", rs.getInt("o_id"));
                            m.put("status", rs.getString("status"));
                            m.put("total", rs.getBigDecimal("total_amount"));
                            if (hasCreatedAt) {
                                m.put("created_at", rs.getTimestamp("created_at"));
                            }
                            recentOrders.add(m);
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>

        <div style="max-width:700px;margin:0 auto 24px;">
            <h3 style="color:#5d4037;margin-bottom:10px">Recent Orders</h3>
            <% if (recentOrders.isEmpty()) { %>
                <div style="color:#6b3a53;padding:10px;background:#fff;border-radius:8px;">You have no recent orders.</div>
            <% } else { %>
                <div style="display:flex;flex-direction:column;gap:10px;">
                    <% for (java.util.Map<String,Object> o : recentOrders) { %>
                        <div style="background:#fff;padding:12px;border-radius:8px;display:flex;justify-content:space-between;align-items:center;">
                            <div>
                                <div><strong>Order #</strong> <%= o.get("o_id") %></div>
                                <div style="font-size:13px;color:#6b3a53">Placed: <%= o.get("created_at") != null ? o.get("created_at").toString().replaceAll("[<>\"']", "") : "N/A" %></div>
                            </div>
                            <div style="text-align:right">
                                <div style="font-weight:700;color:#b13665">₹<%= o.get("total") %></div>
                                <div style="font-size:13px;color:#6b3a53">Status: <%= o.get("status") != null ? o.get("status").toString().replaceAll("[<>\"']", "") : "" %></div>
                                <div style="margin-top:6px"><a href="<%= request.getContextPath() %>/OrdersServlet" style="color:#5d4037;text-decoration:none;font-weight:600">View All</a></div>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>

        <form action="${pageContext.request.contextPath}/SaveProfileServlet" method="post" class="edit-form">
            <div class="input-group">
                <label>Full Name</label>
                <input type="text" name="fullName" placeholder="Enter your full name" value="<%= profileFullName != null ? profileFullName.replaceAll("[<>\"']", "") : "" %>">
            </div>

            <div class="input-group">
                <label>Phone Number</label>
                <input type="tel" name="phone" placeholder="Enter phone number" value="<%= profilePhone != null ? profilePhone.replaceAll("[<>\"']", "") : "" %>">
            </div>

            <div class="input-group">
                <label>Shipping Address</label>
                <textarea name="address" placeholder="Enter your default shipping address"><%= profileAddress != null ? profileAddress.replaceAll("[<>\"']", "") : "" %></textarea>
            </div>

            <div class="input-group">
                <label>Membership Tier</label>
                <select name="membership">
                    <option value="Standard" <%= "Standard".equals(profileMembership) ? "selected" : "" %>>Standard Member</option>
                    <option value="Elite" <%= "Elite".equals(profileMembership) ? "selected" : "" %>>Elite Member</option>
                    <option value="VIP" <%= "VIP".equals(profileMembership) ? "selected" : "" %>>VIP Member</option>
                </select>
            </div>

            <div class="btn-container">
                <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-cancel">Cancel</a>
                <button type="submit" class="btn btn-save">Save Profile</button>
            </div>
        </form>
    </div>

    <script>
        (function() {
            const points = parseInt(localStorage.getItem('gildedStitchRewardPoints') || '0', 10);
            const discount = points >= 20 ? Math.min(15, Math.floor(points / 20)) : 0;
            const pointsEl = document.getElementById('profileRewardPoints');
            const discountEl = document.getElementById('profileRewardDiscount');
            const summaryTitle = document.getElementById('profileRewardSummaryTitle');
            if (pointsEl) pointsEl.textContent = points;
            if (discountEl) discountEl.textContent = discount + '% off';
            if (summaryTitle) {
                if (points >= 20) {
                    summaryTitle.textContent = 'You have ' + points + ' points ready to redeem.';
                } else {
                    summaryTitle.textContent = 'Spin to reach 20 points and unlock checkout savings.';
                }
            }
        })();
    </script>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
