package com.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.conn.DBConnect;

@WebServlet("/DeleteProductServlet")
public class DeleteProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
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
            session.setAttribute("failedMsg", "Invalid product ID.");
            response.sendRedirect("adminDashboard.jsp");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            try (Connection conn = DBConnect.getConn();
                 PreparedStatement ps = conn.prepareStatement("DELETE FROM products WHERE p_id = ?")) {
                ps.setInt(1, id);
                int result = ps.executeUpdate();
                if (result == 1) {
                    session.setAttribute("succMsg", "Product deleted successfully.");
                } else {
                    session.setAttribute("failedMsg", "Product not found or could not be deleted.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error deleting product: " + e.getMessage());
        }

        response.sendRedirect("adminDashboard.jsp");
    }
}