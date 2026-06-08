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

@WebServlet("/AdminOrderServlet")
public class AdminOrderServlet extends HttpServlet {
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
        String orderIdStr = request.getParameter("orderId");

        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            session.setAttribute("failedMsg", "Order ID is required.");
            response.sendRedirect("adminOrders.jsp");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);

            if ("updateStatus".equals(action)) {
                String status = request.getParameter("status");
                if (status == null || status.trim().isEmpty()) {
                    session.setAttribute("failedMsg", "Status is required.");
                    response.sendRedirect("adminOrders.jsp");
                    return;
                }

                try (Connection conn = DBConnect.getConn()) {
                    if ("shipped".equalsIgnoreCase(status) || "delivered".equalsIgnoreCase(status)) {
                        String validationSql = "SELECT payment_method, payment_status, approval_status FROM orders WHERE o_id = ?";
                        try (PreparedStatement psValidate = conn.prepareStatement(validationSql)) {
                            psValidate.setInt(1, orderId);
                            try (ResultSet rsValidate = psValidate.executeQuery()) {
                                if (rsValidate.next()) {
                                    String paymentMethod = rsValidate.getString("payment_method");
                                    String paymentStatus = rsValidate.getString("payment_status");
                                    String approvalStatus = rsValidate.getString("approval_status");

                                    if (!"approved".equalsIgnoreCase(approvalStatus)) {
                                        session.setAttribute("failedMsg", "Order must be approved before it can be marked " + status + ".");
                                        response.sendRedirect("adminOrders.jsp");
                                        return;
                                    }
                                    if (!"COD".equalsIgnoreCase(paymentMethod) && !"completed".equalsIgnoreCase(paymentStatus)) {
                                        session.setAttribute("failedMsg", "Payment must be completed before shipping or delivering the order.");
                                        response.sendRedirect("adminOrders.jsp");
                                        return;
                                    }
                                } else {
                                    session.setAttribute("failedMsg", "Order not found.");
                                    response.sendRedirect("adminOrders.jsp");
                                    return;
                                }
                            }
                        }
                    }

                    try (PreparedStatement ps = conn.prepareStatement("UPDATE orders SET status = ? WHERE o_id = ?")) {
                        ps.setString(1, status.trim());
                        ps.setInt(2, orderId);
                        int result = ps.executeUpdate();
                        if (result == 1) {
                            session.setAttribute("succMsg", "Order #" + orderId + " status updated to " + status + ".");
                            if ("shipped".equalsIgnoreCase(status)) {
                                sendNotification(orderId, "order_shipped", "Your order has been shipped and is on its way.");
                            } else if ("delivered".equalsIgnoreCase(status)) {
                                sendNotification(orderId, "order_delivered", "Your order has been delivered. Thank you for shopping with us!");
                            } else if ("out_of_stock".equalsIgnoreCase(status)) {
                                sendNotification(orderId, "order_placed", "Your order is currently out of stock. We will update you once it is available.");
                            }
                        } else {
                            session.setAttribute("failedMsg", "Order not found or could not be updated.");
                        }
                    }
                }
            } else if ("deleteOrder".equals(action)) {
                try (Connection conn = DBConnect.getConn();
                     PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE o_id = ?")) {
                    ps.setInt(1, orderId);
                    int result = ps.executeUpdate();
                    if (result == 1) {
                        session.setAttribute("succMsg", "Order #" + orderId + " deleted successfully.");
                    } else {
                        session.setAttribute("failedMsg", "Order not found or could not be deleted.");
                    }
                }
            } else {
                session.setAttribute("failedMsg", "Unknown action.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("failedMsg", "Invalid order ID.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error: " + e.getMessage());
        }

        response.sendRedirect("adminOrders.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("adminOrders.jsp");
    }

    private void sendNotification(int orderId, String notificationType, String message) {
        try (Connection conn = DBConnect.getConn()) {
            String getUserSql = "SELECT user_id FROM orders WHERE o_id = ?";
            try (PreparedStatement getPs = conn.prepareStatement(getUserSql)) {
                getPs.setInt(1, orderId);
                try (ResultSet rs = getPs.executeQuery()) {
                    if (rs.next()) {
                        String userId = rs.getString("user_id");
                        String insertSql = "INSERT INTO order_notifications (o_id, user_id, notification_type, message) VALUES (?, ?, ?, ?)";
                        try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                            insertPs.setInt(1, orderId);
                            insertPs.setString(2, userId);
                            insertPs.setString(3, notificationType);
                            insertPs.setString(4, message);
                            insertPs.executeUpdate();
                            try {
                                com.utility.EmailUtility.sendOrderStatusUpdateAsync(userId, orderId, notificationType, message);
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
