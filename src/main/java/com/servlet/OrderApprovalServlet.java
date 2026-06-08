package com.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.conn.DBConnect;

@WebServlet("/OrderApprovalServlet")
public class OrderApprovalServlet extends HttpServlet {
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
            String adminId = session.getAttribute("user").toString();

            if ("verifyAddress".equals(action)) {
                verifyAddress(orderId, adminId, session, response);
            } else if ("verifyLocation".equals(action)) {
                verifyLocation(orderId, adminId, session, response);
            } else if ("verifyPayment".equals(action)) {
                verifyPayment(orderId, adminId, session, response);
            } else if ("approveOrder".equals(action)) {
                approveOrder(orderId, adminId, request, session, response);
            } else if ("rejectOrder".equals(action)) {
                rejectOrder(orderId, adminId, request, session, response);
            } else {
                session.setAttribute("failedMsg", "Unknown action.");
                response.sendRedirect("adminOrders.jsp");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("failedMsg", "Invalid order ID.");
            response.sendRedirect("adminOrders.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error: " + e.getMessage());
            response.sendRedirect("adminOrders.jsp");
        }
    }

    private void verifyAddress(int orderId, String adminId, HttpSession session, HttpServletResponse response) throws Exception {
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                "UPDATE orders SET address_verified = true, verified_at = ?, verified_by = ? WHERE o_id = ?")) {
            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setString(2, adminId);
            ps.setInt(3, orderId);
            int result = ps.executeUpdate();

            if (result == 1) {
                session.setAttribute("succMsg", "Address verified for Order #" + orderId);
                // Send notification to customer
                sendNotification(orderId, "address_verification_required", 
                    "Your address has been verified. Awaiting payment verification.");
            } else {
                session.setAttribute("failedMsg", "Order not found.");
            }
        }
        response.sendRedirect("adminOrders.jsp");
    }

    private void verifyLocation(int orderId, String adminId, HttpSession session, HttpServletResponse response) throws Exception {
        try (Connection conn = DBConnect.getConn()) {
            String selectSql = "SELECT shipping_address, shipping_pincode FROM orders WHERE o_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        session.setAttribute("failedMsg", "Order not found.");
                        response.sendRedirect("adminOrders.jsp");
                        return;
                    }

                    String shippingAddress = rs.getString("shipping_address");
                    String shippingPincode = rs.getString("shipping_pincode");
                    boolean pincodeMatch = shippingPincode != null && shippingAddress != null && shippingAddress.contains(shippingPincode);

                    if (!pincodeMatch) {
                        session.setAttribute("failedMsg", "Pincode does not match the shipping address for Order #" + orderId + ". Please review shipping details.");
                        response.sendRedirect("adminOrders.jsp");
                        return;
                    }
                }
            }

            try (PreparedStatement psUpdate = conn.prepareStatement(
                    "UPDATE orders SET location_verified = true, verified_at = ?, verified_by = ? WHERE o_id = ?")) {
                psUpdate.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
                psUpdate.setString(2, adminId);
                psUpdate.setInt(3, orderId);
                int result = psUpdate.executeUpdate();
                if (result == 1) {
                    session.setAttribute("succMsg", "Location verified for Order #" + orderId);
                    sendNotification(orderId, "address_verification_required", "Your delivery location has been verified.");
                } else {
                    session.setAttribute("failedMsg", "Order not found.");
                }
            }
        }
        response.sendRedirect("adminOrders.jsp");
    }

    private void verifyPayment(int orderId, String adminId, HttpSession session, HttpServletResponse response) throws Exception {
        try (Connection conn = DBConnect.getConn()) {
            // Get order details
            String selectSql = "SELECT user_id, total_amount, payment_method FROM orders WHERE o_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        BigDecimal amount = rs.getBigDecimal("total_amount");
                        String paymentMethod = rs.getString("payment_method");

                        // Verify payment based on method
                        boolean paymentVerified = verifyPaymentMethod(paymentMethod, amount, orderId);

                        if (paymentVerified) {
                            // Update payment status
                            String updateSql = "UPDATE orders SET payment_status = 'completed', payment_date = ?, "
                                + "approval_status = 'pending_review' WHERE o_id = ?";
                            try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                                updatePs.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
                                updatePs.setInt(2, orderId);
                                updatePs.executeUpdate();
                            }

                            // Log verification
                            logPaymentVerification(conn, orderId, paymentMethod, amount, "verified", adminId);

                            session.setAttribute("succMsg", "Payment verified for Order #" + orderId);
                            sendNotification(orderId, "payment_received", 
                                "Payment received. Your order is being processed.");
                        } else {
                            // Mark as failed
                            String failSql = "UPDATE orders SET payment_status = 'failed', "
                                + "approval_status = 'payment_verification_failed' WHERE o_id = ?";
                            try (PreparedStatement failPs = conn.prepareStatement(failSql)) {
                                failPs.setInt(1, orderId);
                                failPs.executeUpdate();
                            }

                            logPaymentVerification(conn, orderId, paymentMethod, amount, "failed", adminId);

                            session.setAttribute("failedMsg", "Payment verification failed for Order #" + orderId);
                            sendNotification(orderId, "payment_failed", 
                                "Payment verification failed. Please contact support.");
                        }
                    } else {
                        session.setAttribute("failedMsg", "Order not found.");
                    }
                }
            }
        }
        response.sendRedirect("adminOrders.jsp");
    }

    private void approveOrder(int orderId, String adminId, HttpServletRequest request, 
                            HttpSession session, HttpServletResponse response) throws Exception {
        String approvalNotes = request.getParameter("approvalNotes");

        try (Connection conn = DBConnect.getConn()) {
            String checkSql = "SELECT payment_method, payment_status, address_verified, approval_status FROM orders WHERE o_id = ?";
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setInt(1, orderId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (!rs.next()) {
                        session.setAttribute("failedMsg", "Order not found.");
                        response.sendRedirect("adminOrders.jsp");
                        return;
                    }

                    String paymentMethod = rs.getString("payment_method");
                    String paymentStatus = rs.getString("payment_status");
                    boolean addressVerified = rs.getBoolean("address_verified");
                    String approvalStatus = rs.getString("approval_status");

                    if ("rejected".equalsIgnoreCase(approvalStatus)) {
                        session.setAttribute("failedMsg", "Order #" + orderId + " has already been rejected.");
                        response.sendRedirect("adminOrders.jsp");
                        return;
                    }
                    if (!addressVerified) {
                        session.setAttribute("failedMsg", "Please verify the shipping address before approving Order #" + orderId + ".");
                        response.sendRedirect("adminOrders.jsp");
                        return;
                    }
                    if (!"COD".equalsIgnoreCase(paymentMethod) && !"completed".equalsIgnoreCase(paymentStatus)) {
                        session.setAttribute("failedMsg", "Please verify payment before approving Order #" + orderId + ".");
                        response.sendRedirect("adminOrders.jsp");
                        return;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE orders SET approval_status = 'approved', admin_approval_date = ?, "
                + "approval_notes = ?, status = 'confirmed' WHERE o_id = ?")) {
                ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
                ps.setString(2, approvalNotes != null ? approvalNotes : "Order approved by admin");
                ps.setInt(3, orderId);
                int result = ps.executeUpdate();

                if (result == 1) {
                    session.setAttribute("succMsg", "Order #" + orderId + " approved and confirmed!");
                    sendNotification(orderId, "order_approved", 
                        "Your order has been approved and is being prepared for shipment.");
                } else {
                    session.setAttribute("failedMsg", "Order not found.");
                }
            }
        }

        response.sendRedirect("adminOrders.jsp");
    }

    private void rejectOrder(int orderId, String adminId, HttpServletRequest request, 
                            HttpSession session, HttpServletResponse response) throws Exception {
        String rejectionReason = request.getParameter("rejectionReason");

        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                "UPDATE orders SET approval_status = 'rejected', status = 'cancelled', "
                + "approval_notes = ? WHERE o_id = ?")) {
            ps.setString(1, rejectionReason != null ? rejectionReason : "Order rejected by admin");
            ps.setInt(2, orderId);
            int result = ps.executeUpdate();

            if (result == 1) {
                session.setAttribute("succMsg", "Order #" + orderId + " rejected.");
                sendNotification(orderId, "order_placed", 
                    "Your order has been rejected. Reason: " + rejectionReason);
            } else {
                session.setAttribute("failedMsg", "Order not found.");
            }
        }
        response.sendRedirect("adminOrders.jsp");
    }

    private boolean verifyPaymentMethod(String paymentMethod, BigDecimal amount, int orderId) {
        // For COD (Cash on Delivery), mark as completed immediately upon order placement
        if ("COD".equalsIgnoreCase(paymentMethod)) {
            return true;
        }
        // For other payment methods, simulate verification
        // In production, integrate with payment gateway API
        if ("card".equalsIgnoreCase(paymentMethod) || "credit_card".equalsIgnoreCase(paymentMethod) || "debit_card".equalsIgnoreCase(paymentMethod)) {
            return true; // Placeholder
        }
        if ("upi".equalsIgnoreCase(paymentMethod)) {
            return true; // Placeholder
        }
        return false;
    }

    private void logPaymentVerification(Connection conn, int orderId, String paymentMethod, 
                                       BigDecimal amount, String status, String verifiedBy) throws Exception {
        String sql = "INSERT INTO payment_verification_log (o_id, payment_method, amount, status, verified_by) "
            + "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, paymentMethod);
            ps.setBigDecimal(3, amount);
            ps.setString(4, status);
            ps.setString(5, verifiedBy);
            ps.executeUpdate();
        }
    }

    private void sendNotification(int orderId, String notificationType, String message) {
        try (Connection conn = DBConnect.getConn()) {
            // Get user_id for the order
            String getUserSql = "SELECT user_id FROM orders WHERE o_id = ?";
            try (PreparedStatement getPs = conn.prepareStatement(getUserSql)) {
                getPs.setInt(1, orderId);
                try (ResultSet rs = getPs.executeQuery()) {
                    if (rs.next()) {
                        String userId = rs.getString("user_id");
                        // Insert notification
                        String insertSql = "INSERT INTO order_notifications (o_id, user_id, notification_type, message) "
                            + "VALUES (?, ?, ?, ?)";
                        try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                            insertPs.setInt(1, orderId);
                            insertPs.setString(2, userId);
                            insertPs.setString(3, notificationType);
                            insertPs.setString(4, message);
                            insertPs.executeUpdate();
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("adminOrders.jsp");
    }
}
