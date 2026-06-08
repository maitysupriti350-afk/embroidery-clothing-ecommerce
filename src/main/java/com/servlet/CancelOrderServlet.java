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

@WebServlet("/CancelOrderServlet")
public class CancelOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth.jsp");
            return;
        }

        String userid = (String) session.getAttribute("user");
        String orderIdParam = request.getParameter("order_id");
        if (orderIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/OrdersServlet");
            return;
        }

        int orderId = Integer.parseInt(orderIdParam);

        String selectSql = "SELECT status FROM orders WHERE o_id = ? AND user_id = ?";
        String updateSql = "UPDATE orders SET status = ? WHERE o_id = ? AND user_id = ?";

        try (Connection conn = DBConnect.getConn();
             PreparedStatement psSelect = conn.prepareStatement(selectSql)) {

            psSelect.setInt(1, orderId);
            psSelect.setString(2, userid);
            try (ResultSet rs = psSelect.executeQuery()) {
                if (!rs.next()) {
                    // order not found or not belongs to user
                    response.sendRedirect(request.getContextPath() + "/OrdersServlet?msg=notfound");
                    return;
                }

                String status = rs.getString("status");
                // Allow cancel only if not shipped/out for delivery/delivered/cancelled
                if (status == null) status = "";
                String lower = status.toLowerCase();
                if (lower.contains("shipped") || lower.contains("out for") || lower.contains("delivered") || lower.contains("cancelled")) {
                    response.sendRedirect(request.getContextPath() + "/OrdersServlet?msg=not_allowed");
                    return;
                }

                try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                    psUpdate.setString(1, "Cancelled");
                    psUpdate.setInt(2, orderId);
                    psUpdate.setString(3, userid);
                    psUpdate.executeUpdate();
                }

                // Send cancellation email (best effort)
                try {
                    EmailUtility.sendOrderCancellation(userid, orderId);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                response.sendRedirect(request.getContextPath() + "/OrdersServlet?msg=cancelled");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/OrdersServlet?msg=error");
        }
    }
}
