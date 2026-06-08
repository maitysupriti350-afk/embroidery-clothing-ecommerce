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

@WebServlet("/addProduct")
public class AddProductServlet extends HttpServlet {
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

        String pName = request.getParameter("p_name");
        String pCategory = request.getParameter("p_category");
        String pPrice = request.getParameter("p_price");
        String pImage = request.getParameter("p_image");
        String pDesc = request.getParameter("p_desc");

        if (pName == null || pCategory == null || pPrice == null || pImage == null || pDesc == null
                || pName.trim().isEmpty() || pCategory.trim().isEmpty() || pPrice.trim().isEmpty()
                || pImage.trim().isEmpty() || pDesc.trim().isEmpty()) {
            session.setAttribute("failedMsg", "All fields are required.");
            response.sendRedirect("addproduct.jsp");
            return;
        }

        try (Connection conn = DBConnect.getConn();
             PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO products(p_name, p_category, p_price, p_image, p_desc) VALUES(?,?,?,?,?)")) {
            ps.setString(1, pName.trim());
            ps.setString(2, pCategory.trim());
            ps.setBigDecimal(3, new BigDecimal(pPrice.trim()));
            ps.setString(4, pImage.trim());
            ps.setString(5, pDesc.trim());

            int result = ps.executeUpdate();
            if (result == 1) {
                session.setAttribute("succMsg", "Product added successfully.");
            } else {
                session.setAttribute("failedMsg", "Could not add the product. Please try again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("failedMsg", "Error adding product: " + e.getMessage());
        }

        response.sendRedirect("addproduct.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("dashboard.jsp");
    }
}
