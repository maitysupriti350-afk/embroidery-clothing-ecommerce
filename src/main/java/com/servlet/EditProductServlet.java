package com.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.conn.DBConnect;

@WebServlet("/EditProductServlet")
public class EditProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("auth.jsp");
            return;
        }
        Boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin"));
        if (!isAdmin) {
            response.sendRedirect("dashboard.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        String pName = request.getParameter("p_name");
        String pCategory = request.getParameter("p_category");
        String pPrice = request.getParameter("p_price");
        String pImage = request.getParameter("p_image");
        String pDesc = request.getParameter("p_desc");

        if (idStr == null || pName == null || pCategory == null || pPrice == null || pImage == null || pDesc == null
                || idStr.trim().isEmpty() || pName.trim().isEmpty() || pCategory.trim().isEmpty() || pPrice.trim().isEmpty()
                || pImage.trim().isEmpty() || pDesc.trim().isEmpty()) {
            session.setAttribute("failedMsg", "All fields are required.");
            response.sendRedirect("editProduct.jsp?id=" + idStr);
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            try (Connection conn = DBConnect.getConn();
                 PreparedStatement ps = conn.prepareStatement(
                        "UPDATE products SET p_name = ?, p_category = ?, p_price = ?, p_image = ?, p_desc = ? WHERE p_id = ?")) {
                ps.setString(1, pName.trim());
                ps.setString(2, pCategory.trim());
                ps.setBigDecimal(3, new BigDecimal(pPrice.trim()));
                ps.setString(4, pImage.trim());
                ps.setString(5, pDesc.trim());
                ps.setInt(6, id);

                int result = ps.executeUpdate();
                if (result == 1) {
                    session.setAttribute("succMsg", "Product updated successfully.");
                } else {
                    session.setAttribute("failedMsg", "Product not found or could not be updated.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error updating product: " + e.getMessage());
        }

        response.sendRedirect("adminDashboard.jsp");
    }
}