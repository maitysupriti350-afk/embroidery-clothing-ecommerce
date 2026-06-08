package com.servlet;

import com.conn.DBConnect;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/RewardUsageServlet")
public class RewardUsageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String userId = req.getSession(false) != null ? (String) req.getSession(false).getAttribute("user") : null;
        try (PrintWriter out = resp.getWriter()) {
            if (userId == null) {
                out.print("{\"valid\":false,\"message\":\"User not signed in\"}");
                return;
            }
            try (Connection conn = DBConnect.getConn()) {
                try (PreparedStatement ps = conn.prepareStatement("SELECT spin_used, card_used, scratch_used FROM reward_game_usage WHERE user_id = ?")) {
                    ps.setString(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            out.print("{\"valid\":true,\"spinUsed\":" + rs.getBoolean("spin_used") + ",\"cardUsed\":" + rs.getBoolean("card_used") + ",\"scratchUsed\":" + rs.getBoolean("scratch_used") + "}");
                        } else {
                            out.print("{\"valid\":true,\"spinUsed\":false,\"cardUsed\":false,\"scratchUsed\":false}");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            try {
                resp.getWriter().print("{\"valid\":false,\"message\":\"Server error fetching game usage\"}");
            } catch (Exception ex) {
                // Ignore if response already committed
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String userId = req.getSession(false) != null ? (String) req.getSession(false).getAttribute("user") : null;
        String game = req.getParameter("game");
        try (PrintWriter out = resp.getWriter()) {
            if (userId == null) {
                out.print("{\"valid\":false,\"message\":\"User not signed in\"}");
                return;
            }
            if (game == null || !(game.equals("spin") || game.equals("card") || game.equals("scratch"))) {
                out.print("{\"valid\":false,\"message\":\"Invalid game type\"}");
                return;
            }
            String column = game + "_used";
            try (Connection conn = DBConnect.getConn()) {
                conn.setAutoCommit(false);
                boolean used;
                try (PreparedStatement ps = conn.prepareStatement("SELECT " + column + " FROM reward_game_usage WHERE user_id = ? FOR UPDATE")) {
                    ps.setString(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            used = rs.getBoolean(column);
                        } else {
                            used = false;
                        }
                    }
                }
                if (used) {
                    out.print("{\"valid\":false,\"message\":\"You have already used your one chance for this game.\"}");
                    conn.rollback();
                    return;
                }
                try (PreparedStatement psUpsert = conn.prepareStatement(
                        "INSERT INTO reward_game_usage (user_id, spin_used, card_used, scratch_used) VALUES (?, ?, ?, ?) " +
                        "ON DUPLICATE KEY UPDATE " + column + " = TRUE")) {
                    psUpsert.setString(1, userId);
                    psUpsert.setBoolean(2, game.equals("spin"));
                    psUpsert.setBoolean(3, game.equals("card"));
                    psUpsert.setBoolean(4, game.equals("scratch"));
                    psUpsert.executeUpdate();
                }
                conn.commit();
            }
            out.print("{\"valid\":true,\"message\":\"Game chance recorded\"}");
        } catch (Exception e) {
            e.printStackTrace();
            try {
                resp.getWriter().print("{\"valid\":false,\"message\":\"Server error recording game usage\"}");
            } catch (Exception ex) {
                // Ignore if response already committed
            }
        }
    }
}
