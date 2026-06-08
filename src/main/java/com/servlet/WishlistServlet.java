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

@WebServlet("/WishlistServlet")
public class WishlistServlet extends HttpServlet { 
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        
       
        Object userObj = session.getAttribute("user");

        if (userObj == null) {
            try {
                response.getWriter().write("notlogin");
            } catch (Exception ex) {
                // Ignore if response already committed
            }
            return;
        }

        String userId = userObj.toString(); 
        String productIdStr = request.getParameter("p_id");

        if (productIdStr != null) {
            try {
                int pId = Integer.parseInt(productIdStr);

                String checkSql = "SELECT * FROM wishlist WHERE p_id = ? AND user_id = ?";
                String deleteSql = "DELETE FROM wishlist WHERE p_id = ? AND user_id = ?";
                String insertSql = "INSERT INTO wishlist (p_id, user_id) VALUES (?, ?)";

                try (Connection conn = DBConnect.getConn();
                     PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setInt(1, pId);
                    psCheck.setString(2, userId);

                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                                psDel.setInt(1, pId);
                                psDel.setString(2, userId);
                                psDel.executeUpdate();
                            }
                            try {
                                response.getWriter().write("removed");
                            } catch (Exception ex) {
                                // Ignore if response already committed
                            }
                        } else {
                            try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                                psIns.setInt(1, pId);
                                psIns.setString(2, userId);
                                psIns.executeUpdate();
                            }
                            try {
                                response.getWriter().write("added");
                            } catch (Exception ex) {
                                // Ignore if response already committed
                            }
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                try {
                    response.getWriter().write("error");
                } catch (Exception ex) {
                    // Ignore if response already committed
                }
            }
        } else {
            try {
                response.getWriter().write("error");
            } catch (Exception ex) {
                // Ignore if response already committed
            }
        }
    }
}