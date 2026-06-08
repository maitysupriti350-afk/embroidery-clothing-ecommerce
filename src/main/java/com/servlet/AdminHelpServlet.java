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
import com.utility.EmailUtility;

@WebServlet("/AdminHelpServlet")
public class AdminHelpServlet extends HttpServlet {
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
        String ticketIdStr = request.getParameter("ticketId");
        if (ticketIdStr == null) {
            session.setAttribute("failedMsg", "Ticket ID missing.");
            response.sendRedirect("adminHelp.jsp");
            return;
        }

        try (Connection conn = DBConnect.getConn()) {
            int tid = Integer.parseInt(ticketIdStr);
            if ("respond".equals(action)) {
                String responseText = request.getParameter("response");
                if (responseText == null || responseText.trim().isEmpty()) {
                    session.setAttribute("failedMsg", "Response cannot be empty.");
                    response.sendRedirect("adminHelp.jsp");
                    return;
                }
                String getUserSql = "SELECT user_id FROM help_tickets WHERE id = ?";
                try (PreparedStatement psGet = conn.prepareStatement(getUserSql)) {
                    psGet.setInt(1, tid);
                    try (ResultSet rs = psGet.executeQuery()) {
                        if (rs.next()) {
                            String userId = rs.getString("user_id");
                            try (PreparedStatement ps = conn.prepareStatement("UPDATE help_tickets SET admin_response = ?, status = ? WHERE id = ?")) {
                                ps.setString(1, responseText.trim());
                                ps.setString(2, "responded");
                                ps.setInt(3, tid);
                                ps.executeUpdate();
                            }
                            // send email to user asynchronously
                            try { EmailUtility.sendOrderStatusUpdateAsync(userId, tid, "Support Reply", responseText.trim()); } catch (Exception e) { e.printStackTrace(); }
                            session.setAttribute("succMsg", "Responded to ticket #" + tid);
                        } else {
                            session.setAttribute("failedMsg", "Ticket not found.");
                        }
                    }
                }
            } else if ("close".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement("UPDATE help_tickets SET status = ? WHERE id = ?")) {
                    ps.setString(1, "closed");
                    ps.setInt(2, Integer.parseInt(ticketIdStr));
                    int res = ps.executeUpdate();
                    if (res == 1) session.setAttribute("succMsg", "Ticket closed."); else session.setAttribute("failedMsg", "Ticket not found or could not be closed.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error: " + e.getMessage());
        }

        response.sendRedirect("adminHelp.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("adminHelp.jsp");
    }
}
