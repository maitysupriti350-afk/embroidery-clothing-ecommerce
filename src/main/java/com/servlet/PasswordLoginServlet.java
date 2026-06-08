package com.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.conn.DBConnect;

@WebServlet("/PasswordLoginServlet")
public class PasswordLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uid = request.getParameter("userid");
        String pwd = request.getParameter("password");
        if (uid == null || pwd == null || uid.trim().isEmpty() || pwd.trim().isEmpty()) {
            response.sendRedirect("auth.jsp?error=invalid_input");
            return;
        }

        String sql = "SELECT password FROM user WHERE userid = ?";
        try (Connection conn = DBConnect.getConn(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, uid);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String stored = rs.getString("password");
                    // Note: In production, use password hashing (BCrypt, Argon2, etc.)
                    // This is a simple comparison for demonstration purposes
                    if (stored != null && stored.equals(pwd)) {
                        HttpSession session = request.getSession();
                        session.setAttribute("user", uid);
                        // preserve admin check
                        String adminEmails = System.getenv("ADMIN_EMAILS");
                        if (adminEmails == null || adminEmails.trim().isEmpty()) adminEmails = System.getProperty("admin.emails", "maitysupriti350@gmail.com");
                        boolean isAdmin = false;
                        for (String a : adminEmails.split("\\s*,\\s*")) {
                            if (a != null && !a.trim().isEmpty() && uid.equalsIgnoreCase(a.trim())) { isAdmin = true; break; }
                        }
                        if (isAdmin) {
                            // Admins must sign in via admin portal only
                            response.sendRedirect("adminAuth.jsp?notice=use_admin_login");
                            return;
                        } else {
                            session.setAttribute("user", uid);
                            session.removeAttribute("isAdmin");
                            response.sendRedirect("dashboard.jsp");
                            return;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("auth.jsp?error=invalid_credentials");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("auth.jsp");
    }
}
