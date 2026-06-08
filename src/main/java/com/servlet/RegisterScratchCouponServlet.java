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
import java.sql.Timestamp;

@WebServlet("/RegisterScratchCouponServlet")
public class RegisterScratchCouponServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String code = req.getParameter("coupon_code");
        String userId = (String) (req.getSession(false) != null ? req.getSession(false).getAttribute("user") : null);

        try (PrintWriter out = resp.getWriter()) {
            if (userId == null) {
                out.print("{\"valid\":false,\"message\":\"Please sign in to claim scratcher coupons.\"}");
                return;
            }
            if (code == null || code.trim().isEmpty()) {
                out.print("{\"valid\":false,\"message\":\"No coupon code provided.\"}");
                return;
            }
            code = code.trim().toUpperCase();
            String type = "percent";
            BigDecimal value = BigDecimal.ZERO;
            try {
                String numeric = code.replaceAll("[^0-9]", "");
                if (!numeric.isEmpty()) {
                    value = new BigDecimal(numeric);
                }
            } catch (Exception e) {
                value = new BigDecimal("10");
            }
            if (value.compareTo(BigDecimal.ZERO) <= 0) {
                value = new BigDecimal("10");
            }
            if (value.compareTo(new BigDecimal("50")) > 0) {
                value = new BigDecimal("50");
            }

            Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + 30L * 24 * 60 * 60 * 1000);
            try (Connection conn = DBConnect.getConn()) {
                conn.setAutoCommit(false);
                boolean scratchUsed = false;
                try (PreparedStatement psCheck = conn.prepareStatement("SELECT scratch_used FROM reward_game_usage WHERE user_id = ? FOR UPDATE")) {
                    psCheck.setString(1, userId);
                    try (ResultSet rsCheck = psCheck.executeQuery()) {
                        if (rsCheck.next()) {
                            scratchUsed = rsCheck.getBoolean("scratch_used");
                        }
                    }
                }
                if (scratchUsed) {
                    out.print("{\"valid\":false,\"message\":\"You have already used your scratch chance.\"}");
                    conn.rollback();
                    return;
                }

                String upsertSql = "INSERT INTO coupons (code, type, value, max_discount, first_order_only, usage_limit, uses, active, expires_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                        "ON DUPLICATE KEY UPDATE type = VALUES(type), value = VALUES(value), max_discount = VALUES(max_discount), first_order_only = VALUES(first_order_only), usage_limit = VALUES(usage_limit), active = VALUES(active), expires_at = VALUES(expires_at)";
                try (PreparedStatement ps = conn.prepareStatement(upsertSql)) {
                    ps.setString(1, code);
                    ps.setString(2, type);
                    ps.setBigDecimal(3, value);
                    ps.setBigDecimal(4, new BigDecimal("200"));
                    ps.setBoolean(5, false);
                    ps.setInt(6, 1);
                    ps.setInt(7, 0);
                    ps.setBoolean(8, true);
                    ps.setTimestamp(9, expiresAt);
                    ps.executeUpdate();
                }
                try (PreparedStatement psUsage = conn.prepareStatement(
                        "INSERT INTO reward_game_usage (user_id, spin_used, card_used, scratch_used) VALUES (?, false, false, true) " +
                        "ON DUPLICATE KEY UPDATE scratch_used = TRUE")) {
                    psUsage.setString(1, userId);
                    psUsage.executeUpdate();
                }
                conn.commit();
                out.print("{\"valid\":true,\"message\":\"Scratch coupon registered successfully.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            try (PrintWriter out = resp.getWriter()) {
                out.print("{\"valid\":false,\"message\":\"Server error registering coupon.\"}");
            } catch (Exception ex) {
                // Ignore if response already committed
            }
        }
    }
}
