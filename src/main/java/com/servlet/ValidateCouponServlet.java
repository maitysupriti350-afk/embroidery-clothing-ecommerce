package com.servlet;

import com.conn.DBConnect;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/ValidateCouponServlet")
public class ValidateCouponServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String code = req.getParameter("coupon_code");
        String userId = (String) (req.getSession(false) != null ? req.getSession(false).getAttribute("user") : null);
        String subtotalStr = req.getParameter("subtotal");
        BigDecimal subtotal = BigDecimal.ZERO;
        try { if (subtotalStr != null) subtotal = new BigDecimal(subtotalStr); } catch (Exception ignored) {}

        if (code == null || code.trim().isEmpty()) {
            try (PrintWriter out = resp.getWriter()) {
                out.print("{\"valid\":false,\"message\":\"No coupon provided\",\"amount\":0}");
            }
            return;
        }

        code = code.trim().toUpperCase();

        try (Connection conn = DBConnect.getConn()) {
            try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM coupons WHERE code = ? AND active = TRUE")) {
                ps.setString(1, code);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        try (PrintWriter out = resp.getWriter()) {
                            out.print("{\"valid\":false,\"message\":\"Coupon not found or inactive\",\"amount\":0}");
                        }
                        return;
                    }

                    String type = rs.getString("type");
                    BigDecimal value = rs.getBigDecimal("value");
                    BigDecimal maxDiscount = rs.getBigDecimal("max_discount");
                    boolean firstOnly = rs.getBoolean("first_order_only");
                    int usageLimit = rs.getInt("usage_limit");
                    int uses = rs.getInt("uses");
                    java.sql.Timestamp expiresAt = rs.getTimestamp("expires_at");

                    if (expiresAt != null && expiresAt.before(new java.util.Date())) {
                        try (PrintWriter out = resp.getWriter()) {
                            out.print("{\"valid\":false,\"message\":\"Coupon expired\",\"amount\":0}");
                        }
                        return;
                    }

                    if (usageLimit > 0 && uses >= usageLimit) {
                        try (PrintWriter out = resp.getWriter()) {
                            out.print("{\"valid\":false,\"message\":\"Coupon usage limit reached\",\"amount\":0}");
                        }
                        return;
                    }

                    if (firstOnly && userId != null) {
                        try (PreparedStatement psCount = conn.prepareStatement("SELECT COUNT(*) FROM orders WHERE user_id = ?")) {
                            psCount.setString(1, userId);
                            try (ResultSet rsCount = psCount.executeQuery()) {
                                if (rsCount.next() && rsCount.getInt(1) > 0) {
                                    try (PrintWriter out = resp.getWriter()) {
                                        out.print("{\"valid\":false,\"message\":\"Coupon valid only for first order\",\"amount\":0}");
                                    }
                                    return;
                                }
                            }
                        }
                    }

                    BigDecimal amount = BigDecimal.ZERO;
                    if ("percent".equalsIgnoreCase(type)) {
                        amount = subtotal.multiply(value).divide(new BigDecimal("100")).setScale(2, java.math.RoundingMode.HALF_UP);
                        if (maxDiscount != null && amount.compareTo(maxDiscount) > 0) amount = maxDiscount;
                    } else {
                        amount = value.setScale(2, java.math.RoundingMode.HALF_UP);
                    }

                    String msg = "Coupon applied: ";
                    if ("percent".equalsIgnoreCase(type)) msg += value.toPlainString() + "% off";
                    else msg += "₹" + value.toPlainString() + " off";

                    try (PrintWriter out = resp.getWriter()) {
                        out.print("{\"valid\":true,\"message\":\"" + msg + "\",\"amount\": " + amount.toPlainString() + "}");
                    }
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            try (PrintWriter out = resp.getWriter()) {
                out.print("{\"valid\":false,\"message\":\"Server error validating coupon\",\"amount\":0}");
            } catch (Exception ex) {
                // Ignore if response already committed
            }
        }
    }
}
