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

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("adminDashboard.jsp");
        return;
    }

    int pid = Integer.parseInt(idStr);
    String pName = "", pCategory = "", pPrice = "", pImage = "", pDesc = "";
    try (Connection conn = DBConnect.getConn();
         PreparedStatement ps = conn.prepareStatement("SELECT * FROM products WHERE p_id = ?")) {
        ps.setInt(1, pid);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                pName = rs.getString("p_name");
                pCategory = rs.getString("p_category");
                pPrice = rs.getString("p_price");
                pImage = rs.getString("p_image");
                pDesc = rs.getString("p_desc");
            } else {
                response.sendRedirect("adminDashboard.jsp");
                return;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("adminDashboard.jsp");
        return;
    }

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

    request.setAttribute("adminActivePage", "products");
    request.setAttribute("adminPageTitle", "Edit Product");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Product - Admin Panel</title>
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
        <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="btn-secondary" style="margin-bottom: 20px; display: inline-block;">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
        <h2><i class="fas fa-edit" style="color: #3b82f6; margin-right: 8px;"></i>Edit Product</h2>
        <form action="${pageContext.request.contextPath}/EditProductServlet" method="post">
            <input type="hidden" name="id" value="<%= pid %>">
            <div class="form-group">
                <label>Product Name</label>
                <input type="text" name="p_name" value="<%= pName %>" required>
            </div>
            <div class="form-group">
                <label>Category</label>
                <select name="p_category" required>
                    <% for (String category : categories) { %>
                        <option value="<%= category %>" <%= category.equals(pCategory) ? "selected" : "" %>><%= category %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label>Price (&#8377;)</label>
                <input type="number" name="p_price" value="<%= pPrice %>" step="0.01" min="0" required>
            </div>
            <div class="form-group">
                <label>Description</label>
                <textarea name="p_desc" rows="3" required><%= pDesc %></textarea>
            </div>
            <div class="form-group">
                <label>Image File Name</label>
                <input type="text" name="p_image" value="<%= pImage %>" required>
            </div>
            <button type="submit" class="btn-primary" style="width: 100%;">Update Product</button>
        </form>
    </div>

<jsp:include page="/common/admin-footer.jsp" />
