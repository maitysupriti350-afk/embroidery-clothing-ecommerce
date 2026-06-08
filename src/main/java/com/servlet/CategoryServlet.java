package com.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.conn.DBConnect;

@WebServlet("/CategoryServlet")
public class CategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // Security check - only admin can manage categories
        if (session.getAttribute("user") == null) {
            response.sendRedirect("auth.jsp");
            return;
        }
        Boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin"));
        if (!isAdmin) {
            response.sendRedirect("dashboard.jsp");
            return;
        }

        String action = request.getParameter("action");
        String message = "";
        String messageType = "succMsg";

        try (Connection conn = DBConnect.getConn()) {
            if ("add".equals(action)) {
                String categoryName = request.getParameter("category_name");
                String categoryDescription = request.getParameter("category_description");
                int displayOrder = Integer.parseInt(request.getParameter("display_order"));

                String sql = "INSERT INTO categories (category_name, category_description, display_order, is_active) VALUES (?, ?, ?, TRUE)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, categoryName);
                    ps.setString(2, categoryDescription);
                    ps.setInt(3, displayOrder);
                    ps.executeUpdate();
                    message = "Category '" + categoryName + "' added successfully!";
                }
            } else if ("toggle".equals(action)) {
                int categoryId = Integer.parseInt(request.getParameter("category_id"));
                
                String sql = "UPDATE categories SET is_active = NOT is_active WHERE category_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, categoryId);
                    ps.executeUpdate();
                    message = "Category status updated successfully!";
                }
            } else if ("delete".equals(action)) {
                int categoryId = Integer.parseInt(request.getParameter("category_id"));
                
                // Check if category has products
                String checkSql = "SELECT COUNT(*) FROM products WHERE category_id = ?";
                try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                    checkPs.setInt(1, categoryId);
                    ResultSet rs = checkPs.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
                        message = "Cannot delete category with existing products. Please reassign or delete products first.";
                        messageType = "failedMsg";
                    } else {
                        String sql = "DELETE FROM categories WHERE category_id = ?";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            ps.setInt(1, categoryId);
                            ps.executeUpdate();
                            message = "Category deleted successfully!";
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Error: " + e.getMessage();
            messageType = "failedMsg";
        }

        session.setAttribute(messageType, message);
        response.sendRedirect("adminCategories.jsp");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}
