package com.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import com.conn.DBConnect;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/UpdateCartServlet")
public class UpdateCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("auth.jsp");
            return;
        }
        String userId = session.getAttribute("user").toString();

        String cidStr = request.getParameter("cid");
        String qtyStr = request.getParameter("quantity");

        if (cidStr == null || cidStr.trim().isEmpty()) {
            response.sendRedirect("cart.jsp");
            return;
        }

        try {
            int cid = Integer.parseInt(cidStr);
            int qty = Integer.parseInt(qtyStr);

            if (qty <= 0) {
                // Quantity is 0 or less - remove the item
                String deleteSql = "DELETE FROM cart WHERE c_id = ? AND user_id = ?";
                try (Connection conn = DBConnect.getConn();
                     PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                    ps.setInt(1, cid);
                    ps.setString(2, userId);
                    ps.executeUpdate();
                }
                session.setAttribute("succMsg", "Item removed from cart.");
            } else {
                // Update quantity
                String updateSql = "UPDATE cart SET quantity = ? WHERE c_id = ? AND user_id = ?";
                try (Connection conn = DBConnect.getConn();
                     PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, qty);
                    ps.setInt(2, cid);
                    ps.setString(3, userId);
                    int result = ps.executeUpdate();
                    if (result == 1) {
                        session.setAttribute("succMsg", "Cart updated.");
                    } else {
                        session.setAttribute("failedMsg", "Could not update cart item.");
                    }
                }
            }
        } catch (NumberFormatException e) {
            session.setAttribute("failedMsg", "Invalid input.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error updating cart: " + e.getMessage());
        }

        response.sendRedirect("cart.jsp");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("cart.jsp");
    }
}
