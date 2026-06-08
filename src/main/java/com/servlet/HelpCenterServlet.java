package com.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.conn.DBConnect;
import com.utility.EmailUtility;

@WebServlet("/HelpCenterServlet")
public class HelpCenterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("auth.jsp");
            return;
        }

        String userId = request.getParameter("user_id");
        if (userId == null || userId.trim().isEmpty()) userId = session.getAttribute("user").toString();
        String subject = request.getParameter("subject");
        String message = request.getParameter("message");

        if (subject == null || subject.trim().isEmpty() || message == null || message.trim().isEmpty()) {
            session.setAttribute("failedMsg", "Subject and message are required.");
            response.sendRedirect("helpcenter.jsp");
            return;
        }

        try (Connection conn = DBConnect.getConn()) {
            // ensure table exists
            try (Statement st = conn.createStatement()) {
                st.executeUpdate("CREATE TABLE IF NOT EXISTS help_tickets (id INT AUTO_INCREMENT PRIMARY KEY, user_id VARCHAR(255), subject VARCHAR(255), message TEXT, status VARCHAR(50), admin_response TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
            }

            String insertSql = "INSERT INTO help_tickets (user_id, subject, message, status) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, userId);
                ps.setString(2, subject.trim());
                ps.setString(3, message.trim());
                ps.setString(4, "open");
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int ticketId = rs.getInt(1);
                        session.setAttribute("succMsg", "Ticket #" + ticketId + " submitted. Our support will contact you shortly.");
                        // send confirmation email async
                        try {
                            EmailUtility.sendOrderStatusUpdateAsync(userId, ticketId, "Ticket Submitted", "We have received your support request: " + subject);
                        } catch (Exception e) { e.printStackTrace(); }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Failed to submit ticket: " + e.getMessage());
            response.sendRedirect("helpcenter.jsp");
            return;
        }

        response.sendRedirect("profile.jsp");
    }
}
