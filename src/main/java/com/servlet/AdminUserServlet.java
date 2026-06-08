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

@WebServlet("/AdminUserServlet")
public class AdminUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        String action = request.getParameter("action");

        if ("deleteUser".equals(action)) {
            String userId = request.getParameter("userId");
            if (userId == null || userId.trim().isEmpty()) {
                session.setAttribute("failedMsg", "User ID is required.");
                response.sendRedirect("adminUsers.jsp");
                return;
            }

            // Prevent admin from deleting themselves
            String currentUser = session.getAttribute("user").toString();
            if (userId.equals(currentUser)) {
                session.setAttribute("failedMsg", "You cannot delete your own account.");
                response.sendRedirect("adminUsers.jsp");
                return;
            }

            try (Connection conn = DBConnect.getConn()) {
                // Delete user's cart items first
                try (PreparedStatement psCart = conn.prepareStatement("DELETE FROM cart WHERE user_id = ?")) {
                    psCart.setString(1, userId);
                    psCart.executeUpdate();
                }
                // Delete user's wishlist items
                try (PreparedStatement psWish = conn.prepareStatement("DELETE FROM wishlist WHERE user_id = ?")) {
                    psWish.setString(1, userId);
                    psWish.executeUpdate();
                }
                // Delete user's order items (via orders cascade)
                try (PreparedStatement psOrders = conn.prepareStatement("DELETE FROM orders WHERE user_id = ?")) {
                    psOrders.setString(1, userId);
                    psOrders.executeUpdate();
                }
                // Delete user
                try (PreparedStatement psUser = conn.prepareStatement("DELETE FROM user WHERE userid = ?")) {
                    psUser.setString(1, userId);
                    int result = psUser.executeUpdate();
                    if (result == 1) {
                        session.setAttribute("succMsg", "User '" + userId + "' deleted successfully.");
                    } else {
                        session.setAttribute("failedMsg", "User not found or could not be deleted.");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("failedMsg", "Error deleting user: " + e.getMessage());
            }
        } else {
            session.setAttribute("failedMsg", "Unknown action.");
        }

        response.sendRedirect("adminUsers.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("adminUsers.jsp");
    }
}
