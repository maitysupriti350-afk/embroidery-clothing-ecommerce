package com.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.conn.DBConnect;

@WebServlet("/OrdersServlet")
public class OrdersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth.jsp");
            return;
        }

        String userid = (String) session.getAttribute("user");
        List<Map<String, Object>> orders = new ArrayList<>();

        String itemsSql = "SELECT p_id, quantity, p_price, p_name, p_image FROM order_items WHERE o_id = ?";

        try (Connection conn = DBConnect.getConn()) {
            boolean hasCreatedAt = DBConnect.hasColumn(conn, "orders", "created_at");
            String sql = "SELECT o_id, status, total_amount" + (hasCreatedAt ? ", created_at" : "") + ", user_id FROM orders WHERE user_id = ? ORDER BY " + (hasCreatedAt ? "created_at" : "o_id") + " DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 PreparedStatement psItems = conn.prepareStatement(itemsSql)) {

                ps.setString(1, userid);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        int orderId = rs.getInt("o_id");
                        row.put("order_id", orderId);
                        row.put("status", rs.getString("status"));
                        row.put("total", rs.getBigDecimal("total_amount"));
                        if (hasCreatedAt) {
                            row.put("placed_at", rs.getTimestamp("created_at"));
                        } else {
                            row.put("placed_at", null);
                        }
                        List<Map<String, Object>> items = new ArrayList<>();
                        psItems.setInt(1, orderId);
                    try (ResultSet irs = psItems.executeQuery()) {
                        while (irs.next()) {
                            Map<String, Object> item = new HashMap<>();
                            item.put("p_id", irs.getInt("p_id"));
                            item.put("p_name", irs.getString("p_name"));
                            item.put("p_image", irs.getString("p_image"));
                            item.put("quantity", irs.getInt("quantity"));
                            item.put("price", irs.getBigDecimal("p_price"));
                            items.add(item);
                        }
                    }
                    row.put("items", items);
                    orders.add(row);
                }
            }
        }

            request.setAttribute("orders", orders);
            request.getRequestDispatcher("/orders.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            try {
                response.getWriter().println("Error loading orders: " + e.getMessage());
            } catch (Exception ex) {
                // Ignore if response already committed
            }
        }
    }
}
