<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.conn.DBConnect" %>
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

    request.setAttribute("adminActivePage", "categories");
    request.setAttribute("adminPageTitle", "Manage Categories");

    String action = request.getParameter("action");
    String successMessage = (String) session.getAttribute("succMsg");
    String failedMessage = (String) session.getAttribute("failedMsg");
    
    if (successMessage != null) {
        session.removeAttribute("succMsg");
    }
    if (failedMessage != null) {
        session.removeAttribute("failedMsg");
    }

    // Fetch all categories
    java.util.List<java.util.Map<String, Object>> categories = new java.util.ArrayList<>();
    try (Connection conn = DBConnect.getConn();
         PreparedStatement ps = conn.prepareStatement("SELECT * FROM categories ORDER BY display_order");
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            java.util.Map<String, Object> category = new java.util.HashMap<>();
            category.put("category_id", rs.getInt("category_id"));
            category.put("category_name", rs.getString("category_name"));
            category.put("category_description", rs.getString("category_description"));
            category.put("display_order", rs.getInt("display_order"));
            category.put("is_active", rs.getBoolean("is_active"));
            categories.add(category);
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
<title>Manage Categories - Admin Panel</title>
<jsp:include page="/common/admin-style.jsp" />
</head>
<body>
<jsp:include page="/common/admin-header.jsp" />

    <% if (successMessage != null) { %>
    <div class="msg-bar msg-success">
        <i class="fas fa-check-circle"></i> <%= successMessage %>
    </div>
    <% } %>
    <% if (failedMessage != null) { %>
    <div class="msg-bar msg-error">
        <i class="fas fa-exclamation-circle"></i> <%= failedMessage %>
    </div>
    <% } %>

    <div class="admin-form-card">
        <h2><i class="fas fa-tags" style="color: #ff3f6c; margin-right: 8px;"></i>Manage Categories</h2>
        
        <div class="form-group">
            <label>Add New Category</label>
            <form action="${pageContext.request.contextPath}/CategoryServlet" method="post">
                <input type="hidden" name="action" value="add">
                <div style="display: grid; grid-template-columns: 2fr 3fr 1fr auto; gap: 12px; align-items: end;">
                    <div>
                        <label style="font-size: 12px; margin-bottom: 4px;">Category Name</label>
                        <input type="text" name="category_name" placeholder="e.g. Anarkali" required>
                    </div>
                    <div>
                        <label style="font-size: 12px; margin-bottom: 4px;">Description</label>
                        <input type="text" name="category_description" placeholder="Brief description">
                    </div>
                    <div>
                        <label style="font-size: 12px; margin-bottom: 4px;">Display Order</label>
                        <input type="number" name="display_order" placeholder="0" value="0" min="0" required>
                    </div>
                    <div>
                        <button type="submit" class="btn-primary">Add Category</button>
                    </div>
                </div>
            </form>
        </div>

        <h3 style="margin-top: 30px; margin-bottom: 15px;">Existing Categories</h3>
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr>
                    <th style="padding: 12px; background: #f8f9fa; border-bottom: 2px solid #dee2e6;">ID</th>
                    <th style="padding: 12px; background: #f8f9fa; border-bottom: 2px solid #dee2e6;">Category Name</th>
                    <th style="padding: 12px; background: #f8f9fa; border-bottom: 2px solid #dee2e6;">Description</th>
                    <th style="padding: 12px; background: #f8f9fa; border-bottom: 2px solid #dee2e6;">Order</th>
                    <th style="padding: 12px; background: #f8f9fa; border-bottom: 2px solid #dee2e6;">Status</th>
                    <th style="padding: 12px; background: #f8f9fa; border-bottom: 2px solid #dee2e6;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% for (java.util.Map<String, Object> cat : categories) { %>
                <tr>
                    <td style="padding: 12px; border-bottom: 1px solid #dee2e6;"><%= cat.get("category_id") %></td>
                    <td style="padding: 12px; border-bottom: 1px solid #dee2e6;"><strong><%= cat.get("category_name") %></strong></td>
                    <td style="padding: 12px; border-bottom: 1px solid #dee2e6;"><%= cat.get("category_description") != null ? cat.get("category_description") : "-" %></td>
                    <td style="padding: 12px; border-bottom: 1px solid #dee2e6;"><%= cat.get("display_order") %></td>
                    <td style="padding: 12px; border-bottom: 1px solid #dee2e6;">
                        <% if ((Boolean) cat.get("is_active")) { %>
                            <span style="color: #10b981; font-weight: bold;">Active</span>
                        <% } else { %>
                            <span style="color: #6b7280;">Inactive</span>
                        <% } %>
                    </td>
                    <td style="padding: 12px; border-bottom: 1px solid #dee2e6;">
                        <form action="${pageContext.request.contextPath}/CategoryServlet" method="post" style="display: inline;">
                            <input type="hidden" name="action" value="toggle">
                            <input type="hidden" name="category_id" value="<%= cat.get("category_id") %>">
                            <button type="submit" class="btn-secondary" style="padding: 6px 12px; font-size: 12px;">
                                <%= (Boolean) cat.get("is_active") ? "Deactivate" : "Activate" %>
                            </button>
                        </form>
                        <form action="${pageContext.request.contextPath}/CategoryServlet" method="post" style="display: inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="category_id" value="<%= cat.get("category_id") %>">
                            <button type="submit" class="btn-danger" style="padding: 6px 12px; font-size: 12px;" onclick="return confirm('Are you sure you want to delete this category?');">
                                Delete
                            </button>
                        </form>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>

<jsp:include page="/common/admin-footer.jsp" />
</body>
</html>
