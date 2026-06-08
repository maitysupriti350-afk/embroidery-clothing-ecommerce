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

    request.setAttribute("adminActivePage", "addproduct");
    request.setAttribute("adminPageTitle", "Add New Product");

    // Fetch categories from database
    java.util.List<String> categories = new java.util.ArrayList<>();
    try (Connection conn = DBConnect.getConn();
         PreparedStatement ps = conn.prepareStatement("SELECT category_name FROM categories WHERE is_active = TRUE ORDER BY display_order");
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            categories.add(rs.getString("category_name"));
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
<title>Add New Product - Admin Panel</title>
<jsp:include page="/common/admin-style.jsp" />
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
    <% session.removeAttribute("failedMsg"); }
    %>

    <div class="admin-form-card">
        <h2><i class="fas fa-plus-circle" style="color: #ff3f6c; margin-right: 8px;"></i>Add New Collection Item</h2>
        <form action="${pageContext.request.contextPath}/addProduct" method="post">
            <div class="form-group">
                <label>Product Name</label>
                <input type="text" name="p_name" placeholder="e.g. Red Silk Saree" required>
            </div>
            <div class="form-group">
                <label>Category</label>
                <select name="p_category" required>
                    <option value="">Select Category</option>
                    <% for (String category : categories) { %>
                        <option value="<%= category %>"><%= category %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label>Price (&#8377;)</label>
                <input type="number" name="p_price" placeholder="e.g. 2500" step="0.01" min="0" required>
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="p_desc" rows="3" placeholder="Describe the fabric or style..." required></textarea>
            </div>
            <div class="form-group">
                <label>Image File Name</label>
                <input type="text" name="p_image" placeholder="e.g. saree_1.jpeg" required>
                <small style="color: #64748b; font-size: 12px; margin-top: 4px; display: block;">Must match the exact filename in the product_img folder.</small>
            </div>
            <button type="submit" class="btn-primary" style="width: 100%;">Save Product to Gallery</button>
        </form>
    </div>

<jsp:include page="/common/admin-footer.jsp" />
