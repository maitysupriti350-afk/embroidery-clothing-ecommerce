package com.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
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

@WebServlet("/PlaceOrderServlet")
public class PlaceOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("auth.jsp");
            return;
        }

        String userId = session.getAttribute("user").toString();
        String shippingAddress = request.getParameter("shipping_address");
        String shippingPincode = request.getParameter("shipping_pincode");
        String locationVerified = request.getParameter("location_verified");
        String paymentMethod = request.getParameter("payment_method");
        String couponCode = request.getParameter("coupon_code");

        if (shippingAddress == null || shippingAddress.trim().isEmpty()) {
            session.setAttribute("failedMsg", "Shipping address is required.");
            response.sendRedirect("checkout.jsp");
            return;
        }
        if (shippingPincode == null || !shippingPincode.matches("\\d{6}")) {
            session.setAttribute("failedMsg", "A valid 6-digit shipping pincode is required.");
            response.sendRedirect("checkout.jsp");
            return;
        }
        if (!"true".equals(locationVerified)) {
            session.setAttribute("failedMsg", "Please verify your location and pincode before placing the order.");
            response.sendRedirect("checkout.jsp");
            return;
        }
        if (!shippingAddress.contains(shippingPincode)) {
            session.setAttribute("failedMsg", "The pincode must match the shipping address. Please confirm your address and pincode.");
            response.sendRedirect("checkout.jsp");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnect.getConn();
            conn.setAutoCommit(false);

            // Calculate total from cart
            String totalSql = "SELECT SUM(p_price * quantity) as total FROM cart WHERE user_id = ?";
            BigDecimal totalAmount = BigDecimal.ZERO;
            try (PreparedStatement psTotal = conn.prepareStatement(totalSql)) {
                psTotal.setString(1, userId);
                try (ResultSet rs = psTotal.executeQuery()) {
                    if (rs.next()) {
                        BigDecimal dbTotal = rs.getBigDecimal("total");
                        if (dbTotal != null) {
                            totalAmount = dbTotal;
                        }
                    }
                }
            }

            if (totalAmount.compareTo(BigDecimal.ZERO) == 0) {
                session.setAttribute("failedMsg", "Your cart is empty.");
                response.sendRedirect("cart.jsp");
                return;
            }

            BigDecimal discount = BigDecimal.ZERO;
            boolean couponApplied = false;
            if (couponCode != null && !couponCode.trim().isEmpty()) {
                couponCode = couponCode.trim().toUpperCase();
                try (PreparedStatement psC = conn.prepareStatement("SELECT * FROM coupons WHERE code = ? AND active = TRUE")) {
                    psC.setString(1, couponCode);
                    try (ResultSet rsC = psC.executeQuery()) {
                        if (!rsC.next()) {
                            session.setAttribute("failedMsg", "Invalid or inactive coupon code.");
                            response.sendRedirect("checkout.jsp");
                            return;
                        }
                        String type = rsC.getString("type");
                        BigDecimal value = rsC.getBigDecimal("value");
                        BigDecimal maxDiscount = rsC.getBigDecimal("max_discount");
                        boolean firstOnly = rsC.getBoolean("first_order_only");
                        int usageLimit = rsC.getInt("usage_limit");
                        int uses = rsC.getInt("uses");
                        java.sql.Timestamp expiresAt = rsC.getTimestamp("expires_at");

                        if (expiresAt != null && expiresAt.before(new java.util.Date())) {
                            session.setAttribute("failedMsg", "Coupon has expired.");
                            response.sendRedirect("checkout.jsp");
                            return;
                        }
                        if (usageLimit > 0 && uses >= usageLimit) {
                            session.setAttribute("failedMsg", "Coupon usage limit reached.");
                            response.sendRedirect("checkout.jsp");
                            return;
                        }
                        if (firstOnly) {
                            try (PreparedStatement psCount = conn.prepareStatement("SELECT COUNT(*) FROM orders WHERE user_id = ?")) {
                                psCount.setString(1, userId);
                                try (ResultSet rsCount = psCount.executeQuery()) {
                                    if (rsCount.next() && rsCount.getInt(1) > 0) {
                                        session.setAttribute("failedMsg", "This coupon is valid only for your first order.");
                                        response.sendRedirect("checkout.jsp");
                                        return;
                                    }
                                }
                            }
                        }

                        if ("percent".equalsIgnoreCase(type)) {
                            discount = totalAmount.multiply(value).divide(new BigDecimal("100")).setScale(2, RoundingMode.HALF_UP);
                            if (maxDiscount != null && discount.compareTo(maxDiscount) > 0) discount = maxDiscount;
                        } else {
                            discount = value.setScale(2, RoundingMode.HALF_UP);
                        }
                        couponApplied = true;
                    }
                }
            }

            BigDecimal finalAmount = totalAmount.subtract(discount);
            if (finalAmount.compareTo(BigDecimal.ZERO) < 0) {
                finalAmount = BigDecimal.ZERO;
            }

            // Insert order
            String orderSql = "INSERT INTO orders (user_id, total_amount, shipping_address, shipping_pincode, location_verified, payment_method, payment_status, approval_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            int orderId;
            try (PreparedStatement psOrder = conn.prepareStatement(orderSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                psOrder.setString(1, userId);
                psOrder.setBigDecimal(2, finalAmount);
                psOrder.setString(3, shippingAddress);
                psOrder.setString(4, shippingPincode);
                psOrder.setBoolean(5, true);
                String finalPaymentMethod = paymentMethod != null ? paymentMethod : "COD";
                psOrder.setString(6, finalPaymentMethod);
                psOrder.setString(7, "pending");
                psOrder.setString(8, "pending_review");
                psOrder.executeUpdate();

                try (ResultSet rs = psOrder.getGeneratedKeys()) {
                    if (rs.next()) {
                        orderId = rs.getInt(1);
                    } else {
                        throw new Exception("Failed to get order ID");
                    }
                }
            }

            // Insert order items and clear cart
            String cartSql = "SELECT * FROM cart WHERE user_id = ?";
            String insertItemSql = "INSERT INTO order_items (o_id, p_id, p_name, p_price, p_image, size, quantity, subtotal) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            String deleteCartSql = "DELETE FROM cart WHERE user_id = ?";

            try (PreparedStatement psCart = conn.prepareStatement(cartSql);
                 PreparedStatement psItem = conn.prepareStatement(insertItemSql);
                 PreparedStatement psDelete = conn.prepareStatement(deleteCartSql)) {

                psCart.setString(1, userId);
                try (ResultSet rs = psCart.executeQuery()) {
                    while (rs.next()) {
                        psItem.setInt(1, orderId);
                        psItem.setInt(2, rs.getInt("p_id"));
                        psItem.setString(3, rs.getString("p_name"));
                        psItem.setBigDecimal(4, rs.getBigDecimal("p_price"));
                        psItem.setString(5, rs.getString("p_image"));
                        psItem.setString(6, rs.getString("size"));
                        psItem.setInt(7, rs.getInt("quantity"));
                        psItem.setBigDecimal(8, rs.getBigDecimal("p_price").multiply(BigDecimal.valueOf(rs.getInt("quantity"))));
                        psItem.executeUpdate();
                    }
                }

                psDelete.setString(1, userId);
                psDelete.executeUpdate();
            }
            // Record coupon usage and increment coupon counter if applied
            if (couponApplied) {
                try (PreparedStatement psUsage = conn.prepareStatement("INSERT INTO coupon_usage (code, user_id, order_id) VALUES (?, ?, ?)")) {
                    psUsage.setString(1, couponCode);
                    psUsage.setString(2, userId);
                    psUsage.setInt(3, orderId);
                    psUsage.executeUpdate();
                }
                try (PreparedStatement psInc = conn.prepareStatement("UPDATE coupons SET uses = uses + 1 WHERE code = ?")) {
                    psInc.setString(1, couponCode);
                    psInc.executeUpdate();
                }
            }

            conn.commit();

            session.setAttribute("succMsg", "Order placed successfully! Order ID: " + orderId);

            // Send order placed email asynchronously (best effort)
            try {
                com.utility.EmailUtility.sendOrderPlacedAsync(userId, orderId);
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            response.sendRedirect(request.getContextPath() + "/OrdersServlet?msg=placed");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (Exception rb) {
                rb.printStackTrace();
            }
            session.setAttribute("failedMsg", "Failed to place order: " + e.getMessage());
            response.sendRedirect("checkout.jsp");
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignore) {
            }
        }
    }
}