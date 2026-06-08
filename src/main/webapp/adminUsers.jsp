<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.conn.DBConnect" %>
<%@ page import="java.math.BigDecimal" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("auth.jsp");
        return;
    }
    Boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    if (!isAdmin) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    String currentUser = session.getAttribute("user").toString();

    request.setAttribute("adminActivePage", "users");
    request.setAttribute("adminPageTitle", "User Management");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manage Users - Admin Panel</title>
<jsp:include page="/common/admin-style.jsp" />
<style>
    .user-avatar { width: 36px; height: 36px; border-radius: 50%; background: #e0e7ff; color: #4338ca; display: inline-flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px; margin-right: 10px; }
    .btn-delete:disabled { background: #9ca3af; cursor: not-allowed; }
</style>
</head>
<body>
<jsp:include page="/common/admin-header.jsp" />

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

    <div class="section-card">
        <div class="section-header">
            <h2><i class="fas fa-users" style="color: #059669; margin-right: 8px;"></i>All Registered Users</h2>
        </div>
        <div style="overflow-x: auto;">
        <table>
            <thead>
                <tr>
                    <th>User</th>
                    <th>Role</th>
                    <th>Orders</th>
                    <th>Total Spent</th>
                    <th>Cart Items</th>
                    <th>Wishlist</th>
                    <th>Joined</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                // Get admin email from env/property
                String adminEmail = System.getenv("ADMIN_USER");
                if (adminEmail == null || adminEmail.isEmpty()) {
                    adminEmail = System.getProperty("admin.email", "admin@example.com");
                }

                try (Connection conn = DBConnect.getConn()) {
                    boolean hasCreatedAt = DBConnect.hasColumn(conn, "user", "created_at");
                    String orderColumn = hasCreatedAt ? "created_at" : "userid";
                    try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM user ORDER BY " + orderColumn + " ASC");
                         ResultSet rs = ps.executeQuery()) {

                        boolean hasUsers = false;
                        while (rs.next()) {
                            hasUsers = true;
                            String userId = rs.getString("userid");
                            boolean isUserAdmin = userId.equalsIgnoreCase(adminEmail);

                            // Get user stats
                            int orderCount = 0;
                            BigDecimal totalSpent = BigDecimal.ZERO;
                            try (PreparedStatement psO = conn.prepareStatement("SELECT COUNT(*) as cnt, COALESCE(SUM(total_amount),0) as total FROM orders WHERE user_id = ?")) {
                                psO.setString(1, userId);
                                try (ResultSet rsO = psO.executeQuery()) {
                                    if (rsO.next()) {
                                        orderCount = rsO.getInt("cnt");
                                        totalSpent = rsO.getBigDecimal("total");
                                    }
                                }
                            }

                            int cartCount = 0;
                            try (PreparedStatement psC = conn.prepareStatement("SELECT COUNT(*) FROM cart WHERE user_id = ?")) {
                                psC.setString(1, userId);
                                try (ResultSet rsC = psC.executeQuery()) {
                                    if (rsC.next()) cartCount = rsC.getInt(1);
                                }
                            }

                            int wishCount = 0;
                            try (PreparedStatement psW = conn.prepareStatement("SELECT COUNT(*) FROM wishlist WHERE user_id = ?")) {
                                psW.setString(1, userId);
                                try (ResultSet rsW = psW.executeQuery()) {
                                    if (rsW.next()) wishCount = rsW.getInt(1);
                                }
                            }

                            String initial = userId.substring(0, 1).toUpperCase();
            %>
                <tr>
                    <td>
                        <div style="display: flex; align-items: center;">
                            <span class="user-avatar"><%= initial %></span>
                            <div>
                                <div style="font-weight: 600;"><%= userId %></div>
                            </div>
                        </div>
                    </td>
                    <td><span class="role-badge <%= isUserAdmin ? "role-admin" : "role-user" %>"><%= isUserAdmin ? "Admin" : "Customer" %></span></td>
                    <td><%= orderCount %></td>
                    <td><%= String.format("&#8377;%.2f", totalSpent) %></td>
                    <td><%= cartCount %></td>
                    <td><%= wishCount %></td>
                    <td><%= hasCreatedAt ? rs.getTimestamp("created_at") : "N/A" %></td>
                    <td>
                        <% if (userId.equals(currentUser)) { %>
                            <button class="btn-delete" disabled title="Cannot delete your own account">Delete</button>
                        <% } else { %>
                            <form action="${pageContext.request.contextPath}/AdminUserServlet" method="post" onsubmit="return confirm('Delete user <%= userId %>? This will remove all their data including orders, cart, and wishlist.')">
                                <input type="hidden" name="action" value="deleteUser">
                                <input type="hidden" name="userId" value="<%= userId %>">
                                <button type="submit" class="btn-delete">Delete</button>
                            </form>
                        <% } %>
                    </td>
                </tr>
            <%
                        }
                        if (!hasUsers) {
                            out.println("<tr><td colspan='8' style='text-align:center; color:#94a3b8; padding:40px;'>No users found.</td></tr>");
                        }
                    }
                } catch(Exception e) {
                    out.println("<tr><td colspan='8' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                }
            %>
            </tbody>
        </table>
        </div>
    </div>

<jsp:include page="/common/admin-footer.jsp" />
