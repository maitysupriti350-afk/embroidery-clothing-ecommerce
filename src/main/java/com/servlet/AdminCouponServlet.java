package com.servlet;

import com.conn.DBConnect;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/AdminCouponServlet")
public class AdminCouponServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try (Connection conn = DBConnect.getConn()) {
            String orderColumn = DBConnect.hasColumn(conn, "coupons", "created_at") ? "created_at" : "code";
            try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM coupons ORDER BY " + orderColumn + " DESC")) {
                try (ResultSet rs = ps.executeQuery()) {
                    List<Map<String,Object>> coupons = new ArrayList<>();
                    while (rs.next()) {
                        Map<String,Object> c = new HashMap<>();
                        c.put("code", rs.getString("code"));
                        c.put("type", rs.getString("type"));
                        c.put("value", rs.getBigDecimal("value"));
                        c.put("max_discount", rs.getBigDecimal("max_discount"));
                        c.put("first_order_only", rs.getBoolean("first_order_only"));
                        c.put("usage_limit", rs.getInt("usage_limit"));
                        c.put("uses", rs.getInt("uses"));
                        c.put("active", rs.getBoolean("active"));
                        c.put("expires_at", rs.getTimestamp("expires_at"));
                        coupons.add(c);
                    }
                    req.setAttribute("coupons", coupons);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", e.getMessage());
        }
        req.getRequestDispatcher("/adminCoupons.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try (Connection conn = DBConnect.getConn()) {
            if ("create".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement("INSERT INTO coupons (code,type,value,max_discount,first_order_only,usage_limit,active,expires_at) VALUES (?,?,?,?,?,?,?,?)")) {
                    ps.setString(1, req.getParameter("code").trim().toUpperCase());
                    ps.setString(2, req.getParameter("type"));
                    ps.setBigDecimal(3, new java.math.BigDecimal(req.getParameter("value")));
                    String md = req.getParameter("max_discount");
                    if (md == null || md.isEmpty()) ps.setNull(4, java.sql.Types.DECIMAL); else ps.setBigDecimal(4, new java.math.BigDecimal(md));
                    ps.setBoolean(5, "on".equals(req.getParameter("first")));
                    String ul = req.getParameter("usage_limit");
                    if (ul == null || ul.isEmpty()) ps.setInt(6, 0); else ps.setInt(6, Integer.parseInt(ul));
                    ps.setBoolean(7, true);
                    String exp = req.getParameter("expires_at");
                    if (exp == null || exp.isEmpty()) ps.setNull(8, java.sql.Types.TIMESTAMP); else ps.setTimestamp(8, java.sql.Timestamp.valueOf(exp));
                    ps.executeUpdate();
                }
            } else if ("toggle".equals(action)) {
                String code = req.getParameter("code");
                try (PreparedStatement ps = conn.prepareStatement("UPDATE coupons SET active = NOT active WHERE code = ?")) { 
                    ps.setString(1, code); 
                    ps.executeUpdate(); 
                }
            } else if ("delete".equals(action)) {
                String code = req.getParameter("code");
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM coupons WHERE code = ?")) { ps.setString(1, code); ps.executeUpdate(); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        resp.sendRedirect(req.getContextPath() + "/AdminCouponServlet");
    }
}
