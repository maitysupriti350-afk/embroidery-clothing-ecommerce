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

@WebServlet("/AddReviewServlet")
public class AddReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain");

        String pIdStr = request.getParameter("p_id");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");
        if (pIdStr == null || ratingStr == null) {
            response.getWriter().write("error: missing parameters");
            return;
        }
        int pId;
        int rating;
        try {
            pId = Integer.parseInt(pIdStr);
            rating = Integer.parseInt(ratingStr);
        } catch (NumberFormatException e) {
            response.getWriter().write("error: invalid numbers");
            return;
        }
        String userId = null;
        Object userObj = request.getSession().getAttribute("user");
        if (userObj != null) userId = userObj.toString();

        try (Connection conn = DBConnect.getConn()) {
            // ensure reviews table exists
            try (PreparedStatement psCreate = conn.prepareStatement(
                    "CREATE TABLE IF NOT EXISTS reviews (" +
                            "r_id INT NOT NULL AUTO_INCREMENT, " +
                            "p_id INT NOT NULL, " +
                            "user_id VARCHAR(255) DEFAULT NULL, " +
                            "rating TINYINT NOT NULL, " +
                            "comment TEXT, " +
                            "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                            "PRIMARY KEY (r_id), INDEX (p_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;")) {
                psCreate.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement("INSERT INTO reviews (p_id, user_id, rating, comment) VALUES (?, ?, ?, ?)")) {
                ps.setInt(1, pId);
                ps.setString(2, userId);
                ps.setInt(3, rating);
                ps.setString(4, comment);
                ps.executeUpdate();
            }

            response.getWriter().write("success");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("error: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");

        String pIdStr = request.getParameter("p_id");
        if (pIdStr == null) {
            response.getWriter().write("{}");
            return;
        }
        int pId;
        try {
            pId = Integer.parseInt(pIdStr);
        } catch (NumberFormatException e) {
            response.getWriter().write("{}");
            return;
        }

        try (Connection conn = DBConnect.getConn()) {
            // ensure table exists (safe)
            try (PreparedStatement psCreate = conn.prepareStatement(
                    "CREATE TABLE IF NOT EXISTS reviews (" +
                            "r_id INT NOT NULL AUTO_INCREMENT, " +
                            "p_id INT NOT NULL, " +
                            "user_id VARCHAR(255) DEFAULT NULL, " +
                            "rating TINYINT NOT NULL, " +
                            "comment TEXT, " +
                            "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                            "PRIMARY KEY (r_id), INDEX (p_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;")) {
                psCreate.executeUpdate();
            }

            double avg = 0.0;
            int count = 0;
            try (PreparedStatement psAvg = conn.prepareStatement("SELECT AVG(rating) as avg_rating, COUNT(*) as cnt FROM reviews WHERE p_id = ?")) {
                psAvg.setInt(1, pId);
                try (ResultSet rs = psAvg.executeQuery()) {
                    if (rs.next()) {
                        avg = rs.getDouble("avg_rating");
                        count = rs.getInt("cnt");
                    }
                }
            }

            StringBuilder json = new StringBuilder();
            json.append('{');
            json.append("\"average\":").append(String.format("%.1f", avg)).append(',');
            json.append("\"count\":").append(count).append(',');
            json.append("\"reviews\":");
            json.append('[');
            try (PreparedStatement ps = conn.prepareStatement("SELECT user_id, rating, comment, created_at FROM reviews WHERE p_id = ? ORDER BY created_at DESC LIMIT 50")) {
                ps.setInt(1, pId);
                try (ResultSet rs = ps.executeQuery()) {
                    boolean first = true;
                    while (rs.next()) {
                        if (!first) json.append(',');
                        first = false;
                        String user = rs.getString("user_id");
                        if (user == null) user = "Guest";
                        int rating = rs.getInt("rating");
                        String comment = rs.getString("comment");
                        String created = rs.getString("created_at");
                        // escape
                        if (comment == null) comment = "";
                        comment = comment.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","\\r");
                        user = user.replace("\\","\\\\").replace("\"","\\\"");
                        json.append('{')
                                .append("\"user\":\"").append(user).append("\",")
                                .append("\"rating\":").append(rating).append(',')
                                .append("\"comment\":\"").append(comment).append("\",")
                                .append("\"date\":\"").append(created).append("\"")
                                .append('}');
                    }
                }
            }
            json.append(']');
            json.append('}');

            PrintWriter out = response.getWriter();
            out.write(json.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{}");
        }
    }
}
