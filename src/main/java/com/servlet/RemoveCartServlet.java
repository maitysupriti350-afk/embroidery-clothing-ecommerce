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

@WebServlet("/RemoveCartServlet")
public class RemoveCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String cidStr = request.getParameter("cid");
        if (cidStr == null || cidStr.trim().isEmpty()) {
            response.sendRedirect("cart.jsp");
            return;
        }
        
        int cid;
        try {
            cid = Integer.parseInt(cidStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("cart.jsp");
            return;
        }
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("auth.jsp");
            return;
        }
        String userId = session.getAttribute("user").toString();

        String sql = "DELETE FROM cart WHERE c_id=? AND user_id=?";
        
        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cid);
            ps.setString(2, userId);
            
            int i = ps.executeUpdate();
            
            if(i == 1) {
                session.setAttribute("succMsg", "Item Removed!");
            } else {
                session.setAttribute("failedMsg", "Something went wrong!");
            }
           
            response.sendRedirect("cart.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}