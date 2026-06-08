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

@WebServlet("/SaveProfileServlet")
public class SaveProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("auth.jsp");
            return;
        }

        String userId = session.getAttribute("user").toString();
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String membership = request.getParameter("membership");

        try (Connection conn = DBConnect.getConn()) {
            // Check if profile columns exist for this user and upsert
            String checkSql = "SELECT userid FROM user WHERE userid = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setString(1, userId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        // Update existing user profile
                        String updateSql = "UPDATE user SET full_name = ?, phone = ?, address = ?, membership = ? WHERE userid = ?";
                        try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                            psUpdate.setString(1, fullName != null ? fullName.trim() : null);
                            psUpdate.setString(2, phone != null ? phone.trim() : null);
                            psUpdate.setString(3, address != null ? address.trim() : null);
                            psUpdate.setString(4, membership != null ? membership.trim() : "Standard");
                            psUpdate.setString(5, userId);
                            int result = psUpdate.executeUpdate();
                            if (result == 1) {
                                session.setAttribute("succMsg", "Profile updated successfully.");
                            } else {
                                session.setAttribute("failedMsg", "Failed to update profile.");
                            }
                        }
                    } else {
                        session.setAttribute("failedMsg", "User not found.");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error saving profile: " + e.getMessage());
        }

        response.sendRedirect("profile.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("profile.jsp");
    }
}
